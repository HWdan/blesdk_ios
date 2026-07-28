import Foundation
import UIKit
import WatchfaceSDK

/// 封装 HwBluetoothSDK / SifliWatchfaceSDK，对齐 Android BleRepository 能力。
final class BleRepository {
    static let shared = BleRepository()

    private let store = BoundDeviceStore.shared
    private var initialized = false
    private(set) var connectionHandlers: [(ConnectionEvent) -> Void] = []

    /// 绑定成功后开启；手动断开 / 解绑时关闭。
    private(set) var autoReconnectEnabled = false
    /// 对齐 BleConnectManager：失败后 0.5s 再试；连接超时 13s。
    private let reconnectRetryDelay: TimeInterval = 0.5
    private let reconnectTimeout = 13
    private var reconnectWorkItem: DispatchWorkItem?
    private var reconnectAttempt = 0
    private var reconnectInFlight = false

    private(set) var isTransferring = false
    private var activeTransferKind: TransferKind?

    enum TransferKind { case music, album, agps }

    private init() {}

    var sdk: HwBluetoothSDK { HwBluetoothSDK.sharedInstance() }
    var center: HwBluetoothCenter { HwBluetoothCenter.sharedInstance() }

    func addConnectionHandler(_ handler: @escaping (ConnectionEvent) -> Void) {
        connectionHandlers.append(handler)
    }

    func setAutoReconnectEnabled(_ enabled: Bool) {
        autoReconnectEnabled = enabled
        if !enabled {
            cancelReconnect()
        }
    }

    func initSDK() {
        guard !initialized else { return }
        sdk.initSDK()
        SifliWatchfaceSDK.getInstance().initSDK()
        initialized = true

        // 对齐 BleConnectManager：连接态变化延后 0.3s 再处理
        sdk.addBluetoothConnectionStateChangedCallback { [weak self] state in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.handleConnectionStateChanged(state)
            }
        }

        // 蓝牙重新可用且已绑定 → 立即重连
        sdk.addBluetoothStateChangedCallback { [weak self] state in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if state == .available,
                   self.autoReconnectEnabled,
                   !self.isConnected() {
                    self.startConnectBluetooth(reasonKey: "reason_bt_on")
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applicationDidBecomeActive()
        }
    }

    func destroy() {
        if initialized {
            // ObjC destroySDK；部分 Swift 映射为 destroy()
            if sdk.responds(to: NSSelectorFromString("destroySDK")) {
                sdk.perform(NSSelectorFromString("destroySDK"))
            } else {
                sdk.perform(NSSelectorFromString("destroy"))
            }
            initialized = false
        }
    }

    func version() -> String { sdk.version() }
    func isConnected() -> Bool { sdk.connected() }
    func connectedName() -> String? { sdk.connectedDevice()?.name }
    func connectedMac() -> String? { sdk.connectedDevice()?.macAddress }
    func connectedUUID() -> String? { sdk.connectedDevice()?.peripheral?.identifier.uuidString }

    func loadBoundDevice() -> BoundDeviceRecord? { store.load() }

    func saveBoundDevice(mac: String, name: String?, info: BleDeviceInfoModel?) {
        store.save(BoundDeviceRecord(
            macAddress: mac,
            name: name,
            deviceId: info?.id,
            type: info?.type,
            firmwareVersion: info?.firmwareVersion,
            battery: info?.battery,
            protocolVersion: info?.protocolVersion
        ))
    }

    func clearBoundDevice() { store.clear() }

    // MARK: - Scan / Connect

    func scan(timeout: TimeInterval = 10,
              onUpdate: @escaping ([BleDeviceItem]) -> Void,
              onFinish: @escaping () -> Void) {
        var map: [String: BleDeviceItem] = [:]
        sdk.scan(callback: { devices, _ in
            guard let devices = devices else { return }
            for d in devices {
                let key = (d.macAddress?.isEmpty == false ? d.macAddress! : (d.uuid ?? UUID().uuidString))
                map[key] = BleDeviceItem(
                    name: d.name,
                    macAddress: d.macAddress ?? "",
                    uuid: d.uuid,
                    rssi: d.rssi?.intValue
                )
            }
            DispatchQueue.main.async {
                onUpdate(Array(map.values).sorted { ($0.rssi ?? -999) > ($1.rssi ?? -999) })
            }
        }, stopAfter: timeout, stopCallback: {
            DispatchQueue.main.async { onFinish() }
        })
    }

    func stopScan() { sdk.stopScan() }

