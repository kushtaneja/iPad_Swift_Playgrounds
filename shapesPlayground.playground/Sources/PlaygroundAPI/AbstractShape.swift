//
//  Shape.swift
//  Shapes
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// An abstract class that all concrete shapes derive from.
public class Shape: AbstractDrawable {

    /// The color to fill the shape with.
    public var color = Color.blue {
        didSet {
            backingView.backgroundColor = color.uiColor
        }
    }
    
    /// The border width of the shape. The default value is 2.0.
    public var borderWidth = 2.0 {
        didSet {
            backingView.layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
    /// The color to use for the border of the shape. The default value is the same as the fill color.
    public var borderColor = Color.clear {
        didSet {
            backingView.layer.borderColor = borderColor.cgColor
        }
    }
    
    override internal init(modelSize: Size, backingView: UIView) {
        
        super.init(modelSize: modelSize, backingView: backingView)
        
        backingView.layer.borderWidth = CGFloat(borderWidth)
        backingView.layer.borderColor = borderColor.cgColor
        backingView.backgroundColor = color.uiColor
    }
    
}
