import SwiftUI

struct IntroPageModel {
    var title: String = ""
    var text: String = ""
    var emojis: [String] = []
    let buttonText: String
    let destination: Int
}

let intros = [
    IntroPageModel(title: "A Simple Riddle", text: "Last week, an app based driver was asking for the color of my shirt so he could easily find me, but I can't really answer him. Can you guess why?", emojis: ["🚗", "👕", "🤔"], buttonText: "Reveal Answer", destination: 1),
    IntroPageModel(title: "I'm partially colorblind, so I couldn't say for sure what the color of my shirt was!", emojis: ["🎨", "👕", "👀"], buttonText: "Continue", destination: 2),
    IntroPageModel(title: "I always have trouble recognizing colors, and that's why I made this app", text: "Object Color Picker is an accessibility app designed to help colorblind users on recognizing colors.\n\nJust take a picture from your surroundings or from your device gallery, select an area to detect, and boom! the app will tell you about it's color.\n\nColor codes such as hex, rgb, and hsv will also be displayed and can be copied to the clipboard as well.", emojis: ["🌈", "👁️‍🗨️", "📱"], buttonText: "Let's try it out!", destination: 3)
]
