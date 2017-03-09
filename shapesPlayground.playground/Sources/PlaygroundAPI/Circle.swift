//
//  Circle.swift
//  Shapes
//

import UIKit

private let DefaultRadius = 5.0

/// A circle on the canvas:
///
///   - `radius` The distance from the center of the circle to its outside edge. Must be 0.0 or greater.
///
/// Additional properties that can affect Circle:
///
///   - `color` The color to fill the shape with.
///   - `borderWidth` The border width of the shape. The default value is 2.0.
///   - `borderColor` The color to use for the border of the shape. The default value is the same as the fill color.
///   - `center` The center point of the object. Changing this moves the object.
///   - `scale` The amount to grow or shrink the object. A value of 1.0 is the natural (unscaled) size. A value of 0.5 would be 1/2 the original size, while a value of 2.0 would be twice the original size.
///   - `rotation` The angle in radians to rotate this object. Changing this rotates the object counter clockwise about its center. A value of 0.0 (the default) means no rotation. A value of π (3.14159…) will rotate the object 180°, and 2π will rotate a full 360°.
///   - `draggable` Makes the object draggable with your finger on the canvas. The default value is false.
///   - `shadow` The drop shadow for this object. The default is nil, which results in no shadow. To add a shadow, you can set this property, like this: `myObject.dropShadow = Shadow()`.
public class Circle: Shape {
    
    /// The distance from the center of the circle to its outside edge.
    public var radius = DefaultRadius {
        didSet {
            let diameter = radius * 2
            let modelSize = Size(width: diameter, height: diameter)
            updateBackingViewSizeFromModelSize(modelSize: modelSize)
        }
    }
    
    /// Creates a Circle centered on the canvas with a default `radius` of 5.0.
    convenience public init() {
        self.init(radius: DefaultRadius)
    }
    
    /// Creates a Circle centered on the canvas with the given `radius`.
    ///
    /// `radius` The distance from the center of the circle to its outside edge. Must be 0.0 or greater.
    public init(radius: Double) {
        let diameter = radius * 2
        super.init(modelSize: Size(width: diameter, height: diameter), backingView: UIView())
    }
    
    internal override func sizeDidChange() {
        // we could use a shape mask and sublayers to draw the border, but using the corner radius works too.
        backingView.layer.cornerRadius = backingView.frame.width/2.0
    }
}

extension Circle: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("Radius = \(radius)")
        }
    }
}
