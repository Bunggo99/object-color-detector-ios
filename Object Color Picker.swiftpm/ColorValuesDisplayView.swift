import SwiftUI

struct ColorValuesDisplayView: View {
    let objColor: UIColor
    let toastShown: Bool
    @Binding var showToast: Bool
    
    @State private var colorValueTypeIdx = 0
    let colorTypes = ["Hex Code", "RGB", "HSV", "CMYK"]
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .trailing) {
                if colorValueTypeIdx == 0 {
                    ValueText(text: "Hex Code: ", value: "#\(objColor.hexString)", brackets: false)
                }
                else if colorValueTypeIdx == 1 {
                    ValueText(text: "RGB: ", value: String(
                        format: "%d, %d, %d", 
                        objColor.rgbValues.red, objColor.rgbValues.green, objColor.rgbValues.blue))
                }
                else if colorValueTypeIdx == 2 {
                    ValueText(text: "HSV: ", value: String(
                        format: "%d, %d, %d", 
                        objColor.hsvValues.hue, objColor.hsvValues.saturation, objColor.hsvValues.value))
                }
                else if colorValueTypeIdx == 3 {
                    ValueText(text: "CMYK: ", value: String(
                        format: "%d, %d, %d, %d", 
                        objColor.cmykValues.cyan, objColor.cmykValues.magenta, 
                        objColor.cmykValues.yellow, objColor.cmykValues.black))
                }
            }
            
            Menu {
                ForEach(0..<4, id: \.self) { idx in
                    Button(action: {
                        colorValueTypeIdx = idx
                    }) {
                        Text(colorTypes[idx])
                    }
                }
            } label: {
                Image(systemName: "chevron.down.circle")
                    .font(.title)
            }
            .menuStyle(DefaultMenuStyle())
        }
        .font(.title2)
        .padding(.trailing, 32)
    }
    
    func ValueText(text: String, value: String, brackets: Bool = true) -> some View {
        HStack {
            Image(systemName: "doc.on.doc")
            Text(text + (brackets ? "(" : "") + value +  (brackets ? ")" : ""))
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = value
                        if !toastShown {
                            showToast = true
                        }
                    }) {
                        Text("Copy")
                    }
                }
        }
        .onTapGesture {
            UIPasteboard.general.string = value
            if !toastShown {
                showToast = true
            }
        }
    }
}
