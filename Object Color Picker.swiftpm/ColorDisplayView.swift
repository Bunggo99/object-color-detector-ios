import SwiftUI

struct ColorDisplayView: View {
    let emptyState: Bool
    let loadingColorData: Bool
    let toastShown: Bool
    @Binding var showToast: Bool
    @Binding var objColor: UIColor?
    
    var body: some View {
        ZStack {
            HStack {
                    Circle()
                        .fill(emptyState ? .clear : Color(objColor!))
                        .overlay(
                            Circle().stroke(.teal, lineWidth: 1)
                        )
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 4)
                    Text(emptyState ? 
                         "Drag on an area to detect the color" :
                            "Selected Color: \(objColor!.accessibilityName.capitalized)")
                    .font(.title2)
                    .textSelection(.enabled)
                    .bold()
                    if loadingColorData {
                        LoadingView()
                    }
                if !emptyState, let objColor = objColor  {
                    Divider()
                        .frame(height: CGFloat(UIFont.preferredFont(forTextStyle: .title2).pointSize))
                        .padding(.horizontal)
                    ColorValuesDisplayView(objColor: objColor, 
                                           toastShown: toastShown, 
                                           showToast: $showToast)
                }
            }
            .padding()
            .padding(.horizontal, 8)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
        }
//        .frame(maxWidth: .infinity)
//        .overlay(alignment: .trailing, content: {
//            if !emptyState, let objColor = objColor  {
//                ColorValuesDisplayView(objColor: objColor, 
//                                       toastShown: toastShown, 
//                                       showToast: $showToast)
//            }
//        })
    }
}