    func connect(device: HwBluetoothDevice, timeout: TimeInterval = 30,
                 completion: @escaping (Result<BleDeviceItem, Error>) -> Void) {
        sdk.connect(with: device, timeout: Int(timeout)) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let item = BleDeviceItem(
                    name: device.name,
                    macAddress: device.macAddress ?? "",
                    uuid: device.uuid,
                    rssi: device.rssi?.intValue
                )
                self?.emit(.connected(name: item.name, mac: item.macAddress))
                completion(.success(item))
            }
        }
    }

    func connect(mac: String, timeout: TimeInterval = 30,
                 completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.connect(withMac: mac, timeout: Int(timeout)) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    let d = self?.sdk.connectedDevice()
                    self?.emit(.connected(name: d?.name, mac: d?.macAddress ?? mac))
                    completion(.success(()))
                }
            }
        }
    }

    func disconnect(completion: ((Error?) -> Void)? = nil) {
        // 手动断开前由调用方关闭 autoReconnect；此处仅取消排队中的重试
        cancelReconnect()
        sdk.disconnect { error in
            DispatchQueue.main.async {
                self.emit(.disconnected)
                completion?(error)
            }
        }
    }

    // MARK: - Reconnect (对齐 HaWoFit BleConnectManager)

    /// 冷启动 / 回前台 / 蓝牙可用时调用
    func startConnectBluetooth(reasonKey: String = "reason_auto") {
        guard autoReconnectEnabled else { return }
        guard store.load() != nil else { return }
        guard !isConnected() else {
            cancelReconnect()
            return
        }
        guard sdk.powerOn() else { return }
        // 后台不发起重连（与 BleConnectManager 一致；后台循环已注释掉）
        if UIApplication.shared.applicationState == .background { return }

        cancelScheduledReconnect()
        reconnectAttempt += 1
        let attempt = reconnectAttempt
        let reason = L10n.tr(reasonKey)
        emit(.reconnecting(attempt: attempt, reason: reason))

        reconnectInFlight = true

        if let last = sdk.getLastConnectedDevice() {
            sdk.connect(with: last, timeout: reconnectTimeout) { [weak self] error in
                DispatchQueue.main.async {
                    self?.handleReconnectCallback(error: error, reasonKey: reasonKey, attempt: attempt)
                }
            }
            return
        }

        guard let mac = store.load()?.macAddress, !mac.isEmpty else {
            reconnectInFlight = false
            return
        }
        sdk.connect(withMac: mac, timeout: reconnectTimeout) { [weak self] error in
            DispatchQueue.main.async {
                self?.handleReconnectCallback(error: error, reasonKey: reasonKey, attempt: attempt)
            }
        }
    }

    private func handleConnectionStateChanged(_ state: HwBluetoothConnectionState) {
        if state == .connected {
            cancelReconnect()
            reconnectAttempt = 0
            reconnectInFlight = false
            let d = sdk.connectedDevice()
            emit(.connected(name: d?.name, mac: d?.macAddress))
            return
        }
        guard state == .disconnected else { return }
        emit(.disconnected)
        // 对齐 BleConnectManager.bluetoothConnectionStateChanged：
        // 前台 + 蓝牙开 + 已绑定 → 立即 startConnectBluetooth
        guard autoReconnectEnabled else { return }
        guard sdk.powerOn() else { return }
        if UIApplication.shared.applicationState == .background { return }
        startConnectBluetooth(reasonKey: "reason_auto")
    }

    private func handleReconnectCallback(error: Error?, reasonKey: String, attempt: Int) {
        reconnectInFlight = false
        if let error = error {
            emit(.reconnectFailed(attempt: attempt, message: error.localizedDescription))
            if UIApplication.shared.applicationState == .background { return }
            guard autoReconnectEnabled, !isConnected() else { return }
            scheduleReconnectRetry(reasonKey: reasonKey)
            return
        }
        reconnectAttempt = 0
        let d = sdk.connectedDevice()
        emit(.connected(name: d?.name, mac: d?.macAddress ?? store.load()?.macAddress))
    }

    private func scheduleReconnectRetry(reasonKey: String) {
        cancelScheduledReconnect()
        let work = DispatchWorkItem { [weak self] in
            self?.startConnectBluetooth(reasonKey: reasonKey)
        }
        reconnectWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectRetryDelay, execute: work)
    }

    private func cancelScheduledReconnect() {
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
    }

    private func cancelReconnect() {
        cancelScheduledReconnect()
        reconnectInFlight = false
        reconnectAttempt = 0
    }

    private func applicationDidBecomeActive() {
        guard autoReconnectEnabled else { return }
        guard store.load() != nil else { return }
        guard !isConnected() else { return }
        startConnectBluetooth(reasonKey: "reason_foreground")
    }

    // MARK: - Bind

    func startBind(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.startBindDevice { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func endBind(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.endBindDevice { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func unbindDevice(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.unbindDevice { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setDeviceTime(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.setDeviceTime(Date(), is24H: true) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setUserInfo(completion: @escaping (Result<Void, Error>) -> Void) {
        let user = HwUserInfo()
        user.gender = .male
        user.age = 28
        user.height = 175
        user.weight = 70
        sdk.setUserInfo(user) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setUnitMetric(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.setUnit(.metric) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setLanguage(_ language: HwLanguage = HwLanguage(rawValue: 0x01)!,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.setLanguage(language) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func getDeviceInfo(completion: @escaping (Result<BleDeviceInfoModel, Error>) -> Void) {
        sdk.getDeviceInfo { info, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let info = info else {
                    completion(.failure(SdkError(code: -1, message: "deviceInfo nil")))
                    return
                }
                var model = BleDeviceInfoModel()
                // Swift 将 ObjC `Id` 导入为 `id`；勿用 KVC "id"（会抛 NSUnknownKeyException）
                model.id = info.id
                model.type = info.type
                model.firmwareVersion = info.firmwareVersion
                model.mac = info.mac
                model.battery = Int(info.battery)
                model.protocolVersion = Int(info.protocolVersion)
                model.displayingWatchfaceId = info.displayingWatchfaceId
                if let mac = model.mac, !mac.isEmpty {
                    self.sdk.updateMacAddressIfNeed(withMac: mac)
                }
                completion(.success(model))
            }
        }
    }

    func getPairState(completion: @escaping (Result<Bool, Error>) -> Void) {
        sdk.getPairState { ok, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success(ok)) }
            }
        }
    }

    func requestDeviceToPair(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.requestDeviceToPair { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func removeConnectionCache() { sdk.removeConnectionCache() }

    // MARK: - Health

    func getHealthDataCount(completion: @escaping (Result<HealthDataCount, Error>) -> Void) {
        center.getActivityNum { sportNum, sleepNum, heartrateNum, hrfNum, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                completion(.success(HealthDataCount(
                    activityCount: Int(sportNum),
                    sleepCount: Int(sleepNum),
                    heartrateCount: Int(heartrateNum),
                    hrfCount: Int(hrfNum)
                )))
            }
        }
    }

    func getActivities(count: UInt, completion: @escaping (Result<[HwActivity], Error>) -> Void) {
        guard count > 0 else { completion(.success([])); return }
        sdk.getActivities(count) { list, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success((list as? [HwActivity]) ?? [])) }
            }
        }
    }

    func getHeartrates(count: UInt = 50, completion: @escaping (Result<[Any], Error>) -> Void) {
        sdk.getHeartrates(count) { list, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success(list ?? [])) }
            }
        }
    }

    func getSleeps(count: UInt = 50, completion: @escaping (Result<[Any], Error>) -> Void) {
        sdk.getSleeps(count) { list, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success(list ?? [])) }
            }
        }
    }

    func deleteActivities(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.deleteActivities { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func deleteHeartrates(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.deleteHeartrates { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func deleteSleeps(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.deleteSleeps { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    /// 对齐 Android sync：必要时可先重连；计数 → 按数量拉取 → 非空再删表端。
    func syncHealthData(completion: @escaping (Result<String, Error>) -> Void) {
        getHealthDataCount { [weak self] countResult in
            guard let self = self else { return }
            switch countResult {
            case .failure(let e): completion(.failure(e))
            case .success(let count):
                self.fetchActivities(count: count.activityCount) { actResult in
                    let actList = (try? actResult.get()) ?? []
                    let actN = actList.count
                    let stepSum = actList.reduce(0) { $0 + Int($1.step) }
                    self.fetchHeartrates(count: count.heartrateCount) { hrResult in
                        let hrN = (try? hrResult.get())?.count ?? 0
                        self.fetchSleeps(count: count.sleepCount) { sleepResult in
                            let sleepN = (try? sleepResult.get())?.count ?? 0
                            let summary = L10n.tr("sync_summary", actN, stepSum, hrN, sleepN)
                            let afterDeletes = {
                                completion(.success(summary))
                            }
                            let delSleeps = {
                                if sleepN > 0 {
                                    self.deleteSleeps { _ in afterDeletes() }
                                } else {
                                    afterDeletes()
                                }
                            }
                            let delHR = {
                                if hrN > 0 {
                                    self.deleteHeartrates { _ in delSleeps() }
                                } else {
                                    delSleeps()
                                }
                            }
                            if actN > 0 {
                                self.deleteActivities { _ in delHR() }
                            } else {
                                delHR()
                            }
                        }
                    }
                }
            }
        }
    }

    private func fetchActivities(count: Int, completion: @escaping (Result<[HwActivity], Error>) -> Void) {
        guard count > 0 else { completion(.success([])); return }
        getActivities(count: UInt(count), completion: completion)
    }

    private func fetchHeartrates(count: Int, completion: @escaping (Result<[Any], Error>) -> Void) {
        guard count > 0 else { completion(.success([])); return }
        getHeartrates(count: UInt(count), completion: completion)
    }

    private func fetchSleeps(count: Int, completion: @escaping (Result<[Any], Error>) -> Void) {
        guard count > 0 else { completion(.success([])); return }
        getSleeps(count: UInt(count), completion: completion)
    }

    // MARK: - Goals

    func getGoals(completion: @escaping (Result<HwGoal, Error>) -> Void) {
        center.getGoalInfoModel { goal, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else if let goal = goal { completion(.success(goal)) }
                else { completion(.failure(SdkError(code: -1, message: "goal nil"))) }
            }
        }
    }

    func setGoal(type: HwGoalType, value: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.setGoalWith(type, goal: value) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setDemoGoals(completion: @escaping (Result<Void, Error>) -> Void) {
        let steps: [(HwGoalType, Int)] = [
            (.step, 80), (.caloris, 400), (.distance, 5), (.sleep, 8), (.duration, 30)
        ]
        func run(_ i: Int) {
            if i >= steps.count { completion(.success(())); return }
            let (t, v) = steps[i]
            setGoal(type: t, value: v) { result in
                switch result {
                case .failure(let e): completion(.failure(e))
                case .success: run(i + 1)
                }
            }
        }
        run(0)
    }

    // MARK: - Alarms / reminders

    func getAlarms(completion: @escaping (Result<[HwAlarm], Error>) -> Void) {
        sdk.getAlarmsWithCallback { list, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success((list as? [HwAlarm]) ?? [])) }
            }
        }
    }

    func addDemoAlarm(completion: @escaping (Result<Void, Error>) -> Void) {
        let alarm = HwAlarm()
        alarm.setValue(true, forKey: "S")
        alarm.custom = L10n.tr("alarms_demo_content")
        alarm.times = [HwTimePoint(hour: 7, minute: 30)]
        // 工作日：周一～周五（对齐 Android createDemoAlarm）
        let weekdays = Int(HwWeek.monday.rawValue) | Int(HwWeek.tuesday.rawValue) | Int(HwWeek.wednesday.rawValue)
            | Int(HwWeek.thursday.rawValue) | Int(HwWeek.friday.rawValue)
        alarm.setValue(weekdays, forKey: "week")
        sdk.add(alarm) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func deleteAllAlarms(completion: @escaping (Result<Void, Error>) -> Void) {
        // Prefer batch API if present
        let sel = NSSelectorFromString("deleteAlarmsWithCallback:")
        if sdk.responds(to: sel) {
            sdk.deleteAlarms { ok, error in
                DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
            }
            return
        }
        getAlarms { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let list):
                if list.isEmpty { completion(.success(())); return }
                let group = DispatchGroup()
                var firstError: Error?
                for a in list {
                    group.enter()
                    let idVal = (a.value(forKey: "Id") as? NSNumber)?.uintValue ?? 0
                    self.sdk.deleteAlarm(byID: idVal) { ok, error in
                        if let error = error, firstError == nil { firstError = error }
                        if !ok, firstError == nil { firstError = SdkError(code: -1, message: "del fail") }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    if let firstError = firstError { completion(.failure(firstError)) }
                    else { completion(.success(())) }
                }
            }
        }
    }

    func getSedentary(completion: @escaping (Result<HwSedentaryReminder, Error>) -> Void) {
        sdk.getSedentaryReminder { reminder, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else if let reminder = reminder { completion(.success(reminder)) }
                else { completion(.failure(SdkError(code: -1, message: "nil"))) }
            }
        }
    }

    func setDemoSedentary(completion: @escaping (Result<Void, Error>) -> Void) {
        let r = HwSedentaryReminder()
        r.on = true
        r.startTime = HwTimePoint(hour: 9, minute: 0)
        r.endTime = HwTimePoint(hour: 18, minute: 0)
        r.interval = 3600
        r.setValue(Self.weekdaysMask, forKey: "week")
        sdk.setSedentaryReminder(r) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setDemoDrinkWater(completion: @escaping (Result<Void, Error>) -> Void) {
        let c = HwDrinkWaterConfig()
        c.eventOn = true
        c.startHour = 8
        c.startMinute = 0
        c.endHour = 20
        c.endMinute = 0
        c.timeInterval = 3600
        c.duration = 5
        c.setValue(Self.everyDayMask, forKey: "week")
        sdk.setDrinkWaterConfig(c) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setDemoWashHand(completion: @escaping (Result<Void, Error>) -> Void) {
        let c = HwHandwashingConfig()
        c.eventOn = true
        c.startHour = 8
        c.startMinute = 0
        c.endHour = 22
        c.endMinute = 0
        c.timeInterval = 7200
        c.duration = 5
        c.setValue(Self.everyDayMask, forKey: "week")
        sdk.setHandwashingConfig(c) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    /// 周一～周五
    private static var weekdaysMask: Int {
        Int(HwWeek.monday.rawValue) | Int(HwWeek.tuesday.rawValue) | Int(HwWeek.wednesday.rawValue)
            | Int(HwWeek.thursday.rawValue) | Int(HwWeek.friday.rawValue)
    }

    /// 每天
    private static var everyDayMask: Int {
        weekdaysMask | Int(HwWeek.saturday.rawValue) | Int(HwWeek.sunday.rawValue)
    }

    // MARK: - Notify / contacts

    /// 通知开关列表（对齐 Android `getSocialAppSwitches`）。
    /// 注意：不是 `getSocialApps`（那是社交 App 图标包）。
    func getSocialSwitches(completion: @escaping (Result<[HwSocialSwitch], Error>) -> Void) {
        sdk.getSocialSwitches { list, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success((list as? [HwSocialSwitch]) ?? [])) }
            }
        }
    }

    /// Demo：开启微信 / 短信 / 来电（对齐 Android Wechat + SMS + IncomingCall）。
    func enableDemoSocialSwitches(completion: @escaping (Result<Void, Error>) -> Void) {
        let types: [HwSocialSwitchType] = [.wechat, .message, .calls]
        func run(_ i: Int) {
            if i >= types.count {
                DispatchQueue.main.async { completion(.success(())) }
                return
            }
            sdk.setSocialSwitchWith(types[i], s: true) { ok, error in
                if let error = error {
                    DispatchQueue.main.async { completion(.failure(error)) }
                } else if !ok {
                    DispatchQueue.main.async {
                        completion(.failure(SdkError(code: -1, message: "setSocialSwitch failed type=\(types[i].rawValue)")))
                    }
                } else {
                    run(i + 1)
                }
            }
        }
        run(0)
    }

    func setDemoContacts(completion: @escaping (Result<Void, Error>) -> Void) {
        let c1 = HwContact()
        c1.contactName = "Demo A"
        c1.contactPhone = "10086"
        let c2 = HwContact()
        c2.contactName = "Demo B"
        c2.contactPhone = "10010"
        sdk.setContacts([c1, c2]) { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    func setEmergencyContact(completion: @escaping (Result<Void, Error>) -> Void) {
        sdk.setSosName("Emergency", phoneNumber: "120") { ok, error in
            DispatchQueue.main.async { Self.boolResult(ok, error, completion) }
        }
    }

    // MARK: - Music / Album / AGPS

    func getMusicStorage(completion: @escaping (Result<MusicStorage, Error>) -> Void) {
        sdk.getMusicAvailableStorage { available, total, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success(MusicStorage(availableKb: Int(available), totalKb: Int(total)))) }
            }
        }
    }

    func getAlbumFileIds(completion: @escaping (Result<[Int], Error>) -> Void) {
        sdk.getAlbumFilesIdList { ids, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                let ints: [Int] = (ids ?? []).compactMap { item -> Int? in
                    if let n = item as? NSNumber { return n.intValue }
                    if let i = item as? Int { return i }
                    return Int("\(item)")
                }
                completion(.success(ints))
            }
        }
    }

    /// 分配 1...50 空闲槽位（对齐 Android allocateAlbumIndices）。
    func allocateAlbumIndices(count: Int, completion: @escaping (Result<[Int], Error>) -> Void) {
        getAlbumFileIds { result in
            switch result {
            case .failure(let e): completion(.failure(e))
            case .success(let used):
                let usedSet = Set(used)
                var free: [Int] = []
                for i in 1...50 where !usedSet.contains(i) {
                    free.append(i)
                    if free.count >= count { break }
                }
                if free.count < count {
                    completion(.failure(SdkError(code: -1, message: L10n.tr("album_no_slots", count, free.count))))
                } else {
                    completion(.success(free))
                }
            }
        }
    }

    func getBtConnectionState(completion: @escaping (Result<Bool, Error>) -> Void) {
        sdk.getBtConnectionState { ok, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)) }
                else { completion(.success(ok)) }
            }
        }
    }

    func getDeviceGpsStatus(completion: @escaping (Result<BleGpsStatusModel, Error>) -> Void) {
        sdk.getDeviceGpsStatus { status, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let status = status else {
                    completion(.failure(SdkError(code: -1, message: "gps status nil")))
                    return
                }
                var m = BleGpsStatusModel()
                // SDK 返回秒级时间戳（HaWoFit 展示时 *1000）
                m.agpsValidStartTimeMs = Self.normalizeEpochMs(Int64(status.agpsValidStartTime))
                m.agpsValidEndTimeMs = Self.normalizeEpochMs(Int64(status.agpsValidEndTime))
                m.gpsClipType = status.gpsClipType
                m.gpsFirmwareVersion = status.gpsFirmwareVersion
                m.gpsFirmwareBuild = Int(status.gpsFirmwareBuild)
                completion(.success(m))
            }
        }
    }

    func cancelTransfer() {
        SifliWatchfaceSDK.getInstance().stop()
        isTransferring = false
        activeTransferKind = nil
    }

    private func beginTransfer(_ kind: TransferKind) -> Error? {
        if isTransferring || SifliWatchfaceSDK.getInstance().isWorking {
            return SdkError(code: -1, message: L10n.tr("err_transfer_busy"))
        }
        isTransferring = true
        activeTransferKind = kind
        return nil
    }

    private func endTransfer() {
        isTransferring = false
        activeTransferKind = nil
    }

    /// iOS 统一走思澈推送，不依赖经典 BT。
    func pushMusicAuto(fileURLs: [URL],
                       onReady: @escaping () -> Void,
                       onProgress: @escaping (Float) -> Void,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        if let err = beginTransfer(.music) { completion(.failure(err)); return }
        pushMusicSifliInternal(fileURLs: fileURLs, onReady: onReady, onProgress: onProgress, completion: completion)
    }

    private func pushMusicSifliInternal(fileURLs: [URL],
                                        onReady: @escaping () -> Void,
                                        onProgress: @escaping (Float) -> Void,
                                        completion: @escaping (Result<Void, Error>) -> Void) {
        // 对齐 HaWoFit HwMusicService：目录必须是 …/music/mp3
        // SifliWatchfaceSDK.packageQjsMp3 会对路径 deletingLastPathComponent 后压缩 `music` 目录，
        // zip 内需为 music/mp3/*.mp3，否则表端单文件开始会返回错误码 22。
        let fm = FileManager.default
        let root = fm.temporaryDirectory
            .appendingPathComponent("qjs_musics_\(UUID().uuidString)", isDirectory: true)
        let mp3Dir = root.appendingPathComponent("selectTemp/music/mp3", isDirectory: true)
        do {
            try fm.createDirectory(at: mp3Dir, withIntermediateDirectories: true)
        } catch {
            endTransfer()
            completion(.failure(error))
            return
        }

        var copied = 0
        for url in fileURLs {
            let name = Self.sanitizeMusicFileName(url.lastPathComponent)
            let dest = mp3Dir.appendingPathComponent(name)
            do {
                if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
                try fm.copyItem(at: url, to: dest)
                copied += 1
            } catch {
                continue
            }
        }
        guard copied > 0 else {
            endTransfer()
            completion(.failure(SdkError(code: -1, message: L10n.tr("err_no_music"))))
            return
        }

        pushMusicSifli(directoryURL: mp3Dir, onCompress: { ok in
            if ok { onReady() }
        }, onProgress: { p in
            onProgress(Float(p) / 100.0)
        }, completion: { [weak self] result in
            try? fm.removeItem(at: root)
            self?.endTransfer()
            completion(result)
        })
    }

    /// 对齐 HwMusicViewController：去掉空格与特殊字符，避免表端无法识别文件名。
    private static func sanitizeMusicFileName(_ raw: String) -> String {
        let noSpace = raw.replacingOccurrences(of: " ", with: "")
        let banned = CharacterSet(charactersIn: "@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\"")
        let cleaned = noSpace.components(separatedBy: banned).joined()
        let base = cleaned.isEmpty ? "music.mp3" : cleaned
        if base.lowercased().hasSuffix(".mp3") { return base }
        return base + ".mp3"
    }

    func pushMusicJL(fileURLs: [URL],
                     onReady: @escaping () -> Void,
                     onProgress: @escaping (Float) -> Void,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        var models: [HwMultipleFileTransferModel] = []
        for url in fileURLs {
            guard let data = try? Data(contentsOf: url) else { continue }
            let m = HwMultipleFileTransferModel()
            m.fileName = url.lastPathComponent
            m.fileData = data
            m.musicType = MultipleFileTransferMusicType(rawValue: 0)!
            models.append(m)
        }
        guard !models.isEmpty else {
            completion(.failure(SdkError(code: -1, message: L10n.tr("err_no_music"))))
            return
        }
        center.startMultipleFileTransfer(
            models,
            transferType: MultipleFileTransferType(rawValue: 0x01)!,
            readyCallback: { ok, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)); return }
                    if ok { onReady() }
                }
            },
            progressCallback: { p, _ in DispatchQueue.main.async { onProgress(p) } },
            finishCallback: { ok, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)) }
                    else if ok { completion(.success(())) }
                    else { completion(.failure(SdkError(code: -1, message: "music transfer failed"))) }
                }
            }
        )
    }

    func pushMusicSifli(directoryURL: URL,
                        onCompress: @escaping (Bool) -> Void,
                        onProgress: @escaping (Int) -> Void,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uuid = connectedUUID() else {
            completion(.failure(SdkError(code: -1, message: "no connected uuid")))
            return
        }
        SifliWatchfaceSDK.getInstance().setMusicFiles(
            devIdentifier: uuid,
            musicFilePath: directoryURL,
            compressCallback: { ok in DispatchQueue.main.async { onCompress(ok) } },
            progressCallback: { p in DispatchQueue.main.async { onProgress(p) } },
            finishCallback: { ok, errInfo, errType, _ in
                DispatchQueue.main.async {
                    SifliWatchfaceSDK.getInstance().stop()
                    if ok { completion(.success(())) }
                    else { completion(.failure(SdkError(code: errType, message: errInfo ?? "sifli music fail"))) }
                }
            }
        )
    }

    /// 默认相册推送分辨率（对齐 Demo / 常见思澈表；APP 用产品宽高）。
    static let defaultAlbumSize = CGSize(width: 466, height: 466)

    func pushAlbumAuto(images: [UIImage],
                       size: CGSize = BleRepository.defaultAlbumSize,
                       onReady: @escaping () -> Void,
                       onProgress: @escaping (Float) -> Void,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        if let err = beginTransfer(.album) { completion(.failure(err)); return }
        let prepared = images.map { Self.resizeAndCropAlbumImage($0, to: size) }
        allocateAlbumIndices(count: prepared.count) { [weak self] idxResult in
            guard let self = self else { return }
            switch idxResult {
            case .failure(let e):
                self.endTransfer()
                completion(.failure(e))
            case .success(let indices):
                self.pushAlbumSifli(
                    images: prepared,
                    indices: indices,
                    width: Double(size.width),
                    height: Double(size.height),
                    onCompress: { _ in onReady() },
                    onProgress: { p in onProgress(Float(p) / 100.0) },
                    completion: { r in
                        self.endTransfer()
                        completion(r)
                    }
                )
            }
        }
    }

    /// 对齐 HwAlbumService `resizeAndCropImage:toSize:`：等比放大后居中裁剪到目标尺寸。
    static func resizeAndCropAlbumImage(_ image: UIImage, to size: CGSize) -> UIImage {
        guard size.width > 0, size.height > 0, image.size.width > 0, image.size.height > 0 else { return image }
        let scale = max(size.width / image.size.width, size.height / image.size.height)
        let scaled = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let origin = CGPoint(x: (size.width - scaled.width) / 2, y: (size.height - scaled.height) / 2)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: origin, size: scaled))
        }
    }

    func pushAlbumSifli(images: [UIImage],
                        indices: [Int]? = nil,
                        width: Double = 466,
                        height: Double = 466,
                        onCompress: @escaping (Bool) -> Void,
                        onProgress: @escaping (Int) -> Void,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uuid = connectedUUID() else {
            completion(.failure(SdkError(code: -1, message: "no connected uuid")))
            return
        }
        let target = CGSize(width: width, height: height)
        let face = SifliWatchfaceSDK.getInstance()
        face.width = width
        face.height = height
        var albums: [QjsAlbumModel] = []
        for (i, img) in images.enumerated() {
            let m = QjsAlbumModel()
            let idx = indices?[safe: i] ?? (i + 1)
            m.name = "\(idx)"
            // 再保险：保证送入 SDK 的图已是目标分辨率（SDK 内部是 fit，不保证铺满）
            let alreadyExact = abs(img.size.width - target.width) < 0.5 && abs(img.size.height - target.height) < 0.5
            m.image = alreadyExact ? img : Self.resizeAndCropAlbumImage(img, to: target)
            albums.append(m)
        }
        face.setPictures(
            devIdentifier: uuid,
            compressSuccessCallback: { ok in DispatchQueue.main.async { onCompress(ok) } },
            albums: albums,
            progressCallback: { p in DispatchQueue.main.async { onProgress(p) } },
            finishCallback: { ok, errInfo, errType, _ in
                DispatchQueue.main.async {
                    face.stop()
                    if ok { completion(.success(())) }
                    else { completion(.failure(SdkError(code: errType, message: errInfo ?? "album fail"))) }
                }
            }
        )
    }

    func pushAlbumJL(images: [UIImage],
                     indices: [Int]? = nil,
                     size: CGSize = BleRepository.defaultAlbumSize,
                     onReady: @escaping () -> Void,
                     onProgress: @escaping (Float) -> Void,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        var models: [HwMultipleFileTransferModel] = []
        for (i, image) in images.enumerated() {
            let resized = Self.resizeAndCropAlbumImage(image, to: size)
            guard let data = resized.jpegData(compressionQuality: 0.9) else { continue }
            let m = HwMultipleFileTransferModel()
            let idx = indices?[safe: i] ?? (i + 1)
            m.fileName = "PNG_\(idx).bin"
            m.fileData = data
            m.photoType = MultipleFileTransferPhotoType(rawValue: 1)!
            models.append(m)
        }
        guard !models.isEmpty else {
            completion(.failure(SdkError(code: -1, message: L10n.tr("err_no_images"))))
            return
        }
        center.startMultipleFileTransfer(
            models,
            transferType: MultipleFileTransferType(rawValue: 0x02)!,
            readyCallback: { ok, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)); return }
                    if ok { onReady() }
                }
            },
            progressCallback: { p, _ in DispatchQueue.main.async { onProgress(p) } },
            finishCallback: { ok, error in
                DispatchQueue.main.async {
                    if let error = error { completion(.failure(error)) }
                    else if ok { completion(.success(())) }
                    else { completion(.failure(SdkError(code: -1, message: "album transfer failed"))) }
                }
            }
        )
    }

    func pushAgpsZip(zipURL: URL,
                     onProgress: @escaping (Int) -> Void,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        if let err = beginTransfer(.agps) { completion(.failure(err)); return }
        guard let uuid = connectedUUID() else {
            endTransfer()
            completion(.failure(SdkError(code: -1, message: "no connected uuid")))
            return
        }
        SifliWatchfaceSDK.getInstance().syncZipFile(
            devIdentifier: uuid,
            filePath: zipURL,
            type: 3,
            byteAlign: true,
            progressCallback: { p in DispatchQueue.main.async { onProgress(p) } },
            finishCallback: { [weak self] ok, errInfo, errType, _ in
                DispatchQueue.main.async {
                    SifliWatchfaceSDK.getInstance().stop()
                    self?.endTransfer()
                    if ok { completion(.success(())) }
                    else { completion(.failure(SdkError(code: errType, message: errInfo ?? "agps fail"))) }
                }
            }
        )
    }

    // MARK: - Helpers

    private func emit(_ event: ConnectionEvent) {
        connectionHandlers.forEach { $0(event) }
    }

    private static func normalizeEpochMs(_ value: Int64) -> Int64 {
        // 秒级约 1e9，毫秒约 1e12
        if value > 0 && value < 10_000_000_000 { return value * 1000 }
        return value
    }

    private static func boolResult(_ ok: Bool, _ error: Error?,
                                   _ completion: (Result<Void, Error>) -> Void) {
        if let error = error { completion(.failure(error)) }
        else if ok { completion(.success(())) }
        else { completion(.failure(SdkError(code: -1, message: "operation failed"))) }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
