import SwiftUI

struct Toast: View {
    let text: String
    @Binding var showToast: Bool
    @Binding var toastShown: Bool
    
    var body: some View {
        Text(text)
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
}
