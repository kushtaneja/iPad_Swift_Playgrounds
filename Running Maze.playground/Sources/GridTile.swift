//
//  GridTile.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

class GridTile: SKSpriteNode {
    
    let coordinate: Coordinate
    
    var lineInsetScale: CGFloat = 1.0 {
        didSet {
            guard isInsetForLines else { return }
            xScale = lineInsetScale
            yScale = lineInsetScale
        }
    }
    
    var isInsetForLines = true {
        didSet {
            xScale = isInsetForLines ? lineInsetScale : 1.0
            yScale = isInsetForLines ? lineInsetScale : 1.0
        }
    }
    
    required init(coordinate: Coordinate) {
        self.coordinate = coordinate
        super.init(texture: nil, color: .clear, size: .zero)
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        fatalError("init(texture: color: size:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
