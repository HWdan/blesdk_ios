
import UIKit

class SequenceImageWidget: ValueWidget {
    var images: [UIImage] = []
    var imagePaths: [String] = []
    var resMode: String = "once"
    var imagePrefix: String = ""
    var resInterval: Int = 80
    var startDelay: Int = 0

    override init() {
        super.init()
        self.dependence = QjsDependence(module: "seqframe", path: "seqframe.js")
    }

    override func start() -> String {
        var sb = ""
        let name = "this.seq" + getJsVarName()
        let pathName = "this.seqpath" + getJsVarName()
        let fontImagePath = "this.path() + \"\(getImagePrefix())\""
        sb += "\n"
        sb += "\t\t\(pathName) = \(fontImagePath);\n"
        sb += "\t\t\(name) = new seqframe(this.root());\n"
        sb += "\t\t\(name).set_pos(\(getLocation().x), \(getLocation().y));\n"
        // 图片前缀
        sb += "\t\t\(name).prefix(\(pathName), \(imagePaths.count));\n"
        // 播放模式
        let mode = getResMode() == "once" ? 2 : 1
        sb += "\t\t\(name).playback_mode(\(mode));\n"
        // 播放延迟
        sb += "\t\t\(name).refresh_open(\(getResInterval()), \(getStartDelay()));\n"
        sb += "\t\t\(name).select(0);\n"
        return sb
    }

    override func pause() -> String {
        let name = "this.seq" + getJsVarName()
        return "\t\t\(name).refresh_pause();\n"
    }

    override func resume() -> String {
        let name = "this.seq" + getJsVarName()
        return "\t\t\(name).refresh_resume();\n"
    }

    func getImages() -> [UIImage] {
        return images
    }

    func setImages(_ images: [UIImage]) {
        self.images = images
    }

    func getImagePaths() -> [String] {
        return imagePaths
    }

    func setImagePaths(_ imagePaths: [String]) {
        self.imagePaths = imagePaths
    }

    func getResMode() -> String {
        return resMode
    }

    func setResMode(_ resMode: String) {
        self.resMode = resMode
    }

    func getImagePrefix() -> String {
        return imagePrefix
    }

    func setImagePrefix(_ imagePrefix: String) {
        self.imagePrefix = imagePrefix
    }

    func getResInterval() -> Int {
        return resInterval
    }

    func setResInterval(_ resInterval: Int) {
        self.resInterval = resInterval
    }

    func getStartDelay() -> Int {
        return startDelay
    }

    func setStartDelay(_ startDelay: Int) {
        self.startDelay = startDelay
    }
    
    override func copy() -> Widget {
        let obj = SequenceImageWidget()
        obj.location = self.location
        obj.size = self.size
        obj.valueType = self.valueType
        obj.images = self.images
        obj.imagePaths = self.imagePaths
        obj.resMode = self.resMode
        obj.imagePrefix = self.imagePrefix
        obj.resInterval = self.resInterval
        obj.startDelay = self.startDelay
        return obj
    }
}
