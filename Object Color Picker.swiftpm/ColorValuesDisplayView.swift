import SwiftUI

struct ColorValuesDisplayView: View {
    let objColor: UIColor
    let toastShown: Bool
    @Binding var showToast: Bool
    
    @State private var colorValueTypeIdx = 1
    
    var body: some View {
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
}
