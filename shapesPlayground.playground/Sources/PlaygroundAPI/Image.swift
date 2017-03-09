//
//  Image.swift
//  Shapes
//

import UIKit

private let MaxInitialWidth = 20.0
private let MaxInitialHeight = 20.0
private let DefaultImageContentMode = ImageContentMode.scaleToFitMaintainingAspectRatio

/// An image on the canvas.
///
///   - `size` The width and height of the image.
///   - `contentMode` Controls the way the image scales to fill its size.
///   - `tint` When set to a non-nil value, parts of the image with an alpha value of 1.0 are filled with the tint color, while parts of the image with an alpha of less than 1.0 get treated as completely transparent.
///
/// Additional properties that can affect Image:
///
///   - `center` The center point of the object. Changing this moves the object.
///   - `scale` The amount to grow or shrink the object. A value of 1.0 is the natural (unscaled) size. A value of 0.5 would be 1/2 the original size, while a value of 2.0 would be twice the original size.
///   - `rotation` The angle in radians to rotate this object. Changing this rotates the object counter clockwise about its center. A value of 0.0 (the default) means no rotation. A value of π (3.14159…) will rotate the object 180°, and 2π will rotate a full 360°.
///   - `draggable` Makes the object draggable with your finger on the canvas. The default value is false.
///   - `shadow` The drop shadow for this object. The default is nil, which results in no shadow. To add a shadow, you can set this property, like this: `myObject.dropShadow = Shadow()`.
public class Image: AbstractDrawable {

    private var backingViewAsImageView: UIImageView {
        return backingView as! UIImageView
    }
    
    /// Controls the way the image scales to fill its size.
    public var contentMode: ImageContentMode {
        get {
            switch backingViewAsImageView.contentMode {
            case .scaleToFill:
                return .scaleAndStretchToFill
            case .scaleAspectFit:
                return .scaleToFitMaintainingAspectRatio
            default:
                // we shouldn't get here.
                return DefaultImageContentMode
            }
        }
        set {
            switch newValue {
            case .scaleAndStretchToFill:
                backingViewAsImageView.contentMode = .scaleToFill
            case .scaleToFitMaintainingAspectRatio:
                backingViewAsImageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    /// The width and height to draw the image.
    public var size = Size(width: 10.0, height: 10.0) {
        didSet {
            updateBackingViewSizeFromModelSize(modelSize: size)
        }
    }
    
    /// When set to a non-nil value, parts of the image with an alpha value of 1.0 are filled with the tint color, and parts of the image with an alpha of less than 1.0 get treated as completely transparent.
    public var tint: Color? {
        get {
            return Color(uiColor:backingViewAsImageView.tintColor)
        }
        set {
            let renderingMode: UIImageRenderingMode = newValue == nil ? .alwaysOriginal : .alwaysTemplate
            backingViewAsImageView.image = backingViewAsImageView.image?.withRenderingMode(renderingMode)
            backingViewAsImageView.tintColor = newValue?.uiColor
        }
    }
    
    /// Creates an image centered on the canvas.
    ///
    ///   - `name` The name of the image resource to use to create the image.
    ///   - `tint` When set to a non-nil value, parts of the image with an alpha value of 1.0 are filled with the tint color, and parts of the image with an alpha of less than 1.0 get treated as completely transparent.
    ///   - `contentMode` Controls the way the image scales to fill its size.
    public convenience init(name: String, tint: Color? = nil, contentMode: ImageContentMode = .scaleToFitMaintainingAspectRatio) {
        
        let image = UIImage(named: name)
        self.init(image: image, tint: tint, contentMode: .scaleToFitMaintainingAspectRatio)
    }

    /// Creates an image centered on the canvas.
    ///
    ///   - `url` The URL that points to an image resource, to create an Image from.
    ///   - `tint` When set to a non-nil value, parts of the image with an alpha value of 1.0 are filled with the tint color, and parts of the image with an alpha of less than 1.0 get treated as completely transparent.
    ///   - `contentMode` Controls the way the image scales to fill its size.
    public convenience init(url: String, tint: Color? = nil, contentMode: ImageContentMode = .scaleToFitMaintainingAspectRatio) {
        
        var image: UIImage?
        if let imageURL = NSURL.init(string: url) {
            if let imageData = NSData.init(contentsOf: imageURL as URL) {
                image = UIImage.init(data: imageData as Data)
            }
        }
        
        self.init(image: image, tint: tint, contentMode: .scaleToFitMaintainingAspectRatio)
    }
    
    private init(image: UIImage?, tint: Color? = nil, contentMode: ImageContentMode) {

        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        
        var modelSize = Size(width: 0, height: 0)
        if let image = image {
            var width = Canvas.shared.convertMagnitudeFromScreen(screenMagnitude: Double(image.size.width))
            var height = Canvas.shared.convertMagnitudeFromScreen(screenMagnitude: Double(image.size.height))
            
            let maxInitialWidth = MaxInitialWidth
            let maxInitialHeight = MaxInitialHeight
            
            let extraWidth = Double(width) - maxInitialWidth
            let extraHeight = Double(height) - maxInitialHeight
            
            if (extraWidth == 0 && extraHeight == 0) {
                // nothing to do.
            } else if (extraWidth > extraHeight) {
                // adjust the default size based on the width dimension, since it has more extra.
                let ratioOfHeightToWidth = height/width
                width = maxInitialWidth
                height = width * ratioOfHeightToWidth
            } else {
                // adjust the default size based on the height dimension, since it has more extra.
                let ratioOfWidthToHeight = width/height
                height = maxInitialHeight
                width = height * ratioOfWidthToHeight
            }
            
            modelSize = Size(width: width, height: height)
        }
        
        super.init(modelSize: modelSize, backingView: imageView)
        
        self.size = modelSize
        self.contentMode = contentMode
        self.tint = tint
    }
}

/// Controls the way the image scales to fill its size.
public enum ImageContentMode {
    /// Both scale and stretch the image when its natural size doesn't match the size it is being set to.
    case scaleAndStretchToFill
    /// Only scale and don't stretch the image when its natural size doesn't match the size it is being set to.
    case scaleToFitMaintainingAspectRatio
}

extension Image: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("Width \(size.width), height = \(size.height)")
        }
    }
}
