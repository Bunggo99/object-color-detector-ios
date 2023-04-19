import SwiftUI

struct ColorDisplayView: View {
    let emptyState: Bool
    let loadingColorData: Bool
    let toastShown: Bool
    @Binding var showToast: Bool
    @Binding var objColor: UIColor?
    
    var body: some View {
        HStack {
            Circle()
                .fill(emptyState ? .clear : Color(objColor!))
                .overlay(
                    Circle().stroke(emptyState ? .teal : .clear, lineWidth: 1)
                )
                .frame(width: 50, height: 50)
                .padding(.trailing, 4)
            Text(emptyState ? 
                 "Drag on an area to detect the color" :
                 "Color: \(objColor!.accessibilityName.capitalized)")
                .font(.title2)
                .textSelection(.enabled)
            if loadingColorData {
                LoadingView()
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing, content: {
            if !emptyState, let objColor = objColor  {
                ColorValuesDisplayView(objColor: objColor, 
                                       toastShown: toastShown, 
                                       showToast: $showToast)
            }
        })
    }
}
