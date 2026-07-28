
import UIKit

class Widget: QjsLifeCycle {
    var name: String = ""
    var namePrefix: String = ""
    var nameSuffix: String = ""
    var location: Point = Point.zero
    var size: Size = Size.zero
    var dependence: QjsDependence?
    var jsVarName: String = ""

    func getName() -> String {
        return name
    }

    func setName(_ name: String) {
        self.name = name
    }

    func getNamePrefix() -> String {
        return namePrefix
    }

    func setNamePrefix(_ namePrefix: String) {
        self.namePrefix = namePrefix
    }

    func getNameSuffix() -> String {
        return nameSuffix
    }

    func setNameSuffix(_ nameSuffix: String) {
        self.nameSuffix = nameSuffix
    }

    func getLocation() -> Point {
        return location
    }

    func setLocation(_ location: Point) {
        self.location = location
    }

    func getSize() -> Size {
        return size
    }

    func setSize(_ size: Size) {
        self.size = size
    }

    func getDependence() -> QjsDependence? {
        return dependence
    }

    func setDependence(_ dependence: QjsDependence) {
        self.dependence = dependence
    }

    func getJsVarName() -> String {
        return jsVarName
    }

    func setJsVarName(_ jsVarName: String) {
        self.jsVarName = jsVarName
    }

    func start() -> String {
        return ""
    }
    
    func refresh() -> String {
        return ""
    }
    
    func resume() -> String {
        return ""
    }
    
    func pause() -> String {
        return ""
    }
    
    func stop() -> String {
        return ""
    }
    
    func toQjs(_ isAOD: Bool) -> String {
        return ""
    }
    
    func copy() -> Widget {
        return Widget()
    }
}
