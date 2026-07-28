import Foundation

final class BoundDeviceStore {
    static let shared = BoundDeviceStore()
    private let key = "blesdkdemo.bound.device"
    private let defaults = UserDefaults.standard

    func load() -> BoundDeviceRecord? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(BoundDeviceRecord.self, from: data)
    }

    func save(_ record: BoundDeviceRecord) {
        if let data = try? JSONEncoder().encode(record) {
            defaults.set(data, forKey: key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
