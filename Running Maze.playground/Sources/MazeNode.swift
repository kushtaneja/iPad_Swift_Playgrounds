//
//  MazeNode.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

class MazeNode: SKSpriteNode {
    private struct Texture {
        static let floor = SKTexture(imageNamed: "Floor")
        static let searched = SKTexture(imageNamed: "Searched")
        static let wall = SKTexture(imageNamed: "Wall")
        static let goal = SKTexture(imageNamed: "Goal")
        static let start = SKTexture(imageNamed: "Start")
    }
    
    private static var searchTextures: [SKTexture] = {
        let atlas = SKTextureAtlas(named: "Search")
        return atlas.textureNames.filter( { $0.hasPrefix("Search") }).sorted().map( { atlas.textureNamed($0) } )
    }()
    
    private var searchedNode: SKSpriteNode?
    
    var coordinateDetails: CoordinateDetails? {
        didSet {
            guard let coordinateDetails = coordinateDetails else { return }
            guard let gridTile = parent as? GridTile else { fatalError("Expected to be a direct child of a GridTile") }
            gridTile.isInsetForLines = false
            
            // Set the texture of the node.
            switch coordinateDetails.type {
            case .start:
                texture = Texture.start
                
            case .goal:
                texture = Texture.goal
                
            case .floor:
                texture = Texture.floor
                
            case .wall:
                texture = Texture.wall
            }
            
            if coordinateDetails.type == .floor {
                if coordinateDetails.isSearched && searchedNode == nil {
                    // The tile is now searched and there isn't a search node; create a search node and animate its texture.
                    let searchedNode = SKSpriteNode(texture: nil, color: .clear, size: size)
                    addChild(searchedNode)
                    
                    searchedNode.run(SKAction.animate(with: MazeNode.searchTextures, timePerFrame: 1.0 / 60.0))
                } else if let searchedNode = searchedNode, !coordinateDetails.isSearched {
                    // The tile is not searched and there is a search node; remove the search node.
                    searchedNode.removeFromParent()
                    self.searchedNode = nil
                }
            }
        }
    }
}
