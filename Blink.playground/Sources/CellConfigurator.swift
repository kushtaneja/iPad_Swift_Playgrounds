// 
//  CellConfigurator.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit

/// The CellConfigurator is used to configure the display of a cell.
class CellConfigurator {
    
    var colors: [UIColor?] = [nil, nil, nil]
    
    var images: [UIImage?] = [nil, nil, nil]
    
    var gridColor: UIColor? {
        didSet {
            textureCache = [State : SKTexture]()
        }
    }
    
    var gridLineThickness : CGFloat? {
        didSet {
            textureCache = [State : SKTexture]()
        }
    }
    
    private var textureCache = [State : SKTexture]()
    
    func set(_ color: UIColor, forState state: State) {
        colors[state.rawValue] = color
        textureCache.removeValue(forKey: state)
    }
    
    func set(_ image:UIImage, forState state: State) {
        images[state.rawValue] = image
        textureCache.removeValue(forKey: state)
    }
    
    func texture(for state: State, size: CGSize) -> SKTexture? {
        let texture: SKTexture?
        let image = images[state.rawValue];
        if let cachedTexture = textureCache[state] {
            texture = cachedTexture
        }
        else if let preparedImage = prepareImage(image, color: colors[state.rawValue], size: size, state: state) {
            texture = SKTexture(image: preparedImage)
            textureCache[state] = texture
        }
        else {
            texture = nil
        }
        
        return texture
    }
    
    func prepareImage(_ image: UIImage?, color: UIColor?, size: CGSize, state: State) -> UIImage? {
        
        var origin = CGPoint.zero
        var newSize = CGSize()
        
        if let image = image {
            let isWidthGreaterThanHeight = image.size.width > image.size.height
            let aspectRatio = isWidthGreaterThanHeight ?  (image.size.height / image.size.width) : (image.size.width / image.size.height)
            newSize = isWidthGreaterThanHeight ?
                CGSize(width: size.width, height: size.width * aspectRatio) : CGSize(width: size.width * aspectRatio, height: size.height)
            
            let widthDelta = size.width - newSize.width
            let heightDelta = size.height - newSize.height
            if widthDelta  > 0 { origin.x +=  widthDelta * 0.5 }
            if heightDelta > 0 { origin.y +=  heightDelta * 0.5 }
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            let cellRect = CGRect(origin: .zero, size: size)
            context.clear(cellRect)
            
            if let cellColor = colors[state.rawValue] {
                cellColor.setFill()
                context.fill(cellRect)
            }
            
            if let image = image {
                image.draw(in: CGRect(origin: origin, size: newSize))
            }
            
            if let gridColor = gridColor, let gridLineThickness = gridLineThickness {
                let layer = CALayer()
                layer.frame = CGRect(origin: .zero, size: size)
                layer.backgroundColor = UIColor.clear.cgColor
                layer.borderColor = gridColor.cgColor
                layer.borderWidth = gridLineThickness / 2.0
                layer.render(in: context)
            }
            
        }
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
