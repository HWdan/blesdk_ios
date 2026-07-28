import Foundation

/// Parse / compare watch firmware version strings.
///
/// Device firmware is typically shaped like:
/// `V{major}R{…}T{…}H{…}B{build}…`
/// e.g. `V1.0.0RxxxTxxxHxxxB123`
///
/// Used by OTA check (aligned with Android `FirmwareVersionUtils`):
/// - Extract `V` / `B` for the server request body (`currentVersion` / `currentBuild`).
/// - Decide whether the server package is newer (`canUpgrade`).
enum FirmwareVersionUtils {
    private static let pattern = try! NSRegularExpression(
        pattern: #"V(.+?)R(.+?)T(.+?)H(.+?)B(\d+).*"#,
        options: [.caseInsensitive]
    )

    static func extractV(_ str: String?) -> String {
        extract(str, group: 1) ?? ""
    }

    static func extractB(_ str: String?) -> Int64? {
        guard let s = extract(str, group: 5) else { return nil }
        return Int64(s)
    }

    /// Formats as `major(build)`, e.g. `1.0.0(123)`. Empty when unparsable.
    static func formatDisplay(_ str: String?) -> String {
        guard let str = str, !str.isEmpty else { return "" }
        let major = extractV(str)
        guard let build = extractB(str), !major.isEmpty else { return "" }
        return "\(major)(\(build))"
    }

    static func semanticVersionEquals(_ a: String?, _ b: String?) -> Bool {
        if (a ?? "").isEmpty && (b ?? "").isEmpty { return true }
        guard let a = a, let b = b, !a.isEmpty, !b.isEmpty else { return false }
        if a == b { return true }
        let pa = a.split(separator: ".").map(String.init)
        let pb = b.split(separator: ".").map(String.init)
        let n = max(pa.count, pb.count)
        for i in 0..<n {
            let va = i < pa.count ? (Int(pa[i].trimmingCharacters(in: .whitespaces)) ?? 0) : 0
            let vb = i < pb.count ? (Int(pb[i].trimmingCharacters(in: .whitespaces)) ?? 0) : 0
            if va != vb { return false }
        }
        return true
    }

    /// Whether destination package is newer than current.
    static func canUpgrade(currentVersion: String?,
                           currentBuild: Int64?,
                           destVersion: String?,
                           destBuild: Int64?) -> Bool {
        guard let currentVersion = currentVersion, !currentVersion.isEmpty,
              let destVersion = destVersion, !destVersion.isEmpty,
              let currentBuild = currentBuild, let destBuild = destBuild else { return false }
        if semanticVersionEquals(currentVersion, destVersion) {
            return currentBuild < destBuild
        }
        let pa = currentVersion.split(separator: ".").map(String.init)
        let pb = destVersion.split(separator: ".").map(String.init)
        let n = max(pa.count, pb.count)
        for i in 0..<n {
            let vc = i < pa.count ? (Int(pa[i].trimmingCharacters(in: .whitespaces)) ?? 0) : 0
            let vd = i < pb.count ? (Int(pb[i].trimmingCharacters(in: .whitespaces)) ?? 0) : 0
            if vc == vd { continue }
            return vc < vd
        }
        return false
    }

    private static func extract(_ str: String?, group: Int) -> String? {
        guard let str = str, !str.isEmpty else { return nil }
        let range = NSRange(str.startIndex..., in: str)
        guard let match = pattern.firstMatch(in: str, options: [], range: range),
              match.numberOfRanges > group,
              let r = Range(match.range(at: group), in: str) else { return nil }
        return String(str[r])
    }
}
