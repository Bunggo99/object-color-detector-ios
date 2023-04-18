import SwiftUI
import CoreImage

struct ImageView: View {
    @Binding var selectedImage: UIImage?
    
    @State private var objColor: UIColor?
    @State private var loadingColorData = false
    
    @State private var showToast = false
    @State private var toastShown = false
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1))
                .ignoresSafeArea()
            VStack {
                ColorDisplayView(emptyState: objColor == nil, 
                                 loadingColorData: loadingColorData, 
                                 toastShown: toastShown, showToast: $showToast, 
                                 objColor: $objColor)
                if selectedImage != nil {
                    ImageDisplayView(image: $selectedImage, 
                                     objColor: $objColor, 
                                     loadingColorData: $loadingColorData)
                    .overlay(VStack {
                        if showToast {
                            Spacer()
                            Toast(text: "Copied to clipboard!", 
                                  showToast: $showToast, toastShown: $toastShown)
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
}
