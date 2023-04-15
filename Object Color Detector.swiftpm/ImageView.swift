
import SwiftUI
import CoreImage

struct ImageView: View {
    @Binding var selectedImage: UIImage?
    @State private var imageSize: CGSize = .zero
    
    @State private var objColor: UIColor?
    @State private var objColorData: ColorData?
    @State private var loadingColor = false
    
    @State private var startPosition: CGPoint = .zero
    @State private var endPosition: CGPoint = .zero
    @State private var rectSize: CGSize = .zero
    @State private var startedDragging = false
    
    var body: some View {
        ZStack {
            Color(.systemGray).ignoresSafeArea()
            VStack {
                if let objColor = objColor {
                    HStack {
                        Circle()
                            .foregroundColor(Color(objColor))
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("Descriptive Color Name: \(objColor.accessibilityName)")
                            Text("Specific Color Name: \(objColorData!.name)")
                        }
                        if loadingColor {
                            ProgressView()
                                .padding(.leading, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing, content: {
                        VStack(alignment: .trailing) {
                            Text("Hex Code: #\(objColor.hexString)")
                            HStack {
                                Text("R: \(objColor.rgbValues.red), ")
                                Text("G: \(objColor.rgbValues.green), ")
                                Text("B: \(objColor.rgbValues.blue)")
                            }
                        }.padding(.trailing, 32)
                    })
                }
                else {
                    HStack {
                        Circle()
                            .stroke()
                            .frame(width: 50, height: 50)
                        Text("Drag an area on the image to detect the color")
                        if loadingColor {
                            ProgressView()
                                .padding(.leading, 4)
                        }
                    }
                }
                if let image = selectedImage {
                    ImageComponent(image)
                }
            }
        }
        .onDisappear(perform: {
            selectedImage = nil
        })
    }
    
    func ImageComponent(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(rectReader())
            .gesture(DragGesture()
                .onChanged { value in
                    if(!startedDragging)
                    {
                        startedDragging = true
                        startPosition = CGPoint(x: value.startLocation.x, y: value.startLocation.y)
                    }
                    
                    endPosition =  CGPoint(x: value.location.x, y: value.location.y)
                    endPosition.x = min(max(endPosition.x, 0), imageSize.width)
                    endPosition.y = min(max(endPosition.y, 0), imageSize.height)
                    
                    rectSize = CGSize(width: endPosition.x - startPosition.x, height: endPosition.y - startPosition.y)
                }.onEnded { value in
                    DetectColor(image: image)
                }
            ).overlay { 
                Rectangle()
                    .frame(width: abs(rectSize.width), height: abs(rectSize.height))
                    .position(x: (startPosition.x + endPosition.x)/2.0, y: (startPosition.y + endPosition.y)/2.0)
                    .foregroundColor(.blue)
                    .opacity(0.5)
                    .clipped()
            }
    }
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> Color in
            let imageSize = geometry.size
            DispatchQueue.main.async {
                self.imageSize = imageSize
            }
            return .clear
        }
    }
    
    func DetectColor(image: UIImage)
    {
        startedDragging = false
        
        let scaleX = image.size.width / imageSize.width
        let scaleY = image.size.height / imageSize.height
        
        let x = min(startPosition.x, endPosition.x)
        let y = min(startPosition.y, endPosition.y)
        let width = abs(endPosition.x - startPosition.x)
        let height = abs(endPosition.y - startPosition.y)
        let cropRect = CGRect(x: x * scaleX, y: y * scaleY, width: width * scaleX, height: height * scaleY)
        
        let orientedImage = image.fixOrientation()
        let croppedImage = orientedImage.cgImage?.cropping(to: cropRect).flatMap { UIImage(cgImage: $0) }
        
        loadingColor = true
        DispatchQueue.main.async {
            let averageColor = preciseAverageColor(in: croppedImage!)!
            objColor = averageColor
            
            objColorData = ColorHelpers.GetColorName(red: Int(averageColor.rgbValues.red), green: Int(averageColor.rgbValues.green), blue: Int(averageColor.rgbValues.blue))
            loadingColor = false
        }
    }
    
    func preciseAverageColor(in image: UIImage) -> UIColor? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(image.size.width)
        let imageData = UnsafeMutableRawPointer.allocate(byteCount: Int(image.size.height) * bytesPerRow, alignment: bytesPerPixel)
        defer {
            imageData.deallocate()
        }
        
        let context = CGContext(data: imageData,
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        
        var totalR: Double = 0
        var totalG: Double = 0
        var totalB: Double = 0
        
        for y in 0..<Int(image.size.height) {
            for x in 0..<Int(image.size.width) {
                let byteIndex = bytesPerRow * y + bytesPerPixel * x
                let red = Double(imageData.load(fromByteOffset: byteIndex + 0, as: UInt8.self))
                let green = Double(imageData.load(fromByteOffset: byteIndex + 1, as: UInt8.self))
                let blue = Double(imageData.load(fromByteOffset: byteIndex + 2, as: UInt8.self))
                totalR += red
                totalG += green
                totalB += blue
            }
        }
        
        let count = Double(image.size.width * image.size.height)
        let averageR = totalR / count
        let averageG = totalG / count
        let averageB = totalB / count
        
        return UIColor(red: CGFloat(averageR/255.0), green: CGFloat(averageG/255.0), blue: CGFloat(averageB/255.0), alpha: 1.0)
    }
}
extension UIColor {
    var hexString: String {
        let components = self.cgColor.components!
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let hexString = String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        return hexString
    }
    var rgbValues: (red: Int, green: Int, blue: Int) {
        return ColorHelpers.hexToRGB(hex: self.hexString)!
    }
}
extension UIImage {
    func fixOrientation() -> UIImage {
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
