//
//  Effect.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

public enum Effect {
    case none, zoomOut, fadeOut, drop
    
    func apply(to node: SKNode) {
        let remove = SKAction.removeFromParent()
        
        switch self {
        case .none:
            node.run(remove)
            
        case .zoomOut:
            let fade = SKAction.fadeOut(withDuration: 0.2)
            let shrink = SKAction.scaleX(to: 0.2, duration: 0.2)
            node.run(SKAction.sequence([SKAction.group([fade, shrink]), remove]))
            
        case .fadeOut:
            let fade = SKAction.fadeOut(withDuration: 0.2)
            node.run(SKAction.sequence([fade, remove]))
            
        case .drop: // TODO: Drop without adding gravity?
            let fade = SKAction.fadeOut(withDuration: 0.2)
            node.run(SKAction.sequence([fade, remove]))
        }
    }
}
