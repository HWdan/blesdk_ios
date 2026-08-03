import Foundation
import CryptoKit

/// HTTP helpers for the online watchface catalog and package download.
///
/// # Business
/// Uses the HaWoFit / Huawo **test** host (`test.huawo-wear.com`). Production apps
/// should swap `baseURL` / `fileBaseURL` and `customerCode` for their own backend.
///
/// # List API
/// `GET api/v1/products/{deviceType}/watchfaces?customerCode=Huawo&locale=…`
/// - `deviceType` comes from bound / connected device info (must not be blank).
/// - Response: `{ ok|code, msg, rows: [...] }`; each row maps to `OnlineWatchface`.
///
/// # Download + MD5
/// Relative `bin` / thumbnail paths are resolved under `fileBaseURL`.
/// When `binMd5` is present, a mismatch deletes the cache file and fails the install.
///
/// # Caveats
/// - Sync wrappers use semaphores — call from a **background** queue (Online tab does).
/// - Progress for download is coarse (start ≈5%, complete ≈100%); the repository
///   remaps it into the 0…40 band of the overall install progress.
enum WatchfaceApi {
    static let baseURL = "https://test.huawo-wear.com/"
    static let fileBaseURL = "https://test.huawo-wear.com/files/"
    /// Tenant / OEM code expected by the test catalog API.
    static let customerCode = "Huawo"

    /// Fetches the online dial list for `deviceType`.
    ///
    /// Sends `appId` / `appVersion` headers (same pattern as HaWoFit). Throws
    /// `SdkError` on HTTP / JSON / business failures.
    static func fetchOnlineWatchfaces(deviceType: String) throws -> [OnlineWatchface] {
        let type = deviceType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !type.isEmpty else { throw SdkError(code: -1, message: "deviceType is blank") }
        let locale = apiLocale()
        let encodedType = type.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? type
        let encodedLocale = locale.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? locale
        let urlString = "\(baseURL)api/v1/products/\(encodedType)/watchfaces?customerCode=\(customerCode)&locale=\(encodedLocale)"
        guard let url = URL(string: urlString) else { throw SdkError(code: -1, message: "bad url") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let appId = Bundle.main.bundleIdentifier ?? "com.huawo.BleSdkDemo"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        request.setValue(appId, forHTTPHeaderField: "appId")
        request.setValue(appVersion, forHTTPHeaderField: "appVersion")
        let (data, response) = try syncData(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw SdkError(code: http.statusCode, message: "HTTP \(http.statusCode)")
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw SdkError(code: -1, message: "invalid response encoding")
        }
        return try parseWatchfaceList(json)
    }

    /// Turns a relative file path into an absolute URL under `fileBaseURL`.
    /// Already-absolute `http(s)` URLs are returned unchanged.
    static func resolveFileUrl(_ path: String?) -> String {
        guard let path = path?.nilIfEmpty else { return "" }
        if path.lowercased().hasPrefix("http") { return path }
        return fileBaseURL + path
    }

    /// Downloads a package into Caches/`subDir`, optionally verifying MD5.
    ///
    /// - Parameters:
    ///   - url: Relative or absolute `bin` path.
    ///   - fileName: Local cache file name (usually last path component of `bin`).
    ///   - expectMd5: If non-empty, must match the file MD5 (case-insensitive hex).
    /// - Returns: Local file URL of the ZIP.
    static func downloadToCache(url: String,
                                fileName: String,
                                expectMd5: String?,
                                subDir: String = "online_watchface",
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

    /// Parses catalog JSON into `[OnlineWatchface]`.
    /// Accepts either `ok: true` or `code: 0` as success (API variants).
    static func parseWatchfaceList(_ json: String) throws -> [OnlineWatchface] {
        guard let data = json.data(using: .utf8),
              let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SdkError(code: -1, message: "invalid JSON")
        }
        let ok = (root["ok"] as? Bool) ?? ((root["code"] as? Int) == 0)
        if !ok {
            let msg = (root["msg"] as? String)?.nilIfEmpty
                ?? (root["message"] as? String)?.nilIfEmpty
                ?? "watchface list failed"
            throw SdkError(code: -1, message: msg)
        }
        let rows = (root["rows"] as? [[String: Any]]) ?? []
        return rows.compactMap { row in
            let id = (row["id"] as? String)
                ?? (row["id"] as? NSNumber)?.stringValue
                ?? ""
            let name = (row["name"] as? String) ?? ""
            guard !id.isEmpty || !name.isEmpty else { return nil }
            let byteSize: Int64 = {
                if let n = row["byteSize"] as? NSNumber { return n.int64Value }
                if let s = row["byteSize"] as? String, let v = Int64(s) { return v }
                return 0
            }()
            return OnlineWatchface(
                id: id.isEmpty ? name : id,
                name: name.isEmpty ? id : name,
                thumbnail: (row["thumbnail"] as? String)?.nilIfEmpty,
                aodThumbnail: (row["aodThumbnail"] as? String)?.nilIfEmpty,
                bin: (row["bin"] as? String)?.nilIfEmpty,
                binMd5: (row["binMd5"] as? String)?.nilIfEmpty,
                byteSizeKb: byteSize
            )
        }
    }

    /// Maps demo locale to API `locale` query (`zh-Hans` / `en`).
    private static func apiLocale() -> String {
        switch LocaleHelper.current {
        case .zh: return "zh-Hans"
        case .en: return "en"
        case .system:
            let code = Locale.preferredLanguages.first ?? "en"
            return code.hasPrefix("zh") ? "zh-Hans" : "en"
        }
    }

    /// Blocking download into `savePath` (call off the main thread).
    private static func downloadToFile(_ urlString: String, to savePath: URL, onProgress: ((Int) -> Void)?) throws {
        guard let url = URL(string: urlString) else { throw SdkError(code: -1, message: "bad url") }
        var request = URLRequest(url: url)
        request.timeoutInterval = 120
        let semaphore = DispatchSemaphore(value: 0)
        var resultData: Data?
        var resultError: Error?
        onProgress?(5)
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if let error = error { resultError = error; return }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                resultError = SdkError(code: http.statusCode, message: "HTTP \(http.statusCode)")
                return
            }
            resultData = data
            onProgress?(100)
        }.resume()
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
        guard let result = result else { throw SdkError(code: -1, message: "timeout") }
        return result
    }

    private static func md5Hex(of fileURL: URL) -> String {
        guard let data = try? Data(contentsOf: fileURL) else { return "" }
        return Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
