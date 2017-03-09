//
//  SpiralView.swift
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

/** 
 Draws a spiral shape to the screen after being initialized with a roulette struct.
 Works essentially like a connect-the-dots, drawing the shape by drawing lines from point to point
 */
public class SpiralView: UIView {

    // MARK: Property overrides
    
    // Resets the scale factor if the frame changes
    override public var frame: CGRect {
        didSet {
            if roulette != nil {
                scale = spiralScale()
            }
        }
    }
    
    // MARK: Private properties

    // Intentionally using implicitly unwrapped optional,
    // SpiralView should only ever be instantiated with a roulette object.
    fileprivate var roulette: Roulette!
    
    private var scale: Double = 30.0

    private var points: [CGPoint] = [] {
        didSet {
            // If there are too many points, reduce the resolution of the shape
            // by removing every other point. This can happen in very complex
            // shapes, where there points are required before the shape is complete.
            guard points.count > 5000 else { return }

            points = points.enumerated().filter({ index, point in
                // Only include every other point.
                return index % 2 != 0
                
            }).map({ (index, point) in
                // Map the enumerated tuple back to a single point.
                return point
            })
        }
    }
    
    private var angle: Double = 0.0
    
    private var time: TimeInterval = 0.0
    
    private var timeStep: TimeInterval = 0.01
    
    let trackLayer = CAShapeLayer()
    
    let wheelLayer = CAShapeLayer()
    
    let spokeLayer = CAShapeLayer()
    
    private let pathLayer = CAShapeLayer()
    
    // Counter to keep track of how many points in a row we've matched for shape completion
    private var countUp = 0
    
    private var isShapeComplete = false
    
    private var currentStartPoint: CGPoint {
        // Calculate the current "start point" of the next line that will be drawn of the shape.
        let startX = scale * (roulette.trackRadius - roulette.wheelRadius) * cos(time)
        let startY = scale * (roulette.trackRadius - roulette.wheelRadius) * sin(time)

        return CGPoint(x: CGFloat(startX) + bounds.midX, y: CGFloat(startY) + bounds.midY)
    }
    
    private var currentNextPoint: CGPoint {
        // Calculate the current "next point" of the next line that will be drawn of the shape.
        let nextPointX = CGFloat(roulette.spokeLength * scale * cos(angle)) + currentStartPoint.x
        let nextPointY = CGFloat(roulette.spokeLength * scale * sin(angle)) + currentStartPoint.y

        return CGPoint(x: nextPointX, y: nextPointY)
    }
    
    // MARK: Initiailization & DrawRect

    public convenience init(frame: CGRect, roulette: Roulette) {
        self.init(frame: frame)
        self.roulette = roulette
        self.scale = spiralScale()
        
        backgroundColor = self.roulette.backgroundColor
        
        // Advising the user to enter speeds between 1 and 10 for ease of reading.
        // Actual values should really be in 0.01 - 1.0 range. Faster speeds are possible but look ridiculous
        timeStep = (roulette.drawSpeed / 100)
        
        // Add layers to represent the track, wheel and spoke.
        layer.addSublayer(trackLayer)
        layer.insertSublayer(pathLayer, above: trackLayer)
        layer.insertSublayer(wheelLayer, above: pathLayer)
        layer.insertSublayer(spokeLayer, above: wheelLayer)
        
        configureShapeLayers()
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        guard !points.isEmpty else { return }
        
        // Create a `UIBezierPath` made up of all the points.
        let path = UIBezierPath()
        path.move(to: points[0])
        
        for point in points {
            path.addLine(to: point)
        }
        
        // Draw the path.
        roulette.pathColor.set()
        path.lineWidth = 1.5
        path.stroke()
        
        pathLayer.path = path.cgPath
        pathLayer.fillColor = UIColor.clear.cgColor
    }
    
    // MARK: Private helper functions
    
