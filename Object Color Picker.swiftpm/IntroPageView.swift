import SwiftUI

struct IntroPageView: View {
    let intros: [IntroPageModel]
    let pageIndex: Int
    
    var body: some View {
        if pageIndex < intros.count
        {
            VStack {
                if intros[pageIndex].title != "" {
                    Text(intros[pageIndex].title)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                
                if intros[pageIndex].emojis.count > 0 {
                    HStack {
                        ForEach(intros[pageIndex].emojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 60))
                        }
                    }
                    .padding()
                }
                
                if intros[pageIndex].text != "" {
                    Text(intros[pageIndex].text)
                        .font(.headline)
                        .padding()
                }
                
                NavigationLink(destination: IntroPageView(intros: intros, pageIndex: intros[pageIndex].destination)) {
                    Text(intros[pageIndex].buttonText)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 16)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width/2)
            .padding()
        }
        else {
            CameraView()
        }
    }
}
