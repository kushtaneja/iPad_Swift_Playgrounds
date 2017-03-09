//
//  Canvas.swift
//  Shapes
//

import UIKit

/// The surface that all objects are added to. The canvas center point is (0,0) and is located in the visual center of the canvas.
public class Canvas {
    
    public static let shared = Canvas()
    
    fileprivate let grid = Grid()
    
    /// Determines whether a grid is drawn underneath objects on the canvas. The default value is `false`.
    public var showsGrid: Bool {
        get {
            return grid.show
        }
        set {
            grid.show = showsGrid
        }
    }
    
    /// The color to fill the canvas with.
    public var color = Color.clear {
        didSet {
            backingView.backgroundColor = color.uiColor
        }
    }
    
    /// The visible width and height of the canvas.
    public var visibleSize: Size {
        get {
            let modelWidth = convertMagnitudeFromScreen(screenMagnitude: Double(backingView.frame.width))
            let modelHeight = convertMagnitudeFromScreen(screenMagnitude: Double(backingView.frame.height))
            return Size(width: modelWidth, height: modelHeight)
        }
    }
    
    /// Points where touches are currently occurring.
    public var currentTouchPoints: [Point] {
        get {
            // convert the current UITouches into an array of points.
            var points: [Point] = []
            for touch in touchGestureRecognizer.currentTouches {
                let screenTouchPoint = Point(touch.location(in: backingView))
                let modelTouchPoint = convertPointFromScreen(screenPoint: screenTouchPoint)
                points.append(modelTouchPoint)
            }
            
            return points
        }
    }
    
    internal let numPointsPerUnit = 10.0
    
    fileprivate var offsetToCenterOfViewInScreenPoints = Point(x: 0, y: 0)
    
    fileprivate var drawables = [AbstractDrawable]()
    
    fileprivate var touchGestureRecognizer: TouchGestureRecognizer
    
    internal let backingView: UIView = FrameChangeNotifyingView()
    
    private init() {
        
        backingView.backgroundColor = UIColor.init(white: 1.0, alpha: 0.8)
        backingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        grid.backingView.gridStrideInPoints = numPointsPerUnit
        
        // add the grid.
        backingView.insertSubview(grid.backingView, at: 0)

        touchGestureRecognizer = TouchGestureRecognizer()
        touchGestureRecognizer.touchDelegate = self
        backingView.addGestureRecognizer(touchGestureRecognizer)
        
        let frameChangeNotifyingView = backingView as! FrameChangeNotifyingView
        frameChangeNotifyingView.frameChangeDelegate = self
    }
    
    internal func addDrawable(drawable: AbstractDrawable) {
        // if the drawable is already on the canvas, just return.
        guard drawables.index(of: drawable) == nil else { return }
        drawables.append(drawable)
        backingView.addSubview(drawable.backingView)
        centerDrawable(drawable: drawable)
    }
    
    internal func removeDrawable(drawable: AbstractDrawable) {
        // if the drawable isn't on the canvas, just return.
        guard let index = drawables.index(of: drawable) else { return }
        drawable.backingView.removeFromSuperview()
        drawables.remove(at: index)
    }
    
    internal func clear() {
        for drawable in drawables {
            drawable.backingView.removeFromSuperview()
        }
        
        drawables.removeAll()
    }
    
    internal func centerDrawable(drawable: AbstractDrawable) {
        drawable.backingView.center = offsetToCenterOfViewInScreenPoints.cgPoint
    }
    
    internal func convertPointToScreen(modelPoint: Point) -> Point {
        var screenPoint = Point(x: 0,y: 0)
        
        screenPoint.x = (modelPoint.x * numPointsPerUnit) + offsetToCenterOfViewInScreenPoints.x
        
        // remember that 0,0 is in the top left.
        screenPoint.y = offsetToCenterOfViewInScreenPoints.y - (modelPoint.y * numPointsPerUnit)
        
        return screenPoint
    }
    
    internal func convertPointFromScreen(screenPoint: CGPoint) -> Point {
        return convertPointFromScreen(screenPoint: Point(screenPoint))
    }
    
