import Foundation

/// Server / local OTA package metadata (aligned with Android `OtaUpgradeInfo`).
struct OtaUpgradeInfo {
    var version: String?
    var build: Int64?
    var forceUpdate: Bool = false
    var updateContent: String?
    var firmwares: [OtaFirmwareItem] = []
    /// Optional diff-mode resource package (required when zip contains `diff_ctrl*.bin`).
    var resource: OtaResourceItem?
}

struct OtaFirmwareItem {
    var url: String
    var md5: String?
    var name: String?
    var id: String?
    /// Firmware type from server (`0x01` platform, picture types used by production apps).
    var type: Int = 0x01
}

struct OtaResourceItem {
    var name: String?
    var url: String?
    var md5: String?
    var fromVersion: String?
    var toVersion: String?
}
