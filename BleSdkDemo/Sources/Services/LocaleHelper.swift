import Foundation

enum AppLanguage: String, CaseIterable {
    case system
    case zh
    case en

    var displayName: String {
        switch self {
        case .system: return L10n.tr("language_system")
        case .zh: return L10n.tr("language_zh")
        case .en: return L10n.tr("language_en")
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system: return nil
        case .zh: return "zh-Hans"
        case .en: return "en"
        }
    }
}

enum LocaleHelper {
    private static let key = "app_language"
    private static var bundleOverride: Bundle?

    static var current: AppLanguage {
        get { AppLanguage(rawValue: UserDefaults.standard.string(forKey: key) ?? "") ?? .system }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            apply(newValue)
        }
    }

    static var bundle: Bundle { bundleOverride ?? .main }

    static func apply(_ language: AppLanguage = current) {
        if let id = language.localeIdentifier,
           let path = Bundle.main.path(forResource: id, ofType: "lproj"),
           let b = Bundle(path: path) {
            bundleOverride = b
        } else {
            bundleOverride = nil
        }
    }
}

enum L10n {
    static func tr(_ key: String) -> String {
        LocaleHelper.bundle.localizedString(forKey: key, value: key, table: nil)
    }

    static func tr(_ key: String, _ args: CVarArg...) -> String {
        String(format: tr(key), locale: Locale.current, arguments: args)
    }
}