    internal func convertPointFromScreen(screenPoint: Point) -> Point {
        var modelPoint = Point(x: 0, y: 0)
        
        modelPoint.x = (screenPoint.x - offsetToCenterOfViewInScreenPoints.x) / numPointsPerUnit
        
        // remember that 0,0 is in the top left.
        modelPoint.y = (offsetToCenterOfViewInScreenPoints.y - screenPoint.y) / numPointsPerUnit
        
        return modelPoint
    }
    
    internal func convertMagnitudeToScreen(modelMagnitude: Double) -> Double {
        return modelMagnitude * numPointsPerUnit
    }
    
    internal func convertMagnitudeFromScreen(screenMagnitude: Double) -> Double {
        return screenMagnitude / numPointsPerUnit
    }
    
    // MARK: Interaction API
    
    fileprivate var onTouchDownHandler: (() -> Void)?
    /// A code block that is called for when a touch down occurs on this object.
    public func onTouchDown(handler: @escaping () -> Void) {
        onTouchDownHandler = handler
    }
    
    fileprivate var onTouchUpHandler: (() -> Void)?
    /// A code block that is called for when a touch up occurs on this object.
    public func onTouchUp(handler: @escaping () -> Void) {
        onTouchUpHandler = handler
    }
    
    fileprivate var onTouchDragHandler: (() -> Void)?
    /// A code block that is called for when a drag occurs on this object.
    public func onTouchDrag(handler: @escaping () -> Void) {
        onTouchDragHandler = handler
    }
    
    fileprivate var onTouchCancelledHandler: (() -> Void)?
    /// A code block that is called for when a touch has been canceled on this object. This may occur, for example, if the system presented a dialog while the user was interacting with this object.
    public func onTouchCancelled(handler: @escaping () -> Void) {
        onTouchCancelledHandler = handler
    }
}

extension Canvas: TouchGestureRecognizerDelegate {
    
    func touchesBegan(touches: Set<UITouch>, with event: UIEvent) {
        onTouchDownHandler?()
    }
    
    func touchesMoved(touches: Set<UITouch>, with event: UIEvent) {
        onTouchDragHandler?()
    }
    
    func touchesEnded(touches: Set<UITouch>, with event: UIEvent) {
        onTouchUpHandler?()
    }
    
    func touchesCancelled(touches: Set<UITouch>, with event: UIEvent) {
        onTouchCancelledHandler?()
    }
    
    func wantsTouch(touch: UITouch) -> Bool {
        // we only want touches if we have a handler.
        return onTouchDownHandler != nil || onTouchDragHandler != nil || onTouchUpHandler != nil || onTouchCancelledHandler != nil
    }
}

extension Canvas: FrameChangeDelegate {
    func frameDidChange() {
        
        // remember the previous offset from center so we can adjust the location of each drawable.
        let oldOffset = offsetToCenterOfViewInScreenPoints
        
        // NOTE: for now the center of our canvas is literally its center.
        offsetToCenterOfViewInScreenPoints = Point(backingView.center)
        grid.backingView.frame = self.backingView.bounds
        grid.backingView.offsetToCenterInScreenPoints = offsetToCenterOfViewInScreenPoints
        
        // calculate the delta between the previous center of the screen and the new center of the screen.
        let deltaX = offsetToCenterOfViewInScreenPoints.x - oldOffset.x
        let deltaY = offsetToCenterOfViewInScreenPoints.y - oldOffset.y
        
        // now adjust each drawable, keeping the same distance from the center of the canvas.
        for drawable in drawables {
            drawable.backingView.center.x += CGFloat(deltaX)
            drawable.backingView.center.y += CGFloat(deltaY)
        }
    }
}

private protocol FrameChangeDelegate: class {
    func frameDidChange()
}

private class FrameChangeNotifyingView: UIView {

    weak var frameChangeDelegate: FrameChangeDelegate?
    
    private var previousFrame = CGRect.zero
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        
        // only notify the delegate if the frame actually changed.
        if (previousFrame != frame) {
            frameChangeDelegate?.frameDidChange()
        }
        previousFrame = frame
    }
    
}
