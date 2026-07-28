
import UIKit

@objc public class QjsDotWidget: QjsWidget {
    var center: CGPoint?
    var image: UIImage?

    public override init() {
        super.init()
    }

    @objc public init(tintColor: UIColor) {
        super.init()
        self.tintColor = tintColor
    }

    override func qjsWidgets() -> [Widget] {
        let imageName = "pointer_center.png"
        
        guard let bitmap = UIImage.loadImage(named: imageName) else {
            return []
        }
        
        // Change color
        if getTintColor() != nil {
            self.image = QjsFileUtils.changeBitmapColor(originalBitmap: bitmap, color: getTintColor()!)
        } else {
            self.image = bitmap
        }

        var widgetList: [Widget] = []

        let imageWidget = SingleImageWidget()
        if let center = center, let image = image {
            let x = Int(center.x - image.size.width / 2)
            let y = Int(center.y - image.size.height / 2)
            imageWidget.setLocation(Point(x: x, y: y))
            imageWidget.setSize(Size(width: Int(image.size.width), height: Int(image.size.height)))
            imageWidget.setImage(image)
            widgetList.append(imageWidget)
        }

        return widgetList
    }

    func setImage(_ image: UIImage) {
        self.image = image
    }

    func getCenter() -> CGPoint? {
        return center
    }

    func setCenter(_ center: CGPoint) {
        self.center = center
    }

    func getImage() -> UIImage? {
        return image
    }
}
