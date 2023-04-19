import SwiftUI

@main
struct ObjectColorPickerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                IntroPageView(intros: intros, pageIndex: 0)
            }
        }
    }
}
