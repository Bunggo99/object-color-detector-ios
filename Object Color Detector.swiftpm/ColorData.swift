import SwiftUI

struct ColorData {
    var hex: String
    var name: String
    var r = 0
    var g = 0
    var b = 0
    
    init(_ hex: String,_ name: String) {
        self.hex = hex
        self.name = name
        let rgb = ColorHelpers.hexToRGB(hex: hex)!
        r = rgb.red
        g = rgb.green
        b = rgb.blue
    }
    
    func proximityValue(r: Int, g: Int, b: Int) -> Int {
        return abs(self.r - r) + abs(self.g - g) + abs(self.b - b)
    }
}

struct ColorHelpers {
    static func hexToRGB(hex: String) -> (red: Int, green: Int, blue: Int)? {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let red = Int((hexNumber & 0xff0000) >> 16)
            let green = Int((hexNumber & 0x00ff00) >> 8)
            let blue = Int(hexNumber & 0x0000ff)
            
            return (red, green, blue)
        }
        
        return nil
    }
    static func GetColorName(red: Int, green: Int, blue: Int) -> ColorData
    {
        var minDistance = -1
        var closestColor = ColorList.colors[0]
        for color in ColorList.colors
        {
            let distance = color.proximityValue(r: red, g: green, b: blue)
            if (minDistance == -1 || distance < minDistance)
            {
                minDistance = distance
                closestColor = color
            }
        }
        
        return closestColor
    }
}
