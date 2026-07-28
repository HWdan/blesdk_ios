
import Foundation

class ValueWidget: Widget {
    var valueType: Int = -1
    var value: Int = 0

    func getValueType() -> Int {
        return valueType
    }

    func setValueType(_ valueType: Int) {
        self.valueType = valueType
    }

    func getValue() -> Int {
        return value
    }

    func setValue(_ value: Int) {
        self.value = value
    }
    
    override func resume() -> String {
        return ""
    }
    
    override func start() -> String {
        return ""
    }
    
    override func pause() -> String {
        return ""
    }
    
    override func stop() -> String {
        return ""
    }
    
}
