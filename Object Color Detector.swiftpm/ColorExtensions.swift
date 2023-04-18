import SwiftUI

extension UIColor {
    var hexString: String {
        let components = self.cgColor.components!
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let hexString = String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        return hexString
    }
    var rgbValues: (red: Int, green: Int, blue: Int) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    var hsvValues: (hue: Int, saturation: Int, value: Int) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (Int(hue * 360), Int(saturation * 100), Int(brightness * 100))
    }
    
    var cmykValues: (cyan: Int, magenta: Int, yellow: Int, black: Int) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let c = 1.0 - red
        let m = 1.0 - green
        let y = 1.0 - blue
        let k = min(c, min(m, y))
        return (Int(c * 100), Int(m * 100), Int(y * 100), Int(k * 100))
    }
}
