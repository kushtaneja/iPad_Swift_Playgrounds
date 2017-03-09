//
//  GridView.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit

@objc(GridView)
class GridView: UIView {
    // MARK: Types
    
    struct LineStyle {
        let width: CGFloat
        let color: UIColor
    }

    // MARK: TileGrid propertues
    
    @IBInspectable private(set) var columnCount: Int
    
    @IBInspectable private(set) var rowCount: Int
    
    var scene: SKScene {
        return sceneView.scene!
    }
    
    let sceneView: SKView
    
    let tileDimension: CGFloat = 156

    private var tiles = [Coordinate: GridTile]()
    
    private(set) var innerLineStyle: LineStyle
    
    private(set) var outerLineStyle: LineStyle
    
    required init?(coder aDecoder: NSCoder) {
        columnCount = 10
        rowCount = 10
        
        sceneView = SKView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.allowsTransparency = true
        sceneView.backgroundColor = .clear
        
        innerLineStyle = LineStyle(width: 1.0, color: UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5))
        outerLineStyle = LineStyle(width: 2.0, color: .black)
        
        super.init(coder: aDecoder)

        addSubview(sceneView)
        configurationDidChange()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutSceneView()
        scaleTiles()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Get the scene view's frame and tweak so the outter line overlaps the same amount as an inner line would.
        var rect = sceneView.frame
        rect = rect.insetBy(dx: -outerLineStyle.width / 2.0, dy: -outerLineStyle.width / 2.0)
        rect = rect.insetBy(dx: innerLineStyle.width / 2.0, dy: innerLineStyle.width / 2.0)
        
        outerLineStyle.color.setStroke()
        context.setLineWidth(outerLineStyle.width)
        context.stroke(rect)

        // Draw the inner lines.
        rect = sceneView.frame
        let tileSize = rect.width / CGFloat(columnCount)

        innerLineStyle.color.setStroke()
        context.setLineWidth(innerLineStyle.width)

        for column in 0...columnCount {
            let x = rect.origin.x + CGFloat(column) * tileSize
            context.move(to: CGPoint(x: x, y: rect.origin.y))
            context.addLine(to: CGPoint(x: x, y: rect.origin.y + rect.height))
        }
        
        for row in 0...rowCount {
            let y = rect.origin.y + CGFloat(row) * tileSize
            context.move(to: CGPoint(x: rect.origin.x, y: y))
            context.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: y))
        }
        
        context.strokePath()
    }
    
    // MARK: Convenience property accessors.
    
    func tile(at coordinate: Coordinate) -> GridTile? {
        return tiles[coordinate]
    }
    
    func setColumnCount(_ columnCount: Int, rowCount: Int) {
        self.columnCount = columnCount
        self.rowCount = rowCount
        
        configurationDidChange()
    }
    
    func setInnerLineStyle(_ innerLineStyle: LineStyle, outerLineStyle: LineStyle) {
        self.innerLineStyle = innerLineStyle
        self.outerLineStyle = outerLineStyle
        
        configurationDidChange()
    }

    // MARK: Private convenience methods.
    
    private func configurationDidChange() {
        let scene = SKScene(size: CGSize(width: CGFloat(columnCount) * tileDimension, height: CGFloat(rowCount) * tileDimension))
        scene.backgroundColor = .clear
        scene.scaleMode = .aspectFit
        
        for tile in tiles.values {
            tile.removeFromParent()
        }
        tiles.removeAll()
        
        for coordinate in Coordinate.coordinatesFor(columns: 0..<columnCount, rows: 0..<rowCount) {
            let tile = GridTile(coordinate: coordinate)
            
            tile.size = CGSize(width: tileDimension, height: tileDimension)
            tile.position.x = tileDimension / 2.0
            tile.position.y = tileDimension / 2.0
            
            tile.position.x += CGFloat(tile.coordinate.column) * tileDimension
            tile.position.y += CGFloat(tile.coordinate.row) * tileDimension
            
            tiles[coordinate] = tile
            scene.addChild(tile)
        }
        
        sceneView.presentScene(scene)
        
        layoutSceneView()
        scaleTiles()
        setNeedsDisplay()
    }
    
    private func layoutSceneView() {
        // Determine the viewport size.
        var viewportSize = bounds.size
        viewportSize.width -= outerLineStyle.width
        viewportSize.height -= outerLineStyle.width
        
        // Inset the available size to allow for the outer grid lines.
        viewportSize.width -= outerLineStyle.width
        viewportSize.height -= outerLineStyle.width
        
        // Calculate the scale required to fit the scene view to the available size.
        let sceneRatio = scene.size.width / scene.size.height
        let viewportRatio = viewportSize.width / viewportSize.height
        
        let scale: CGFloat
        if viewportRatio > sceneRatio {
            scale = viewportSize.height / scene.size.height
        } else {
            scale = viewportSize.width / scene.size.width
        }
        
        // Scale and position the scene view's frame.
        var sceneViewFrame = CGRect(x: 0.0, y: 0.0, width: scene.size.width * scale, height: scene.size.height * scale)
        
        // Make sure the view sits on a point boundry.
        let tileDimension = floor(sceneViewFrame.size.width / CGFloat(columnCount))
        sceneViewFrame.size.width = CGFloat(columnCount) * tileDimension
        sceneViewFrame.size.height = CGFloat(rowCount) * tileDimension
        
        sceneViewFrame.origin.x = floor(bounds.size.width / 2.0 - sceneViewFrame.size.width / 2.0)
        sceneViewFrame.origin.y = floor(bounds.size.height / 2.0 - sceneViewFrame.size.height / 2.0)
        
        sceneView.frame = sceneViewFrame
    }
    
    private func scaleTiles() {
        // Calculate the size the tiles should be drawn at.
        var target = sceneView.bounds.size.width / CGFloat(columnCount)
        target -= innerLineStyle.width
        
        // Scale the size to the scene view coordinate space.
        let scaledTarget = sceneView.convert(CGPoint(x: target, y: 0.0), to: scene).x

        // Scale all the tiles.
        let tileScale = scaledTarget / tileDimension
        
        for tile in tiles.values {
            tile.lineInsetScale = tileScale
        }
    }
}
