import Foundation
import CryptoKit

/// Server-side OTA helpers: check for updates + download firmware / resource files.
/// Aligned with Android `OtaFirmwareApi`.
///
/// ## Check-upgrade API
/// - `POST https://test.huawo-wear.com/api/v1/devices/upgrades`
/// - Body: `currentVersion`, `currentBuild`, `productCode`, `customerCode`, `deviceId`
/// - Headers: `appId`, `appVersion`
enum OtaFirmwareApi {
    static let baseURL = "https://test.huawo-wear.com/"
    static let fileBaseURL = "https://test.huawo-wear.com/files/"
    static let customerCode = "Huawo"
    private static let checkPath = "api/v1/devices/upgrades"

    /// Query the upgrade server for a firmware package matching this device.
    static func checkUpgrade(currentFirmwareRaw: String,
                             productCode: String,
                             deviceId: String) throws -> OtaUpgradeInfo {
        let currentVersion = FirmwareVersionUtils.extractV(currentFirmwareRaw)
        guard !currentVersion.isEmpty else {
            throw SdkError(code: -1, message: "Cannot parse major version from firmware: \(currentFirmwareRaw)")
        }
        let currentBuild = FirmwareVersionUtils.extractB(currentFirmwareRaw) ?? 0
        let url = URL(string: baseURL + checkPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let appId = Bundle.main.bundleIdentifier ?? "com.huawo.BleSdkDemo"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        request.setValue(appId, forHTTPHeaderField: "appId")
        request.setValue(appVersion, forHTTPHeaderField: "appVersion")
        let body: [String: Any] = [
            "currentVersion": currentVersion,
            "productCode": productCode,
            "currentBuild": currentBuild,
            "customerCode": customerCode,
            "deviceId": deviceId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try syncData(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw SdkError(code: http.statusCode, message: "HTTP \(http.statusCode)")
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw SdkError(code: -1, message: "empty upgrade response")
        }
        return try parseUpgradeResponse(json)
    }

    static func isNewerThan(_ info: OtaUpgradeInfo, currentFirmwareRaw: String) -> Bool {
        guard !info.firmwares.isEmpty else { return false }
        let curV = FirmwareVersionUtils.extractV(currentFirmwareRaw)
        guard let curB = FirmwareVersionUtils.extractB(currentFirmwareRaw),
              let destV = info.version,
              let destB = info.build else { return false }
        return FirmwareVersionUtils.canUpgrade(
            currentVersion: curV,
            currentBuild: curB,
            destVersion: destV,
            destBuild: destB
        )
    }

    static func resolveFileUrl(_ path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        if path.lowercased().hasPrefix("http") { return path }
        return fileBaseURL + path
    }

    /// Download into `Caches/[subDir]/[fileName]`, optionally verify MD5.
    /// `onProgress` reports 0...100 for this single file.
    @discardableResult
    static func downloadToCache(url: String,
                                fileName: String,
                                expectMd5: String?,
                                subDir: String,
                                onProgress: ((Int) -> Void)? = nil) throws -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(subDir, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let out = dir.appendingPathComponent(fileName)
        try downloadToFile(resolveFileUrl(url), to: out, onProgress: onProgress)
        if let expect = expectMd5, !expect.isEmpty {
            let actual = md5Hex(of: out)
            if actual.caseInsensitiveCompare(expect) != .orderedSame {
                try? FileManager.default.removeItem(at: out)
                throw SdkError(code: -1, message: "MD5 mismatch: expect=\(expect) actual=\(actual)")
            }
        }
        return out
    }

    static func parseUpgradeResponse(_ json: String) throws -> OtaUpgradeInfo {
        guard let data = json.data(using: .utf8),
              let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SdkError(code: -1, message: "invalid JSON")
        }
        let ok = (root["ok"] as? Bool) ?? ((root["code"] as? Int) == 0)
        if !ok {
            let msg = (root["msg"] as? String)?.nilIfEmpty
                ?? (root["message"] as? String)?.nilIfEmpty
                ?? "check upgrade failed"
            throw SdkError(code: -1, message: msg)
        }
        guard let obj = root["data"] as? [String: Any] else { return OtaUpgradeInfo() }
        return parseUpgradeInfoObject(obj)
    }

    private static func parseUpgradeInfoObject(_ obj: [String: Any]) -> OtaUpgradeInfo {
        var firmwares: [OtaFirmwareItem] = []
        let arr = (obj["firmwares"] as? [[String: Any]])
            ?? (obj["firmwareList"] as? [[String: Any]])
            ?? (obj["files"] as? [[String: Any]])
            ?? []
        for f in arr {
            let url = (f["url"] as? String)?.nilIfEmpty ?? (f["downloadUrl"] as? String)?.nilIfEmpty ?? ""
            if url.isEmpty { continue }
            firmwares.append(OtaFirmwareItem(
                url: url,
                md5: (f["md5"] as? String)?.nilIfEmpty ?? (f["fileMd5"] as? String)?.nilIfEmpty,
                name: (f["name"] as? String)?.nilIfEmpty,
                id: (f["id"] as? String)?.nilIfEmpty,
                type: (f["type"] as? Int) ?? 0x01
            ))
        }
        var resource: OtaResourceItem?
        if let r = obj["resource"] as? [String: Any] {
            resource = OtaResourceItem(
                name: (r["name"] as? String)?.nilIfEmpty,
                url: (r["url"] as? String)?.nilIfEmpty,
                md5: (r["md5"] as? String)?.nilIfEmpty,
                fromVersion: (r["fromVersion"] as? String)?.nilIfEmpty,
                toVersion: (r["toVersion"] as? String)?.nilIfEmpty
            )
        }
        let buildValue: Int64? = {
            if let n = obj["build"] as? NSNumber { return n.int64Value }
            if let s = obj["build"] as? String { return Int64(s) }
            return nil
        }()
        return OtaUpgradeInfo(
            version: (obj["version"] as? String)?.nilIfEmpty
                ?? (obj["firmwareVersion"] as? String)?.nilIfEmpty,
            build: buildValue,
            forceUpdate: (obj["forceUpdate"] as? Bool) ?? false,
            updateContent: (obj["updateContent"] as? String)?.nilIfEmpty
                ?? (obj["content"] as? String)?.nilIfEmpty
                ?? (obj["desc"] as? String)?.nilIfEmpty,
            firmwares: firmwares,
            resource: resource
        )
    }

    private static func downloadToFile(_ urlString: String, to savePath: URL, onProgress: ((Int) -> Void)?) throws {
        guard let url = URL(string: urlString) else { throw SdkError(code: -1, message: "bad url") }
        var request = URLRequest(url: url)
        request.timeoutInterval = 120
        let semaphore = DispatchSemaphore(value: 0)
        var resultData: Data?
        var resultError: Error?
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error { resultError = error; return }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                resultError = SdkError(code: http.statusCode, message: "HTTP \(http.statusCode)")
                return
            }
            resultData = data
            onProgress?(100)
        }
        // Coarse progress: mark start then finish (URLSession dataTask has no byte progress without delegate).
        onProgress?(5)
        task.resume()
        _ = semaphore.wait(timeout: .now() + 180)
        if let resultError = resultError { throw resultError }
        guard let data = resultData, !data.isEmpty else {
            throw SdkError(code: -1, message: "Downloaded empty: \(savePath.lastPathComponent)")
        }
        try data.write(to: savePath, options: .atomic)
    }

    private static func syncData(for request: URLRequest) throws -> (Data, URLResponse) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (Data, URLResponse)?
        var err: Error?
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error { err = error; return }
            guard let data = data, let response = response else {
                err = SdkError(code: -1, message: "empty response")
                return
            }
            result = (data, response)
        }.resume()
        _ = semaphore.wait(timeout: .now() + 45)
        if let err = err { throw err }
        guard let result = result else { throw SdkError(code: -1, message: "request timeout") }
        return result
    }

    private static func md5Hex(of fileURL: URL) -> String {
        guard let data = try? Data(contentsOf: fileURL) else { return "" }
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
