//
//  Brick.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

public class Brick {
    private(set) var spriteNode: SKSpriteNode
    
    public internal(set) var coordinate: Coordinate
    
    public var color = UIColor.redBrick {
        didSet {
            let texture = SKTexture(image: Brick.blockImage(color))
            spriteNode.texture = texture
        }
    }
    
    public var strength = 1
    
    public init() {
        let texture = SKTexture(image: Brick.blockImage(.redBrick))
        spriteNode = SKSpriteNode(texture: texture)
        coordinate = Coordinate(column: 0, row: 0)
    }
    
    private static func blockImage(_ seedColor: UIColor) -> UIImage {
        // Get the HSBA values for the seed color.
        var hue = CGFloat(0.0)
        var saturation = CGFloat(0.0)
        var brightness = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        seedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Create a light and dark version of the seed color.
        let lighterColor = UIColor(hue: hue, saturation: saturation * 0.6, brightness: brightness, alpha: alpha)
        let darkerColor = UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.75, alpha: alpha)
        
        // Draw the brick shape using the calculated colors
        let render = UIGraphicsImageRenderer(size: CGSize(width: 118, height: 50))
        let image = render.image { context in
            // Dark shape.
            var path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 8))
            path.addLine(to: CGPoint(x: 11, y: 0))
            path.addLine(to: CGPoint(x: 11, y: 45))
            path.addLine(to: CGPoint(x: 118, y: 45))
            path.addLine(to: CGPoint(x: 105, y: 50))
            path.addLine(to: CGPoint(x: 0, y: 50))
            path.close()
            darkerColor.setFill()
            path.fill()
            
            // Ligher shape.
            path = UIBezierPath(rect: CGRect(x: 11, y: 0, width: 107, height: 45))
            lighterColor.setFill()
            path.fill()
            
            // Seed color rect.
            path = UIBezierPath(rect: CGRect(x: 11, y: 8, width: 97, height: 37))
            seedColor.setFill()
            path.fill()
        }
        
        return image
    }
}
