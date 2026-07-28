import Foundation
import zlib

/// Builds a 7-day AGPS assistance zip for Sifli watches, aligned with Android `AgpsXywBuilder`.
///
/// # Pipeline
/// 1. Download five constellation ephemeris files (`.pgl`) from the RX Networks host.
/// 2. Parse GNSS validity from each file header and **append a 16-byte trailer**:
///    `"AGPS"` + little-endian start UTC seconds + little-endian end UTC seconds + padding.
/// 3. Package processed files into a **store** (uncompressed) ZIP whose entry names use the
///    prefix `music/gps/agps/` — required by the watch firmware path layout.
///
/// Work runs on a background queue; progress and completion are delivered on the main queue
/// when using `buildSevenDayZip`. The resulting `zipURL` is then pushed with
/// `BleRepository.pushAgpsZip` → `SifliWatchfaceSDK.syncZipFile(type: 3, byteAlign: true)`.
enum AgpsXywBuilder {
    /// Progress callback payload for the download / package phase (UI maps `fraction` to ~0...0.5).
    struct Progress {
        var message: String
        /// Normalized progress for this builder only: `0...0.5` (push uses the remaining half).
        var fraction: Float
    }

    /// Successful build output: local zip path plus the aggregate validity window in **ms**.
    struct Result {
        var zipURL: URL
        var validStartTimeMs: Int64
        var validEndTimeMs: Int64
    }

    /// Remote base URL for XYW AGPS `.pgl` files (cleartext HTTP — requires ATS exception).
    private static let baseURL = "http://starcourse.rx-networks.cn/IYMx9qGm7H/"

    /// Fixed set of source filenames (GPS / BDS / QZSS / GLONASS / Galileo).
    private static let sourceFiles = [
        "f1e1G7.pgl", // GPS
        "f1e1C7.pgl", // BDS
        "f1e1J7.pgl", // QZSS
        "f1e1E7.pgl", // GLO
        "f1e1R7.pgl"  // GAL
    ]

    /// Zip entry path prefix expected by the watch (same as Android).
    private static let zipEntryPrefix = "music/gps/agps/"

