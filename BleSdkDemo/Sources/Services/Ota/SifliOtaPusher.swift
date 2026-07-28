import Foundation
import SifliOTAManagerSDK
import SSZipArchive

/// Prepared NAND DFU payload for `SFOTAManager.startOTANand` (HaWoFit `OtaHandler` parity).
struct SifliOtaPackage {
    var controlImageURL: URL?
    var imageInfos: [SFNandImageFileInfo]
    /// Diff-mode picture / resource package path; `nil` when unused (must not pass an empty file URL).
    var resourceURL: URL?
    var unzipDirectory: URL
    /// Human-readable summary for demo logs.
    var debugSummary: String
}

/// Downloads, unzips, and maps Sifli firmware bins, then drives `SFOTAManager` DFU.
///
/// Push path matches HaWoFit `OtaHandler.startSifliOta`:
/// - Unzip **platform** ZIP (`type == 0x01` preferred, else first entry)
/// - Map `hcpu` / `lcpu` / `patch_lcpu` / `ctrl` / `diff_ctrl` / `outdyn` / `outroot`
/// - Wait until OTA BLE core is `poweredOn`, then `startOTANand(..., tryResume: true)`
/// - `resourcePath` is **nil** for full packages (empty `file://` URL → `LoadResourceZipFailed`)
final class SifliOtaPusher: NSObject, SFOTAManagerDelegate, SFOTALogManagerDelegate {
    static let shared = SifliOtaPusher()

    private let manager = SFOTAManager.share
    private var progressHandler: ((Int) -> Void)?
    private var completionHandler: ((Result<Void, Error>) -> Void)?
    private var logHandler: ((String) -> Void)?
    private var mappedProgress = 0
    private var working = false
    /// Prevents `stop()` from reporting cancel after a real complete callback.
    private var finished = false
    /// Continuations waiting for `bleState == .poweredOn` before DFU.
    private var bleReadyWaiters: [() -> Void] = []

    private override init() {
        super.init()
    }

    /// Touch / init the shared manager early so CoreBluetooth can reach `poweredOn`
    /// before the user taps Start (avoids startOTANand racing an uninitialized BLE core).
    func warmUp() {
        manager.initSDK()
        manager.delegate = self
        let otaLog = SFOTALogManager.share
        otaLog.delegate = self
        otaLog.logEnable = true
        emitLog("SFOTA warmUp SDK=\(SFOTAManager.SDKVersion) bleState=\(manager.bleState.rawValue)")
    }

    var isWorking: Bool { working }

