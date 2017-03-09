//
//  Game.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

/// Represents an instance of the Breakout game being played. A game has many levels.
public class Game {
    public private(set) var levels: [Level]
    
    public private(set) var currentLevel: Level
    
    public init(levels: [Level]) {
        self.levels = levels
        
        currentLevel = levels.first!
    }
    
    public var score = 0
    
    public var lives = 3
}
