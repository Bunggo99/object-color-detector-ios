import SwiftUI
import CoreImage
import UIKit

struct CameraView: View {
    @State private var showingImagePicker = false
    @State private var imageSelected = false
    @State private var selectedImage: UIImage? = nil
    
    @StateObject private var model = DataModel()
    
    var body: some View {
        NavigationStack {
            ViewfinderView(image:  $model.viewfinderImage)
                .overlay(alignment: .trailing) {
                    buttonsView()
                        .frame(width: 133)
                        .background(.black.opacity(0.75))
                }
                .background(.black)
                .navigationBarHidden(true)
                .ignoresSafeArea()
                .statusBar(hidden: true)
                .task {
                    await model.camera.start()
                }
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
    
    private func buttonsView() -> some View {
        VStack(spacing: 75) {
            Spacer()
            
            Button {
                showingImagePicker = true
            } label: {
                Label("", systemImage: "photo")
                    .font(.system(size: 43, weight: .bold))
                    .foregroundColor(Color.accentColor)
            }
            
            Button {
                model.camera.takePhoto()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 3)
                        .frame(width: 75, height: 75)
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 60, height: 60)
                }
            }
            
            if(model.camera.availableCaptureDevices.count > 1)
            {
                Button {
                    model.camera.switchCaptureDevice()
                } label: {
                    Label("", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 43, weight: .bold))
                        .foregroundColor(Color.accentColor)
                }
            }
            
            Spacer()   
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
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
}