    /// Asynchronously builds the AGPS zip into `directory`, reporting progress and completing on main.
    /// - Parameters:
    ///   - directory: Working directory (raw / processed / zip are created underneath).
    ///   - onProgress: Optional progress updates (may be called off the main thread; UI should hop).
    ///   - completion: Success with `Result`, or failure with download / parse / zip errors.
    static func buildSevenDayZip(
        into directory: URL,
        onProgress: ((Progress) -> Void)? = nil,
        completion: @escaping (Swift.Result<Result, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try buildSync(into: directory, onProgress: onProgress)
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    /// Synchronous implementation: download → trailer → zip. Throws on first hard failure.
    private static func buildSync(
        into directory: URL,
        onProgress: ((Progress) -> Void)?
    ) throws -> Result {
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        let rawDir = directory.appendingPathComponent("raw", isDirectory: true)
        let processedDir = directory.appendingPathComponent("processed", isDirectory: true)
        try fm.createDirectory(at: rawDir, withIntermediateDirectories: true)
        try fm.createDirectory(at: processedDir, withIntermediateDirectories: true)

        // Aggregate validity: take the latest start and earliest end across all files.
        var validStartMs: Int64 = 0
        var validEndMs: Int64 = 0
        var processedURLs: [URL] = []

        for (index, name) in sourceFiles.enumerated() {
            // Cache-bust query so CDN / proxies do not serve a stale ephemeris.
            let urlString = "\(baseURL)\(name)?t=\(Int(Date().timeIntervalSince1970 * 1000))"
            onProgress?(Progress(message: L10n.tr("agps_dl_file", name), fraction: Float(index) / Float(sourceFiles.count) * 0.35))
            let rawFile = rawDir.appendingPathComponent(name)
            try downloadFile(urlString, to: rawFile)

            onProgress?(Progress(
                message: L10n.tr("agps_process_file", name),
                fraction: 0.35 + Float(index) / Float(sourceFiles.count) * 0.1
            ))
            let outFile = processedDir.appendingPathComponent(name)
            let (startSec, endSec) = try appendValidTimeTrailer(source: rawFile, dest: outFile)
            let startMs = startSec * 1000
            let endMs = endSec * 1000
            if validStartMs <= 0 || startMs > validStartMs { validStartMs = startMs }
            if validEndMs <= 0 || endMs < validEndMs { validEndMs = endMs }
            processedURLs.append(outFile)
            onProgress?(Progress(
                message: L10n.tr("agps_processed", index + 1, sourceFiles.count),
                fraction: 0.45 + Float(index + 1) / Float(sourceFiles.count) * 0.05
            ))
        }

        onProgress?(Progress(message: L10n.tr("agps_zipping"), fraction: 0.48))
        let zipURL = directory.appendingPathComponent("agps_xyw.zip")
        try zipWithAgpsPaths(processedURLs, to: zipURL)
        onProgress?(Progress(message: L10n.tr("agps_zip_done"), fraction: 0.5))
        return Result(zipURL: zipURL, validStartTimeMs: validStartMs, validEndTimeMs: validEndMs)
    }

    // MARK: - Download

    /// Downloads `fileURL` to `savePath` with up to 3 attempts (60s request / 90s wait timeout).
    private static func downloadFile(_ fileURL: String, to savePath: URL) throws {
        var lastError: Error?
        for attempt in 0..<3 {
            do {
                guard let url = URL(string: fileURL) else {
                    throw SdkError(code: -1, message: "bad url")
                }
                var request = URLRequest(url: url)
                request.timeoutInterval = 60
                request.httpMethod = "GET"
                // Blocking wait keeps the builder single-threaded and simple to sequence.
                let semaphore = DispatchSemaphore(value: 0)
                var dataResult: Data?
                var httpError: Error?
                URLSession.shared.dataTask(with: request) { data, response, error in
                    defer { semaphore.signal() }
                    if let error = error { httpError = error; return }
                    if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                        httpError = SdkError(code: http.statusCode, message: "HTTP \(http.statusCode)")
                        return
                    }
                    dataResult = data
                }.resume()
                _ = semaphore.wait(timeout: .now() + 90)
                if let httpError = httpError { throw httpError }
                guard let data = dataResult, !data.isEmpty else {
                    throw SdkError(code: -1, message: "Downloaded empty: \(savePath.lastPathComponent)")
                }
                try data.write(to: savePath)
                return
            } catch {
                lastError = error
                if attempt == 2 { throw error }
            }
        }
        throw lastError ?? SdkError(code: -1, message: "Download failed")
    }

    // MARK: - Trailer

    /// Copies `source` to `dest` and appends the 16-byte AGPS validity trailer.
    ///
    /// Trailer layout (little-endian for time fields):
    /// - bytes 0...3: ASCII `"AGPS"`
    /// - bytes 4...7: valid start UTC seconds
    /// - bytes 8...11: valid end UTC seconds
    /// - bytes 12...15: reserved / zero padding
    ///
    /// Header parsing offsets match Android (constellation at offset 30 after fixed header).
    /// - Returns: `(startUTCSeconds, endUTCSeconds)` derived from the ephemeris header.
    private static func appendValidTimeTrailer(source: URL, dest: URL) throws -> (Int64, Int64) {
        let bytes = try Data(contentsOf: source)
        guard !bytes.isEmpty else {
            throw SdkError(code: -1, message: "Empty AGPS file: \(source.lastPathComponent)")
        }
        // Fixed header 29 bytes + EE VERSION 1 → constellation field at offset 30.
        var start = 29 + 1
        let constel = bytesToInt(bytes, start, 1)
        start += 1
        let gnssStart = bytesToLongBigEnd(bytes, start, 4)
        start += 4
        let numberOfBlock = bytesToInt(bytes, start, 1)
        start += 1
        let durationInHour = bytesToInt(bytes, start, 1)

        let startTime = gnssToUtc(gnssStart, constel: constel)
        let endTime = startTime + Int64(numberOfBlock) * Int64(durationInHour) * 3600

        var trailer = Data(count: 16)
        trailer.replaceSubrange(0..<4, with: Data("AGPS".utf8))
        trailer.replaceSubrange(4..<8, with: longToBytesLe(startTime, 4))
        trailer.replaceSubrange(8..<12, with: longToBytesLe(endTime, 4))

        var out = bytes
        out.append(trailer)
        try out.write(to: dest)
        return (startTime, endTime)
    }

    /// Writes a store-method ZIP with each file under `music/gps/agps/<filename>`.
    private static func zipWithAgpsPaths(_ files: [URL], to zipURL: URL) throws {
        var entries: [(String, Data)] = []
        for f in files {
            let data = try Data(contentsOf: f)
            entries.append(("\(zipEntryPrefix)\(f.lastPathComponent)", data))
        }
        let zipData = try buildStoreZip(entries: entries)
        try zipData.write(to: zipURL)
        guard (try? zipURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0 > 0 else {
            throw SdkError(code: -1, message: "AGPS zip empty")
        }
    }

    // MARK: - GNSS helpers (Android parity)

    /// Converts a GNSS time-of-week style field into UTC seconds, applying constellation offsets.
    private static func gnssToUtc(_ gnss: Int64, constel: Int) -> Int64 {
        let mslSystemGpsOffset: Int64 = 315_964_800
        let mslGpsBdsOffset: Int64 = 820_108_800
        let mslGpsGalOffset: Int64 = 619_315_187
        let mslGpsBeidouLeap: Int64 = 14
        let mslGpsGalileoLeap: Int64 = 13

        var result = gnss + (mslSystemGpsOffset - 18)
        switch constel {
        case 3: result += mslGpsBdsOffset + mslGpsBeidouLeap
        case 2: result += mslGpsGalOffset + mslGpsGalileoLeap
        default: break
        }
        return result
    }

    /// Little-endian unsigned integer decode of `length` bytes starting at `offset`.
    private static func bytesToInt(_ data: Data, _ offset: Int, _ length: Int) -> Int {
        var result = 0
        for i in 0..<length {
            result += Int(data[offset + i]) << (i * 8)
        }
        return result
    }

    /// Big-endian integer decode of `length` bytes starting at `offset`.
    private static func bytesToLongBigEnd(_ data: Data, _ offset: Int, _ length: Int) -> Int64 {
        var result: Int64 = 0
        for i in (0..<length).reversed() {
            result += Int64(data[offset + i]) << ((length - 1 - i) * 8)
        }
        return result
    }

    /// Encodes `value` as `length` little-endian bytes (truncated if larger).
    private static func longToBytesLe(_ value: Int64, _ length: Int) -> Data {
        var result = Data(count: length)
        for i in 0..<length {
            result[i] = UInt8((value >> (i * 8)) & 0xff)
        }
        return result
    }

    // MARK: - Minimal store zip

    /// Builds an uncompressed (method 0) ZIP from `(entryName, payload)` pairs.
    /// Avoids third-party Zip dependencies for this fixed AGPS packaging path.
    private static func buildStoreZip(entries: [(String, Data)]) throws -> Data {
        var central = Data()
        var local = Data()
        var offset: UInt32 = 0
        for (name, data) in entries {
            let nameData = Data(name.utf8)
            var localHeader = Data()
            localHeader.append(contentsOf: UInt32(0x04034b50).leBytes) // local file header signature
            localHeader.append(contentsOf: UInt16(20).leBytes)         // version needed
            localHeader.append(contentsOf: UInt16(0).leBytes)          // general purpose bit flag
            localHeader.append(contentsOf: UInt16(0).leBytes)          // compression method = store
            localHeader.append(contentsOf: UInt16(0).leBytes)          // last mod time
            localHeader.append(contentsOf: UInt16(0).leBytes)          // last mod date
            let crc = crc32(data)
            localHeader.append(contentsOf: crc.leBytes)
            localHeader.append(contentsOf: UInt32(data.count).leBytes) // compressed size
            localHeader.append(contentsOf: UInt32(data.count).leBytes) // uncompressed size
            localHeader.append(contentsOf: UInt16(nameData.count).leBytes)
            localHeader.append(contentsOf: UInt16(0).leBytes)          // extra field length
            localHeader.append(nameData)
            localHeader.append(data)
            local.append(localHeader)

            var ch = Data()
            ch.append(contentsOf: UInt32(0x02014b50).leBytes) // central directory header
            ch.append(contentsOf: UInt16(20).leBytes)
            ch.append(contentsOf: UInt16(20).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: crc.leBytes)
            ch.append(contentsOf: UInt32(data.count).leBytes)
            ch.append(contentsOf: UInt32(data.count).leBytes)
            ch.append(contentsOf: UInt16(nameData.count).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt16(0).leBytes)
            ch.append(contentsOf: UInt32(0).leBytes)
            ch.append(contentsOf: offset.leBytes)
            ch.append(nameData)
            central.append(ch)
            offset += UInt32(localHeader.count)
        }
        var end = Data()
        end.append(contentsOf: UInt32(0x06054b50).leBytes) // end of central directory
        end.append(contentsOf: UInt16(0).leBytes)
        end.append(contentsOf: UInt16(0).leBytes)
        end.append(contentsOf: UInt16(entries.count).leBytes)
        end.append(contentsOf: UInt16(entries.count).leBytes)
        end.append(contentsOf: UInt32(central.count).leBytes)
        end.append(contentsOf: UInt32(local.count).leBytes)
        end.append(contentsOf: UInt16(0).leBytes)
        return local + central + end
    }

    /// CRC-32 used in ZIP local / central headers (zlib).
    private static func crc32(_ data: Data) -> UInt32 {
        data.withUnsafeBytes { buf -> UInt32 in
            let ptr = buf.bindMemory(to: UInt8.self).baseAddress
            return UInt32(zlib.crc32(0, ptr, UInt32(data.count)))
        }
    }
}

private extension FixedWidthInteger {
    /// Little-endian raw bytes of `self` for ZIP header fields.
    var leBytes: [UInt8] {
        withUnsafeBytes(of: littleEndian) { Array($0) }
    }
}
