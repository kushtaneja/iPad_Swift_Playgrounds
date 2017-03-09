//
//  Paddle.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

public class Paddle {
    var spriteNode: SKSpriteNode
    
    public init() {
        spriteNode = SKSpriteNode(imageNamed: "Paddle")
        spriteNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
}
