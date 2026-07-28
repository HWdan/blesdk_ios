import Foundation

@objc protocol QjsLifeCycle: Qjs {
    func start() -> String
    func refresh() -> String
    func resume() -> String
    func pause() -> String
    func stop() -> String
}
