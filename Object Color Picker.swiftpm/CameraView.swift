import SwiftUI
import CoreImage
import UIKit

struct CameraView: View {
    @StateObject private var model = CameraDataModel()
    
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var imageSelected = false
    
    var body: some View {
        ViewfinderView(image:  $model.viewfinderImage)
            .overlay(alignment: .trailing) {
                CameraSideButtonsView(model: model, showingImagePicker: $showingImagePicker)
                    .frame(width: 133)
                    .background(.black.opacity(0.75))
                    .navigationDestination(isPresented: $imageSelected) {
                        ImageView(selectedImage: $selectedImage)
                            .onAppear {
                                model.camera.isPreviewPaused = true
                            }
                            .onDisappear {
                                model.camera.isPreviewPaused = false
                                imageSelected = false
                                selectedImage = nil
                                model.takenImage = nil
                            }
                    }
            }
            .background(.black)
//            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
            .task {
                await model.camera.start()
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: { 
                imageSelected = selectedImage != nil
            }) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: model.takenImage) { takenImage in
                if takenImage != nil {
                    selectedImage = takenImage
                    imageSelected = true
                }
            }
    }
}
