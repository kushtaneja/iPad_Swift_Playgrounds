//
//  Color.swift
//  Shapes
//

import UIKit

/// A color that can be used to change how objects on your canvas draw.
///
/// Choose specific colors, such as orange, or create your own colors by specifying the red, green, blue, and alpha (transparency) values.
///
/// Methods for modifying colors include:
/// - `lighter(percent: Double)`: Lighten a color
/// - `darker(percent: Double)`: Darken a color
/// - `withAlpha(percent: Double)`: Set the alpha (transparency) of a color
/// - `random()`: Pick a random color
public class Color: _ExpressibleByColorLiteral, Equatable {
    
    internal let uiColor: UIColor
    
    internal var cgColor: CGColor {
        return uiColor.cgColor
    }
    
    public static let clear:Color = #colorLiteral(red: 1, green: 0.9999743700027466, blue: 0.9999912977218628, alpha: 0)
    
    public static let white:Color = #colorLiteral(red: 1, green: 0.9999743700027466, blue: 0.9999912977218628, alpha: 1)
    public static let gray:Color = #colorLiteral(red: 0.5882352941176471, green: 0.6039215686274509, blue: 0.6, alpha: 1)
    public static let black:Color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    public static let orange:Color = #colorLiteral(red: 0.8941176470588236, green: 0.4705882352941176, blue: 0.08627450980392157, alpha: 1)
    public static let blue:Color = #colorLiteral(red: 0.2627450980392157, green: 0.5803921568627451, blue: 0.9686274509803922, alpha: 1)
    public static let green:Color = #colorLiteral(red: 0.3725490196078431, green: 0.7176470588235294, blue: 0.196078431372549, alpha: 1)
    public static let yellow:Color = #colorLiteral(red: 0.9490196078431372, green: 0.8, blue: 0.1215686274509804, alpha: 1)
    public static let red:Color = #colorLiteral(red: 0.7294117647058823, green: 0.07058823529411765, blue: 0.0392156862745098, alpha: 1)
    public static let purple:Color = #colorLiteral(red: 0.3843137254901961, green: 0.1607843137254902, blue: 0.5372549019607843, alpha: 1)
    
    public init(white: CGFloat, alpha: CGFloat = 1.0) {
        uiColor = UIColor(white: white, alpha: alpha)
    }
    
    public init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
        uiColor = UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: CGFloat(alpha))
    }
    
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        uiColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    internal init(uiColor: UIColor) {
        self.uiColor = uiColor
    }
    
    public required convenience init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        self.init(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
 
    /// Creates a new, lighter color
    ///
    /// `percent` A percentage value to lighten the color. Specify a number from `0.0` to `1.0`.
    public func lighter(percent: Double = 0.2) -> Color {
        return withBrightness(percent: 1 + percent)
    }
    
    /// Creates a new Color with the given transparency.
    ///
    /// `alpha` A percentage value for the transparency of the new Color. Specify a number from `0.0` to `1.0`.
    ///   - 0.0 is completely transparent, and so is invisible.
    ///   - 1.0 is completely opaque.
    public func withAlpha(alpha: Double) -> Color {
        return Color(uiColor: uiColor.withAlphaComponent(CGFloat(alpha)))
    }
    
    /// Creates a new, darker color.
    ///
    /// `percent` A percentage value to darken the color. Specify a number from `0.0` to `1.0`.
    public func darker(percent: Double = 0.2) -> Color {
        return withBrightness(percent: 1 - percent)
    }
    
    /// Creates a new Color with the given brightness.
    ///
    /// `percent` A percentage value to brighten the color. Specify a number from `0.0` to `1.0`.
    ///   - `0.0` is the darkest setting
    ///   - `1.0` is the brightest setting
    private func withBrightness(percent: Double) -> Color {
        var cappedPercent = min(percent, 1.0)
        cappedPercent = max(0.0, percent)
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(brightness) * cappedPercent, alpha: Double(alpha))
    }
    
    /// Pick a random color.
    ///
    /// An opaque color with random red, green and blue values will be selected.
    public static func random() -> Color {
        let uint32MaxAsFloat = Float(UInt32.max)
        let red = Double(Float(arc4random()) / uint32MaxAsFloat)
        let blue = Double(Float(arc4random()) / uint32MaxAsFloat)
        let green = Double(Float(arc4random()) / uint32MaxAsFloat)
        
        return Color(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

public typealias _ColorLiteralType = Color

public func ==(left: Color, right: Color) -> Bool {
    return left.uiColor == right.uiColor
}

extension Color: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .color(uiColor)
        }
    }
}
