
import UIKit

class GifWidget: ValueWidget {
    var gif: URL?
    var gifPreview: UIImage?
    var gifPath: String = ""
    var gifPreviewPath: String = ""

    override init() {
        super.init()
        self.dependence = QjsDependence(module: "gif", path: "gif.js")
    }

    override func start() -> String {
        guard let gif = gif else { return "" }

        var sb = ""
        let name = "this.gif" + getJsVarName()
        let gifSrcName = name + "_src"
        let ffSrcName = name + "_ff_src"

        var path = getGifPath()
        path = path.replacingOccurrences(of: ".gif", with: "")
        path = path.replacingOccurrences(of: ".agif", with: "")
        sb += "\n"
        sb += "\t\tif (lv.get_agif_support()) {\n"
        sb += "\t\t\t\(gifSrcName) = this.path() + \"\(path).agif\";\n"
        sb += "\t\t} else {\n"
        sb += "\t\t\t\(gifSrcName) = this.path() + \"\(path).gif\";\n"
        sb += "\t\t}\n"

        var firstFrameBinPath = getGifPreviewPath()
        firstFrameBinPath = firstFrameBinPath.replacingOccurrences(of: ".png", with: ".bin")
        sb += "\t\t\(ffSrcName) = this.path() + \"\(firstFrameBinPath)\";\n"
        sb += "\n"
        sb += "\t\t\(name) = new gif(this.root());\n"
        sb += "\t\t\(name).anim_open(\(gifSrcName), \(ffSrcName), \(getLocation().x), \(getLocation().y), 0, 80);\n"
        return sb
    }

    override func pause() -> String {
        let name = "this.gif" + getJsVarName()
        return "\t\t\(name).anim_pause();\n"
    }

    override func resume() -> String {
        let name = "this.gif" + getJsVarName()
        return "\t\t\(name).anim_resume();\n"
    }

    override func stop() -> String {
        let name = "this.gif" + getJsVarName()
        return "\t\t\(name).anim_close();\n"
    }

    func getGif() -> URL? {
        return gif
    }

    func setGif(_ gif: URL) {
        self.gif = gif
    }

    func getGifPreview() -> UIImage? {
        return gifPreview
    }

    func setGifPreview(_ gifPreview: UIImage) {
        self.gifPreview = gifPreview
    }

    func getGifPath() -> String {
        return gifPath
    }

    func setGifPath(_ gifPath: String) {
        self.gifPath = gifPath
    }

    func getGifPreviewPath() -> String {
        return gifPreviewPath
    }

    func setGifPreviewPath(_ gifPreviewPath: String) {
        self.gifPreviewPath = gifPreviewPath
    }
    
    override func copy() -> Widget {
        let obj = GifWidget()
        obj.location = self.location
        obj.size = self.size
        obj.valueType = self.valueType
        obj.gif = self.gif
        obj.gifPreview = self.gifPreview
        obj.gifPath = self.gifPath
        obj.gifPreviewPath = self.gifPreviewPath
        
        return obj
    }
}
