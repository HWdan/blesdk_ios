
import UIKit

@objc public class QjsPointerWidget: QjsWidget {
    var center = Point.zero
    var rotationCenter = Point.zero
    var image: UIImage?
    
    public init(watchfaceSize: Size) {
        super.init()
        self.center = Point(x: watchfaceSize.width / 2, y: watchfaceSize.height / 2)
    }
    
    func setImage(_ image: UIImage) {
        self.image = image
    }

    func getCenter() -> Point {
        return center
    }

    func setCenter(_ center: Point) {
        self.center = center
    }

    func getImage() -> UIImage? {
        return image
    }

    func getRotationCenter() -> Point {
        return rotationCenter
    }
}
