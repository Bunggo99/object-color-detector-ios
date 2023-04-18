import SwiftUI

struct CameraSideButtonsView: View {
    let model: CameraDataModel
    @Binding var showingImagePicker: Bool
    
    var body: some View {
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
    }
}
