//
//  Grid.swift
//  Shapes
//

import UIKit

internal class Grid {
    
    internal var show = false {
        didSet {
            backingView.isHidden = !show
        }
    }
    
    internal var backingView = GridView()
    
    fileprivate var majorGridColor: Color {
        get {
            return backingView.majorGridColor
        }
        set {
            backingView.minorGridColor = majorGridColor
        }
    }
    
    fileprivate var minorGridColor: Color {
        get {
            return backingView.minorGridColor
        }
        set {
            backingView.minorGridColor = minorGridColor
        }
    }
    
    internal init() {
        // make sure the grids visibility matches the show property's default.
        backingView.isHidden = !show
    }
}

internal class GridView: UIView {
    
    internal var offsetToCenterInScreenPoints = Point(x: 0, y: 0)
    
    internal var gridStrideInPoints = 10.0
    
    fileprivate var majorGridColor = Color(white: 0.85, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var minorGridColor = Color(white: 0.95, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate init() {
        super.init(frame: CGRect.zero)
        self.isOpaque = false
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawGridLinesFor(axis: .x, dirtyRect: rect)
        drawGridLinesFor(axis: .y, dirtyRect: rect)
    }
    
    private func drawGridLinesFor(axis: Axis, dirtyRect: CGRect) {
    
        let centerPoint: Double
        switch axis {
        case .x:
            centerPoint = offsetToCenterInScreenPoints.x
            break
            
        case .y:
            centerPoint = offsetToCenterInScreenPoints.y
            break
        }
        
        let firstStrokeWidth: CGFloat = 3.0
        let otherThanFirstStrokeWidth: CGFloat = 1.0
        var currentPoint = CGFloat(centerPoint)
        var keepGoing = true
        var iteration = 0
        
        while (keepGoing) {
            
            if iteration % 10 == 0 || (iteration + 1) % 10 == 0{
                majorGridColor.uiColor.set()
            } else {
                minorGridColor.uiColor.set()
            }
            
            let strokeWidth = iteration == 0 ? firstStrokeWidth : otherThanFirstStrokeWidth
            let x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat
            
            switch axis {
            case .x:
                x = currentPoint - strokeWidth/2.0
                y = dirtyRect.minY
                width = strokeWidth
                height = dirtyRect.height
                break
                
            case .y:
                x = dirtyRect.minX
                y = currentPoint - strokeWidth/2.0
                width = dirtyRect.width
                height = strokeWidth
                break
            }
            
            UIRectFillUsingBlendMode(CGRect(x: x, y: y, width: width, height: height), .darken)
            
            iteration += 1
            let multiplier = iteration % 2 == 0 ? 1.0 : -1.0
            currentPoint += CGFloat(gridStrideInPoints * (Double(iteration) * multiplier))
            
            switch axis {
            case .x:
                keepGoing = dirtyRect.minX <= currentPoint && currentPoint <= dirtyRect.maxX
                break
                
            case .y:
                keepGoing = dirtyRect.minY <= currentPoint && currentPoint <= dirtyRect.maxY
                break
            }
        }
    }
    
    private enum Axis {
        case x
        case y
    }
}
