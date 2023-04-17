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
    
    @State private var showToast = false
    @State private var toastShown = false
    @State private var colorValueTypeIdx = 1
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1))
                .ignoresSafeArea()
            VStack {
                if let objColor = objColor {
                    DisplayColorState(objColor: objColor)
                }
                else {
                    EmptyState()
                }
                if let image = selectedImage {
                    ImageComponent(image)
                        .overlay(VStack {
                            if showToast {
                                Spacer()
                                Toast()
                            }
                        })
                }
            }
            .foregroundColor(Color.teal)
        }
        .onDisappear {
            selectedImage = nil
        }
    }
    
    func DisplayColorState(objColor: UIColor) -> some View {
        HStack {
            Circle()
                .foregroundColor(Color(objColor))
                .frame(width: 50, height: 50)
                .padding(.trailing, 4)
            VStack(alignment: .leading) {
                Text("Color: \(objColor.accessibilityName.capitalized)")
                    .font(.title2)
                //Text("Specific Color Name: \(objColorData!.name)")
            }
            .textSelection(.enabled)
            if loadingColor {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(.leading, 4)
            }
        }
        .frame(maxWidth: .infinity)
        
        .overlay(alignment: .trailing, content: {
            HStack(alignment: .top) {
                VStack(alignment: .trailing) {
                    if colorValueTypeIdx == 1 {
                        ValueText(text: "Hex Code: ", value: "#\(objColor.hexString)", brackets: false)
                    }
                    else if colorValueTypeIdx == 2 {
                        ValueText(text: "RGB: ", value: String(
                            format: "%d, %d, %d", 
                            objColor.rgbValues.red, objColor.rgbValues.green, objColor.rgbValues.blue))
                    }
                    else if colorValueTypeIdx == 3 {
                        ValueText(text: "HSV: ", value: String(
                            format: "%d, %d, %d", 
                            objColor.hsvValues.hue, objColor.hsvValues.saturation, objColor.hsvValues.value))
                    }
                    else if colorValueTypeIdx == 4 {
                        ValueText(text: "CMYK: ", value: String(
                            format: "%d, %d, %d, %d", 
                            objColor.cmykValues.cyan, objColor.cmykValues.magenta, 
                            objColor.cmykValues.yellow, objColor.cmykValues.black))
                    }
                }
                Button(action: {
                    colorValueTypeIdx += 1
                    if colorValueTypeIdx > 4 {
                        colorValueTypeIdx = 1
                    }
                }, label: {
                    Image(systemName: "arrow.right.arrow.left.circle")
                })
            }
            .font(.title2)
            .padding(.trailing, 32)
        })
    }
    
    func EmptyState() -> some View {
        HStack {
            Circle()
                .stroke()
                .frame(width: 50, height: 50)
                .padding(.trailing, 4)
            Text("Drag an area on the image to detect the color")
                .font(.title2)
            if loadingColor {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .padding(.leading, 4)
            }
        }
    }
    
    func ValueText(text: String, value: String, brackets: Bool = true) -> some View {
        Text(text + (brackets ? "(" : "") + value +  (brackets ? ")" : ""))
            .onTapGesture {
                UIPasteboard.general.string = value
                if !toastShown {
                    showToast = true
                }
            }
    }
    
    func Toast() -> some View {
        Text("Copied to clipboard!")
            .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
            .foregroundColor(Color(uiColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)))
            .padding()
            .background(Color(uiColor: UIColor(red: 255/255, green: 204/255, blue: 153/255, alpha: 1.0)))
            .cornerRadius(10)
            .onAppear {
                toastShown = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showToast = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    toastShown = false
                }
            }
            .padding(.bottom, 32)
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
                    detectColor(image: image)
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
    
    func detectColor(image: UIImage)
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
    var hsvValues: (hue: Int, saturation: Int, value: Int) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (Int(hue * 360), Int(saturation * 100), Int(brightness * 100))
    }
    
    var cmykValues: (cyan: Int, magenta: Int, yellow: Int, black: Int) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let c = 1.0 - red
        let m = 1.0 - green
        let y = 1.0 - blue
        let k = min(c, min(m, y))
        return (Int(c * 100), Int(m * 100), Int(y * 100), Int(k * 100))
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
