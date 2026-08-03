import Foundation

// MARK: - Online catalog item
//
// Mirrors one row from `GET api/v1/products/{deviceType}/watchfaces` (test host).
// Used by the Online tab and by `BleRepository.installOnlineWatchface`.

/// One online watchface row from the catalog API.
///
/// # Fields of note
/// - `bin` / `binMd5`: package URL (relative or absolute) and optional MD5 of the ZIP.
/// - `byteSizeKb`: server field `byteSize` is documented as **KB** (not bytes).
/// - `name`: used for the HaWoFit-style install match
///   (`catalog.name.contains(installedName)`). Prefer keeping server names stable.
struct OnlineWatchface: Equatable {
    var id: String
    var name: String
    var thumbnail: String?
    var aodThumbnail: String?
    /// Relative or absolute URL of the dial ZIP (`bin` field).
    var bin: String?
    /// Optional MD5 hex of the ZIP; empty / nil skips verification.
    var binMd5: String?
    /// Server `byteSize` unit is **KB**.
    var byteSizeKb: Int64
}

/// Phases reported by `BleRepository.installOnlineWatchface` to the Online UI.
///
/// Typical path: `checking` → (`switching` **or** `downloading` → `installing`) → `success` / `failed`.
enum OnlineWatchfaceInstallPhase: Equatable {
    case idle
    /// Querying installed names on the watch.
    case checking
    /// Face already on device; activating by name only (no ZIP transfer).
    case switching
    /// Downloading ZIP + optional MD5 check (UI progress ≈ 0…40).
    case downloading
    /// BLE push via `setOnlineWatchface` (UI progress ≈ 40…100).
    case installing
    case success
    case failed
}

// MARK: - Size presets
//
// Dial pixel size + corner radius must match the physical panel.
// Thumbnail sizes are what the watch launcher shows in the face picker.

/// Screen / thumbnail geometry for Custom and AI editors.
///
/// `corner` / `thumbCorner` are applied when cropping background / thumbnail bitmaps
/// so round and stadium panels do not leave sharp corners on-device.
struct WatchfaceSizePreset {
    let label: String
    let width: Int
    let height: Int
    let corner: Int
    let thumbW: Int
    let thumbH: Int
    let thumbCorner: Int

    /// Common Sifli panels used by the Custom tab (466 round first).
    static let customDefaults: [WatchfaceSizePreset] = [
        .init(label: "466×466", width: 466, height: 466, corner: 233, thumbW: 264, thumbH: 264, thumbCorner: 132),
        .init(label: "480×480", width: 480, height: 480, corner: 240, thumbW: 264, thumbH: 264, thumbCorner: 132),
        .init(label: "410×502", width: 410, height: 502, corner: 108, thumbW: 200, thumbH: 244, thumbCorner: 50),
    ]

    /// AI tab defaults to **480 first** (matches AiSDK Example / Android AI tab).
    static let aiDefaults: [WatchfaceSizePreset] = [
        .init(label: "480×480", width: 480, height: 480, corner: 240, thumbW: 264, thumbH: 264, thumbCorner: 132),
        .init(label: "466×466", width: 466, height: 466, corner: 233, thumbW: 264, thumbH: 264, thumbCorner: 132),
        .init(label: "410×502", width: 410, height: 502, corner: 108, thumbW: 200, thumbH: 244, thumbCorner: 50),
    ]
}
