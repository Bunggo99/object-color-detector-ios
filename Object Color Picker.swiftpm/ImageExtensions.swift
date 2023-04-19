import SwiftUI

extension UIImage {
    func preciseAverageColor() -> UIColor? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(self.size.width)
        let imageData = UnsafeMutableRawPointer.allocate(byteCount: Int(self.size.height) * bytesPerRow, alignment: bytesPerPixel)
        defer {
            imageData.deallocate()
        }
        
        let context = CGContext(data: imageData,
                                width: Int(self.size.width),
                                height: Int(self.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.draw(self.cgImage!, in: CGRect(origin: .zero, size: self.size))
        
        var totalR: Double = 0
        var totalG: Double = 0
        var totalB: Double = 0
        
        for y in 0..<Int(self.size.height) {
            for x in 0..<Int(self.size.width) {
                let byteIndex = bytesPerRow * y + bytesPerPixel * x
                let red = Double(imageData.load(fromByteOffset: byteIndex + 0, as: UInt8.self))
                let green = Double(imageData.load(fromByteOffset: byteIndex + 1, as: UInt8.self))
                let blue = Double(imageData.load(fromByteOffset: byteIndex + 2, as: UInt8.self))
                totalR += red
                totalG += green
                totalB += blue
            }
        }
        
        let count = Double(self.size.width * self.size.height)
        let averageR = totalR / count
        let averageG = totalG / count
        let averageB = totalB / count
        
        return UIColor(red: CGFloat(averageR/255.0), green: CGFloat(averageG/255.0), blue: CGFloat(averageB/255.0), alpha: 1.0)
    }
    
    func fixCroppingOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let cgImage = cgImage, let colorSpace = cgImage.colorSpace else {
            return self
        }
        
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
        
        context?.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }
        
        guard let newCGImage = context?.makeImage() else { return self }
        
        return UIImage(cgImage: newCGImage, scale: scale, orientation: .up)
    }
}
