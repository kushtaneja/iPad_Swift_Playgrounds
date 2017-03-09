//
//  Rectangle.swift
//  Shapes
//

import UIKit

private let DefaultWidth = 10.0
private let DefaultHeight = 10.0

/// A rectangle on the canvas.
///
///   - `size` The width and height of the rectangle.
///   - `cornerRadius` The amount to round the corners of the rectangle.
///
/// Additional properties that can affect Rectangle:
///
///   - `color` The color to fill the shape with.
///   - `borderWidth` The border width of the shape. The default value is 2.0.
///   - `borderColor` The color to use for the border of the shape. The default value is the same as the fill color.
///   - `center` The center point of the object. Changing this moves the object.
///   - `scale` The amount to grow or shrink the object. A value of 1.0 is the natural (unscaled) size. A value of 0.5 would be 1/2 the orginal size, while a value of 2.0 would be twice the original size.
///   - `rotation` The angle in radians to rotate this object. Changing this rotates the object counter clockwise about its center. A value of 0.0 (the default) means no rotation. A value of π (3.14159…) will rotate the object 180°, and 2π will rotate a full 360°.
///   - `draggable` Makes the object draggable with your finger on the canvas. The default value is false.
///   - `shadow` The drop shadow for this object. The default is nil, which results in no shadow. To add a shadow, you can set this property, like this: `myObject.dropShadow = Shadow()`.
public class Rectangle: Shape {
    
    /// Creates a rectangle centered on the canvas with a default `width` (10.0), `height` (10.0) and `cornerRadius` (0.0).
    public convenience init() {
        self.init(width: DefaultWidth, height: DefaultHeight)
    }
    
    /// Creates a rectangle centered on the canvas.
    ///
    ///   - `width` The width of the rectangle.
    ///   - `height` The height of the rectangle.
    ///   - `cornerRadius` The amount to round the corners of the rectangle.
    public init(width: Double, height: Double, cornerRadius: Double = 0.0) {
        let size = Size(width: width, height: height)
        super.init(modelSize: size, backingView: UIView())
        
        self.size = size
        self.cornerRadius = cornerRadius
        updateCornerRadiusFromModel()
    }
    
    /// The width and height of the rectangle.
    public var size = Size(width: 10.0, height: 10.0) {
        didSet {
            updateBackingViewSizeFromModelSize(modelSize: size)
        }
    }

    /// The amount to round the corners of the rectangle.
    public var cornerRadius = 0.0 {
        didSet {
            updateCornerRadiusFromModel()
        }
    }
    
    private func updateCornerRadiusFromModel() {
        let screenCornerRadius = Canvas.shared.convertMagnitudeToScreen(modelMagnitude: cornerRadius)
        backingView.layer.cornerRadius = CGFloat(screenCornerRadius)
    }

}

extension Rectangle: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("Width = \(size.width), height = \(size.height)")
        }
    }
}