    /// Download + unzip + map bins for [info]. Progress is 0...100 for the prepare phase.
    func preparePackage(info: OtaUpgradeInfo,
                        onProgress: ((Int) -> Void)? = nil) throws -> SifliOtaPackage {
        // Prefer platform package (0x01); fall back to first entry (Android demo uses first).
        let firmware = info.firmwares.first(where: { $0.type == 0x01 }) ?? info.firmwares.first
        guard let firmware = firmware else {
            throw SdkError(code: -1, message: L10n.tr("ota_err_no_package"))
        }
        guard !firmware.url.isEmpty else {
            throw SdkError(code: -1, message: L10n.tr("ota_err_url_md5"))
        }
        let fileName = (firmware.md5?.nilIfEmpty) ?? "fw_\(Int(Date().timeIntervalSince1970))"
        let zipURL = try OtaFirmwareApi.downloadToCache(
            url: firmware.url,
            fileName: fileName,
            expectMd5: firmware.md5,
            subDir: "device/qjs",
            onProgress: { pct in onProgress?(Int(Double(pct) * 0.85)) }
        )

        let unzipDir = zipURL.deletingLastPathComponent()
            .appendingPathComponent("unzip_\(fileName)", isDirectory: true)
        try? FileManager.default.removeItem(at: unzipDir)
        try FileManager.default.createDirectory(at: unzipDir, withIntermediateDirectories: true)
        let ok = SSZipArchive.unzipFile(atPath: zipURL.path, toDestination: unzipDir.path)
        guard ok else { throw SdkError(code: -1, message: L10n.tr("ota_err_unzip")) }

        // `subpathsOfDirectory` parity with HaWoFit StorageUtils.getFiles (relative paths).
        let relative = try FileManager.default.subpathsOfDirectory(atPath: unzipDir.path)
        var imageInfos: [SFNandImageFileInfo] = []
        var ctrlURL: URL?
        var diffCtrlURL: URL?
        var outdynURL: URL?
        var outrootURL: URL?
        var foundBins: [String] = []

        for rel in relative {
            let name = (rel as NSString).lastPathComponent
            guard name.lowercased().hasSuffix(".bin") else { continue }
            let file = unzipDir.appendingPathComponent(rel)
            foundBins.append(name)

            if name.hasPrefix("diff_ctrl") {
                diffCtrlURL = file
            } else if name.hasPrefix("ctrl") {
                ctrlURL = file
            }
            if name.hasPrefix("hcpu") {
                imageInfos.append(SFNandImageFileInfo(path: file, imageID: .HCPU))
            } else if name.hasPrefix("patch_lcpu") || (name.hasPrefix("patch") && name.hasSuffix(".bin")) {
                // HaWoFit: patch_lcpu; Android: patch* → LCPU_PATCH
                imageInfos.append(SFNandImageFileInfo(path: file, imageID: .LCPU_PATCH))
            } else if name.hasPrefix("lcpu") {
                imageInfos.append(SFNandImageFileInfo(path: file, imageID: .LCPU))
            } else if name.hasPrefix("outdyn") {
                outdynURL = file
            } else if name.hasPrefix("outroot") {
                outrootURL = file
            }
        }

        var resourceURL: URL?
        let controlURL: URL?
        if let diffCtrlURL = diffCtrlURL {
            controlURL = diffCtrlURL
            // Diff OTA requires a separate resource package (Android / HaWoFit).
            // Prefer `info.resource`; else a picture-type firmware entry.
            let picture = info.firmwares.first(where: { $0.type != 0x01 && $0.type != 0 })
            if let res = info.resource, let resURL = res.url?.nilIfEmpty, let resName = res.name?.nilIfEmpty {
                resourceURL = try OtaFirmwareApi.downloadToCache(
                    url: resURL,
                    fileName: resName,
                    expectMd5: res.md5,
                    subDir: "device/qjs_diff",
                    onProgress: { pct in onProgress?(85 + Int(Double(pct) * 0.15)) }
                )
            } else if let picture = picture, !picture.url.isEmpty {
                let name = picture.name?.nilIfEmpty ?? picture.md5?.nilIfEmpty ?? "resource"
                resourceURL = try OtaFirmwareApi.downloadToCache(
                    url: picture.url,
                    fileName: name,
                    expectMd5: picture.md5,
                    subDir: "device/qjs_diff",
                    onProgress: { pct in onProgress?(85 + Int(Double(pct) * 0.15)) }
                )
            } else {
                throw SdkError(code: -1, message: L10n.tr("ota_err_diff_resource"))
            }
        } else if let ctrlURL = ctrlURL {
            controlURL = ctrlURL
            if let outdynURL = outdynURL {
                imageInfos.append(SFNandImageFileInfo(path: outdynURL, imageID: .DYN))
            }
            if let outrootURL = outrootURL {
                imageInfos.append(SFNandImageFileInfo(path: outrootURL, imageID: .RES))
            }
        } else {
            throw SdkError(
                code: -1,
                message: L10n.tr("ota_err_no_ctrl") + " bins=\(foundBins.joined(separator: ","))"
            )
        }

        guard let controlURL = controlURL else {
            throw SdkError(code: -1, message: L10n.tr("ota_err_no_ctrl"))
        }

        onProgress?(100)
        let summary = "ctrl=\(controlURL.lastPathComponent) images=\(imageInfos.count) res=\(resourceURL?.lastPathComponent ?? "nil") bins=\(foundBins.joined(separator: ","))"
        return SifliOtaPackage(
            controlImageURL: controlURL,
            imageInfos: imageInfos,
            resourceURL: resourceURL,
            unzipDirectory: unzipDir,
            debugSummary: summary
        )
    }

    /// Starts NAND DFU. Progress callback is overall 0...100 for the push phase only.
    /// Waits for OTA BLE core `poweredOn` (up to ~5s) before calling `startOTANand`.
    func startDFU(devIdentifier: String,
                  package: SifliOtaPackage,
                  onProgress: @escaping (Int) -> Void,
                  onLog: ((String) -> Void)? = nil,
                  completion: @escaping (Result<Void, Error>) -> Void) {
        if working {
            completion(.failure(SdkError(code: 190, message: L10n.tr("err_transfer_busy"))))
            return
        }
        working = true
        finished = false
        progressHandler = onProgress
        completionHandler = completion
        logHandler = onLog
        mappedProgress = 0
        manager.delegate = self
        SFOTALogManager.share.delegate = self
        SFOTALogManager.share.logEnable = true

        guard let control = package.controlImageURL else {
            finish(.failure(SdkError(code: SFOTAErrorType.LoadControlFileFailed.rawValue,
                                     message: L10n.tr("ota_err_no_ctrl"))))
            return
        }
        // Critical: pass nil when no resource. Empty file URL → LoadResourceZipFailed immediately.
        let resource: URL? = package.resourceURL

        emitLog("DFU wait bleState=\(manager.bleState.rawValue) uuid=\(devIdentifier)")
        whenBlePoweredOn(timeout: 5.0) { [weak self] ready in
            guard let self = self else { return }
            guard self.working, !self.finished else { return }
            guard ready else {
                self.finish(.failure(SdkError(
                    code: SFOTAErrorType.UnavailableBleStatus.rawValue,
                    message: "OTA BLE not poweredOn (state=\(self.manager.bleState.rawValue))"
                )))
                return
            }
            self.emitLog("startOTANand ctrl=\(control.lastPathComponent) images=\(package.imageInfos.count) res=\(resource?.lastPathComponent ?? "nil")")
            self.manager.startOTANand(
                targetDeviceIdentifier: devIdentifier,
                resourcePath: resource,
                controlImageFilePath: control,
                imageFileInfos: package.imageInfos,
                tryResume: true,
                imageResponseFrequnecy: 4
            )
        }
    }