    /// Calculate the correct scale, based on chosen values and the view's frame 
    /// at initialization and the type of shape being drawn
    private func spiralScale() -> Double {
        let scaleFactor: Double
        let wheelRadiusAbs = abs(roulette.wheelRadius)
        let spokeAbs = abs(roulette.spokeLength)
        let trackRadiusAbs = abs(roulette.trackRadius)
        let trackDiameter = trackRadiusAbs * 2
        let wheelDiameter = wheelRadiusAbs * 2
        
        let width = Double(max(frame.width, frame.height)) / 2
        
        switch roulette.rouletteType {
        case .hypocycloid:
            if trackDiameter > wheelDiameter {
                scaleFactor = width / trackDiameter
            } else {
                scaleFactor = width / ((wheelDiameter * 2) - trackDiameter)
            }
        case .epicycloid:
            scaleFactor = width / (trackDiameter + (wheelDiameter * 2))
        case .hypotrochoid, .ellipse: // An ellipse is just a specialized hypotrochoid, so it follows the same scale rules
            if trackDiameter > wheelDiameter {
                if spokeAbs > wheelRadiusAbs { // A hypotrochoid with a long spoke and larger track
                    scaleFactor = width / (trackDiameter + ((spokeAbs - wheelRadiusAbs) * 2))
                } else { // A hypotrochoid with a short spoke and larger track
                    scaleFactor = width / trackDiameter
                }
            } else {
                if spokeAbs > wheelRadiusAbs { // A hypotrochoid with a long spoke and larger wheel
                    scaleFactor = width / (((wheelDiameter * 2) - trackDiameter) + ((spokeAbs - wheelRadiusAbs) * 2))
                } else { // A hypotrochoid with a short spoke and larger wheel
                    scaleFactor = width / (((wheelDiameter - trackDiameter) * 2) + trackDiameter)
                }
            }
        case.epitrochoid:
            if spokeAbs > wheelRadiusAbs {
                scaleFactor = width / (trackDiameter + ((wheelRadiusAbs + spokeAbs) * 2))
            } else {
                scaleFactor = width / (trackDiameter + (wheelDiameter * 2))
            }
        }
        
        return scaleFactor * 0.95
    }
    
    /// Draws the track and sets up the layers for the wheel and spoke
    private func configureShapeLayers() {
        // Determine the center of the view.
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        // Create a bezier path tp represent the track. This is a circle of
        // radius truackRadius * scale, centered on the center point.
        let trackPath = UIBezierPath(circleWithCenter: centerPoint,
                                               radius: CGFloat(roulette.trackRadius) * CGFloat(scale))

        trackLayer.path = trackPath.cgPath
        trackLayer.lineWidth = 1.0
        trackLayer.strokeColor = roulette.trackStrokeColor.cgColor
        trackLayer.fillColor = roulette.trackFillColor.cgColor
        
        // Configure `wheelLayer`
        wheelLayer.lineWidth = 2.0
        wheelLayer.strokeColor = roulette.wheelStrokeColor.cgColor
        wheelLayer.fillColor = roulette.wheelFillColor.cgColor
        
        // Configure `spokeLayer`
        spokeLayer.lineWidth = 2.0
        spokeLayer.strokeColor = roulette.spokeColor.cgColor
        spokeLayer.fillColor = roulette.spokeColor.cgColor
    }
    
    // MARK: Public functions
    
    /// Calculates the next point to move to on the spiral's path, and adds it to the points array
    func update() {
        // Update the path for the `wheelLayer`.
        let wheelPath = UIBezierPath(circleWithCenter: currentStartPoint,
                                               radius: CGFloat(roulette.wheelRadius * scale))
        
        wheelLayer.path = wheelPath.cgPath
        
        // Update the path for the `spokeLayer`.
        let spokePath = UIBezierPath()
        spokePath.move(to: currentStartPoint)
        spokePath.addLine(to: currentNextPoint)
        spokePath.append(UIBezierPath(circleWithCenter: currentNextPoint,
                                                radius: 4.0))
        spokeLayer.path = spokePath.cgPath
        
        if !isShapeComplete {

            points.append(currentNextPoint)
            
            // Make sure we've got at least 2 points in the array to draw a line between.
            if points.count > 1 {
                
                // Checks against the first point (countUp is set to 0 initially, and won't increment until we've got a match)
                let checkPoint = points[countUp]
                
                // Use Pythagorean Theorem to calculate a small room for error for
                // matching the finishing point back to the initial point.
                let x = checkPoint.x - currentNextPoint.x
                let y = checkPoint.y - currentNextPoint.y
                
                // If there are more than 200 points, check if the distance between the
                // first and last points is small enough to begin checking for shape completion
                if sqrt((x * x) + (y * y)) < 2 && points.count > 200 {
                    
                    countUp = countUp + 1
                    
                    if countUp == 10 {
                        isShapeComplete = true
                    }
                } else {
                    countUp = 0
                }
                
                // Notify the view that it needs to redraw the portion of itself showing
                // actual movement, not the entire view. CoreGraphics will discard
                // drawing commands that fall outside of this rect.
                let dirtyRect = CGRect(rectContaining: points[points.count - 2],
                                               point2: currentNextPoint, inset: 0.5)
                setNeedsDisplay(dirtyRect)
            }
        }
        
        // Recalculate the angle to move the spoke along its path.
        angle -= ((roulette.trackRadius - roulette.wheelRadius) / roulette.wheelRadius) * timeStep
        
        time += timeStep
    }
    
    /// This notifies the view that its entire rect is dirty and needs to be redrawn
    func reset() {
        configureShapeLayers()
        setNeedsDisplay()
    }
}
