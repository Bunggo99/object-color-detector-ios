import SwiftUI

struct ImageDisplayView: View {
    @Binding var image: UIImage?
    @Binding var objColor: UIColor?
    @Binding var loadingColorData: Bool
    
    @State private var imageSizeOnDisplay: CGSize = .zero
    @State private var startPosition: CGPoint = .zero
    @State private var endPosition: CGPoint = .zero
    @State private var rectangleSize: CGSize = .zero
    @State private var startedDragging = false
    
    var body: some View {
        Image(uiImage: image!)
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
                    endPosition.x = min(max(endPosition.x, 0), imageSizeOnDisplay.width)
                    endPosition.y = min(max(endPosition.y, 0), imageSizeOnDisplay.height)
                    
                    rectangleSize = CGSize(width: endPosition.x - startPosition.x, height: endPosition.y - startPosition.y)
                }.onEnded { value in
                    detectColor(image: image!)
                }
            ).overlay { 
                Rectangle()
                    .frame(width: abs(rectangleSize.width), height: abs(rectangleSize.height))
                    .position(x: (startPosition.x + endPosition.x)/2.0, y: (startPosition.y + endPosition.y)/2.0)
                    .foregroundColor(.blue)
                    .opacity(0.5)
                    .clipped()
            }
    }
    
    func rectReader() -> some View {
        return GeometryReader { (geometry) -> Color in
            let imageSize = geometry.size
            DispatchQueue.main.async {
                self.imageSizeOnDisplay = imageSize
            }
            return .clear
        }
    }
    
    func detectColor(image: UIImage)
    {
        startedDragging = false
        
        let scaleX = image.size.width / imageSizeOnDisplay.width
        let scaleY = image.size.height / imageSizeOnDisplay.height
        
        let x = min(startPosition.x, endPosition.x)
        let y = min(startPosition.y, endPosition.y)
        let width = abs(endPosition.x - startPosition.x)
        let height = abs(endPosition.y - startPosition.y)
        let cropRect = CGRect(x: x * scaleX, y: y * scaleY, width: width * scaleX, height: height * scaleY)
        
        let orientedImage = image.fixCroppingOrientation()
        let croppedImage = orientedImage.cgImage?.cropping(to: cropRect).flatMap { UIImage(cgImage: $0) }
        
        loadingColorData = true
        DispatchQueue.main.async {
            let averageColor = croppedImage!.preciseAverageColor()!
            objColor = averageColor
            loadingColorData = false
        }
    }
}
