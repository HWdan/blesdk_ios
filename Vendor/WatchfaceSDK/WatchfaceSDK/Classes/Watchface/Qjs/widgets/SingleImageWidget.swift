
import UIKit

class SingleImageWidget: ValueWidget {
    var image: UIImage?
    var linkToApp: Int = 0
    var imagePath: String = ""
    
    override init() {
        super.init()
        self.dependence = QjsDependence(module: "img", path: "img.js")
    }
    
    @objc dynamic override func start() -> String {
        var sb = ""
        let name = "this.img" + getJsVarName()
        var binPath = getImagePath()
        binPath = binPath.replacingOccurrences(of: ".png", with: ".bin")
        let path = "this.path() + \"\(binPath)\""
        
        sb += "\n"
        sb += "\t\t\(name) = new img(this.root());\n"
        sb += "\t\t\(name).set_src(\(path));\n"
        sb += "\t\t\(name).set_pos(\(getLocation().x), \(getLocation().y));\n"
        
        return sb
    }
    
    func getImage() -> UIImage? {
        return image
    }
    
    func setImage(_ image: UIImage) {
        self.image = image
    }
    
    func getLinkToApp() -> Int {
        return linkToApp
    }
    
    func setLinkToApp(_ linkToApp: Int) {
        self.linkToApp = linkToApp
    }
    
    func getImagePath() -> String {
        return imagePath
    }
    
    func setImagePath(_ imagePath: String) {
        self.imagePath = imagePath
    }

    override func copy() -> Widget {
        let obj = SingleImageWidget()
        obj.location = self.location
        obj.size = self.size
        obj.valueType = self.valueType
        obj.image = self.image
        obj.imagePath = self.imagePath
        return obj
    }
}
