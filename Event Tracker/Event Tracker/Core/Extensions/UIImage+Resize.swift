import UIKit

extension UIImage {
    func resized(toMax dimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > dimension else { return self }

        let scale = dimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

