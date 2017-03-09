//
//  Line.swift
//  Shapes
//

import UIKit
import CoreGraphics

private func distanceBetween(start: Point, end: Point) -> Double {
    return sqrt(pow(abs(start.x - end.x), 2) + pow(abs(start.y - end.y), 2))
}

private func radianAngleFor(start: Point, end: Point) -> Double {
    return atan2(end.y - start.y, start.x - end.x)
}

private func centerOf(start: Point, end: Point) -> Point {
    return Point(x: (end.x + start.x) / 2, y: (end.y + start.y) / 2)
}

/// A line on the canvas.
///
///   - `start` The starting point.
///   - `end` The ending point.
///   - `thickness` The thickness of the line. The default value is 0.5.
///
/// Additional properties that can affect Line:
///
///   - `color` The color to fill the shape with.
///   - `borderWidth` The border width of the shape. The default value is 2.0.
///   - `borderColor` The color to use for the border of the shape. The default value is the same as the fill color.
///   - `center` The center point of the object. Changing this moves the object.
///   - `scale` The amount to grow or shrink the object. A value of 1.0 is the natural (unscaled) size. A value of 0.5 would be 1/2 the orginal size, while a value of 2.0 would be twice the original size.
///   - `rotation` The angle in radians to rotate this object. Changing this rotates the object counter clockwise about its center. A value of 0.0 (the default) means no rotation. A value of π (3.14159…) will rotate the object 180°, and 2π will rotate a full 360°.
///   - `draggable` Makes the object draggable with your finger on the canvas. The default value is false.
///   - `shadow` The drop shadow for this object. The default is nil, which results in no shadow. To add a shadow, you can set this property, like this: `myObject.dropShadow = Shadow()`.
public class Line: Shape {
    
    public convenience init() {
        let start = Point(x: -10, y: 0)
        let end = Point(x: 10, y: 0)
        self.init(start: start, end: end)
    }
    
    /// Creates a Line with the given start and end point. Note that `Point(x: 0, y: 0)` is the center of the canvas.
    ///
    /// `start` The point at which to start drawing the line.
    /// `end` The point at which to stop drawing the line.
    /// `thickness` The thickness of the line. The default value is 0.5.
    public init(start: Point, end: Point, thickness: Double = 0.5) {
        self.start = start
        self.end = end
        self.thickness = thickness
        
        let length = distanceBetween(start: start, end: end)
        let modelSize = Size(width: length, height: thickness)
        
        super.init(modelSize: modelSize, backingView: UIView())
    
        self.center = centerOf(start: start, end: end)
    }
    
    /// The point at which to start drawing the line. Note that `Point(x: 0, y: 0)` is the center of the canvas.
    public var start: Point {
        didSet {
            updateBackingViewSizeFromModelSize(modelSize: calculatedModelSize)
            updateCenterPoint()
        }
    }
    
    /// The point at which to stop drawing the line. Note that `Point(x: 0, y: 0)` is the center of the canvas.
    public var end: Point {
        didSet {
            updateBackingViewSizeFromModelSize(modelSize: calculatedModelSize)
            updateCenterPoint()
        }
    }
    
    /// The thickness of the line. The default value is 0.5.
    public var thickness: Double {
        didSet {
            updateBackingViewSizeFromModelSize(modelSize: calculatedModelSize)
            updateCenterPoint()
        }
    }
    
    // MARK: Internal
    
    private var calculatedModelSize: Size {
        get {
            let length = distanceBetween(start: start, end: end)
            return Size(width: length, height: thickness)
        }
    }
    
    private func updateCenterPoint() {
        center = centerOf(start: start, end: end)
    }
    
    internal override func defaultRotationTransform() -> CGAffineTransform {
        let radians = radianAngleFor(start: start, end: end)
        return CGAffineTransform(rotationAngle: CGFloat(radians))
    }
}

extension Line: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("Length = \(distanceBetween(start: start, end: end))")
        }
    }
}
