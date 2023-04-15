import SwiftUI
import CoreImage
import UIKit

struct CameraView: View {
    @State private var showingImagePicker = false
    @State private var imageSelected = false
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo.artframe")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .navigationDestination(isPresented: $imageSelected) {
                        ImageView(selectedImage: $selectedImage)
                    }.offset(y: -100)
                    Button {
                        
                    } label: {
                        Image(systemName: "circle.inset.filled")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .padding(32)
        .sheet(isPresented: $showingImagePicker, onDismiss: { 
            imageSelected = selectedImage != nil
        }) {
            ImagePicker(image: $selectedImage)
        }
    }
}
