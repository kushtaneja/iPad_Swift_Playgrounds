//
//  Text.swift
//  Shapes
//

import UIKit

private let DefaultFontSize = 17.0

/// Text on the canvas.
///
///   - `color` The color to draw the text. The default value is black.
///   - `fontSize` The size in points to draw the text. The default value is 17.0.
///   - `fontName` The font name to draw the text with. The default value is the system font.
///
/// Additional properties that can affect the Text:
///
///   - `center`: The center point of the object. Changing this moves the object.
///   - `scale`: The amount to grow or shrink the object. A value of 1.0 is the natural (unscaled) size. A value of 0.5 would be 1/2 the orginal size, while a value of 2.0 would be twice the original size.
///   - `rotation`: The angle in radians to rotate this object. Changing this rotates the object counter clockwise about it's center. A value of 0.0 (the default) means no rotation. A value of π (3.14159…) will rotate the object 180°, and 2π will rotate a full 360°.
///   - `draggable`: Makes the object draggable with your finger on the canvas. The default value is false.
///   - `shadow`: The drop shadow for this object. The default is nil, which results in no shadow. To add a shadow, you can set this property, like this: `myObject.dropShadow = Shadow()`.
public class Text: AbstractDrawable {
    
    private var backingViewAsLabel: UILabel {
        return backingView as! UILabel
    }
    
    /// The string to draw the text.
    public var string: String {
        get {
            return backingViewAsLabel.text ?? ""
        }
        set {
            backingViewAsLabel.text = newValue
            udpateBackingViewSizeFromFont()
        }
    }
    
    /// The color to draw the text. The default value is black.
    public var color: Color {
        get {
            return Color(uiColor: backingViewAsLabel.textColor)
        }
        set {
            backingViewAsLabel.textColor = newValue.uiColor
        }
    }
    
    /// The size, in points, to draw the text. The default value is 17.0.
    public var fontSize: Double {
        get {
            return Double(backingViewAsLabel.font.pointSize)
        }
        set {
            backingViewAsLabel.font = backingViewAsLabel.font.withSize(CGFloat(newValue))
            udpateBackingViewSizeFromFont()
        }
    }
    
    /// The font name to draw the text with. The default value is the system font.
    public var fontName: String {
        get {
            return backingViewAsLabel.font.fontName
        }
        set {
            if let font = UIFont.init(name: newValue, size: CGFloat(fontSize)) {
                backingViewAsLabel.font = font
                udpateBackingViewSizeFromFont()
            }
        }
    }
    
    /// Creates text centered on the canvas.
    ///
    ///   - `string` The string content to draw.
    ///   - `fontSize` The size in points to draw the text. The default value is 17.0.
    ///   - `fontName` The font name to draw the text with. The default value is the system font.
    ///   - `color` The color to draw the text. The default value is black.
    public init(string: String, fontSize: Double = DefaultFontSize, fontName: String = "", color: Color = .black) {
        
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.text = string
        label.textColor = color.uiColor
        if let font = UIFont.init(name: fontName, size: CGFloat(fontSize)) {
            label.font = font
        } else {
            label.font = label.font.withSize(CGFloat(fontSize))
        }
        
        // we'll update our size below as a result of calling udpateBackingViewSizeFromFont().
        super.init(modelSize: Size(width: 0, height: 0), backingView: label)
        
        udpateBackingViewSizeFromFont()
    }
    
    private func udpateBackingViewSizeFromFont() {
        let preferredSize = backingViewAsLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        udpateBackingViewSizeFromScreenSize(screenSize: Size(preferredSize))
    }
}

extension Text: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text(string)
        }
    }
}
