//
//  Size.swift
//  Shapes
//

import UIKit

/// A size on the canvas.
///
///  `width` The width component of this size.
///  `height` The height component of this size.
public struct Size {
    
    /// The width component of this size.
    public var width = 0.0
    
    /// The height component of this size.
    public var height = 0.0
    
    internal var cgSize: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    /// Creates a Size with the given width and height.
    ///
    /// `width` The width component of this size.
    /// `height` The height component of this size.
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    internal init(_ cgSize: CGSize) {
        self.width = Double(cgSize.width)
        self.height = Double(cgSize.height)
    }
    
}

extension Size: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("Width = \(width), height = \(height)")
        }
    }
}
