import SwiftUI

struct ViewfinderView: View {
    @Binding var image: Image?
    
    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
