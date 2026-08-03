import UIKit

/// Image helpers for Custom watchface background / thumbnail preparation.
///
/// # Why these exist
/// Sifli custom dials expect bitmaps at the **exact panel size** (and thumbnail size).
/// Widgets also require a tint color with **no alpha** (`tint >= 0` gate inside the SDK).
///
/// # Caveats
/// - Renderers use `scale = 1` so pixel dimensions match the numeric width/height
///   passed into `SlifiCustomWatchface` (not multiplied by screen scale).
/// - Corner radius should match the panel shape (round ≈ half of side length).
enum WatchfaceImageUtils {
    /// Center-crop / scale to `size`, then apply a corner-radius mask.
    ///
    /// Used for custom face `backgroundImage` and as a thumbnail fallback when
    /// view snapshot fails.
    static func scaledRoundedBitmap(_ image: UIImage, size: CGSize, cornerRadius: CGFloat) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
            path.addClip()
            let imgSize = image.size
            guard imgSize.width > 0, imgSize.height > 0 else { return }
            let scale = max(size.width / imgSize.width, size.height / imgSize.height)
            let drawSize = CGSize(width: imgSize.width * scale, height: imgSize.height * scale)
            let origin = CGPoint(x: (size.width - drawSize.width) / 2, y: (size.height - drawSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: drawSize))
        }
    }

    /// Snapshots a live preview view into a bitmap for `thumbnailImage`.
    ///
    /// Prefer this over a plain background crop so the thumbnail shows widgets
    /// roughly as the editor preview does.
    static func snapshot(_ view: UIView, size: CGSize, cornerRadius: CGFloat) -> UIImage? {
        guard size.width > 0, size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
            path.addClip()
            let scaleX = size.width / max(view.bounds.width, 1)
            let scaleY = size.height / max(view.bounds.height, 1)
            ctx.cgContext.scaleBy(x: scaleX, y: scaleY)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }

    /// Forces RGB with alpha = 1 for Sifli widget tint (`tint >= 0` gate).
    ///
    /// Passing a color with alpha < 1 can make widgets invisible / rejected.
    static func rgbTint(_ color: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
