
import UIKit

class OptionWidget: ValueWidget {
    var images: [String: UIImage] = [:]
    var imagePaths: [String] = []
    var maxCount: Int = 0
    var imagePrefix: String = ""

    override init() {
        super.init()
        self.dependence = QjsDependence(module: "idximg", path: "idximg.js")
    }

    override func start() -> String {
        var sb = ""
        let name = "this.option" + getJsVarName()
        // 创建
        sb += "\n"
        sb += "\t\t\(name) = new idximg(this.root());\n"
        sb += "\t\t\(name).set_pos(\(getLocation().x), \(getLocation().y));\n"
        sb += "\t\t\(name).prefix(this.path() + \"\(getImagePrefix())\");\n"

        if getValueType() >= 0 {
            // 绑定数据
            let index_name = "this.pe_" + getJsVarName()
            // 初始化值
            sb += "\t\t\(index_name) = lv.app_db_get_val_enum(\(getValueType()));\n"
            sb += "\t\t\(name).select(\(index_name));\n"
            // 绑定数据
            sb += "\t\t\(name).bind(\(getValueType()), function(idx, val) {\n"
            sb += "\t\t\t\(index_name) = lv.app_db_get_val_enum(\(getValueType()));\n"
            sb += "\t\t\tthis.select(\(index_name));\n"
            sb += "\t\t});\n"
        }
        return sb
    }

    override func resume() -> String {
        var sb = ""
        let name = "this.option" + getJsVarName()
        let index_name = "this.pe_" + getJsVarName()
        // 初始化值
        sb += "\t\t\(index_name) = lv.app_db_get_val_enum(\(getValueType()));\n"
        sb += "\t\t\(name).select(\(index_name));\n"
        return sb
    }

    func getImages() -> [String: UIImage] {
        return images
    }

    func setImages(_ images: [String: UIImage]) {
        self.images = images
    }

    func getImagePaths() -> [String] {
        return imagePaths
    }

    func setImagePaths(_ imagePaths: [String]) {
        self.imagePaths = imagePaths
    }

    func getMaxCount() -> Int {
        return maxCount
    }

    func setMaxCount(_ maxCount: Int) {
        self.maxCount = maxCount
    }

    func getImagePrefix() -> String {
        return imagePrefix
    }

    func setImagePrefix(_ imagePrefix: String) {
        self.imagePrefix = imagePrefix
    }
    
    override func copy() -> Widget {
        let obj = OptionWidget()
        obj.location = self.location
        obj.size = self.size
        obj.valueType = self.valueType
        obj.imagePrefix = self.imagePrefix
        obj.images = self.images
        obj.imagePaths = self.imagePaths
        obj.maxCount = self.maxCount
        return obj
    }
}