    func stop() {
        manager.stop()
        working = false
        progressHandler = nil
        logHandler = nil
        guard !finished else { return }
        finished = true
        if let completionHandler = completionHandler {
            self.completionHandler = nil
            completionHandler(.failure(SdkError(code: 3, message: L10n.tr("ota_cancelled"))))
        }
    }

    // MARK: - BLE ready

    private func whenBlePoweredOn(timeout: TimeInterval, then: @escaping (Bool) -> Void) {
        if manager.bleState == .poweredOn {
            then(true)
            return
        }
        bleReadyWaiters.append { then(true) }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
            guard let self = self else { return }
            if self.manager.bleState == .poweredOn { return }
            // Timed out: clear waiters that still expect this attempt.
            if !self.bleReadyWaiters.isEmpty {
                self.bleReadyWaiters.removeAll()
                then(false)
            }
        }
    }

    private func flushBleReadyWaiters() {
        let waiters = bleReadyWaiters
        bleReadyWaiters.removeAll()
        waiters.forEach { $0() }
    }

    private func finish(_ result: Result<Void, Error>) {
        working = false
        guard !finished else { return }
        finished = true
        let done = completionHandler
        completionHandler = nil
        progressHandler = nil
        // Keep logHandler until after reporting so callers can still append.
        switch result {
        case .failure(let error):
            emitLog("failed: \(error.localizedDescription)")
        case .success:
            emitLog("success")
        }
        logHandler = nil
        done?(result)
    }

    private func emitLog(_ msg: String) {
        print("[BleSdkDemo OTA] \(msg)")
        logHandler?(msg)
    }

    // MARK: - SFOTAManagerDelegate

    func otaManager(manager: SFOTAManager, updateBleState state: BleCoreManagerState) {
        // poweredOn(5) with "no working module" is normal at CBCentralManager init —
        // not a failure by itself. We only start DFU after poweredOn.
        emitLog("bleState=\(state.rawValue) working=\(working)")
        if state == .poweredOn {
            flushBleReadyWaiters()
        }
    }

    func otaManager(manager: SFOTAManager, stage: SFOTAProgressStage, totalBytes: Int, completedBytes: Int) {
        DispatchQueue.main.async {
            guard totalBytes > 0 else { return }
            let ratio = Float(completedBytes) / Float(totalBytes)
            // HaWoFit / HwOTAUpdateManager: nand_res → 0..50, nand_image → 50..100
            let mapped: Int
            if stage == .nand_res {
                mapped = Int(ratio * 50)
            } else if stage == .nand_image {
                mapped = 50 + Int(ratio * 50)
            } else {
                mapped = Int(ratio * 100)
            }
            self.mappedProgress = max(self.mappedProgress, min(100, mapped))
            self.progressHandler?(self.mappedProgress)
        }
    }

    func otaManager(manager: SFOTAManager, complete error: SFOTAError?) {
        DispatchQueue.main.async {
            if let error = error {
                let msg = "\(error.errorDes) (type=\(error.errorType.rawValue))"
                self.finish(.failure(SdkError(code: error.errorType.rawValue, message: msg)))
            } else {
                self.finish(.success(()))
            }
        }
    }

    // MARK: - SFOTALogManagerDelegate

    func otaLogManager(manager: SFOTALogManager, onLog log: SFOTALogModel!, logLevel level: OTALogLevel) {
        guard let message = log?.message, !message.isEmpty else { return }
        // Surface SDK logs that look like failures / module state to the demo UI.
        let lower = message.lowercased()
        if message.contains("没有工作模块")
            || message.contains("失败")
            || lower.contains("fail")
            || lower.contains("error")
            || lower.contains("timeout") {
            DispatchQueue.main.async { self.emitLog("[SFOTA] \(message)") }
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
