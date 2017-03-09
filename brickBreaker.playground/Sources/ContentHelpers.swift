//
//  ContentHelpers.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation
import UIKit

// MARK: Setup for playGame() method

public var _playGameCalled = false

public func playGame() {
    _playGameCalled = true
}

// MARK: Convenience methods to access methods on a single Level object

public let level = Level()

public func place(_ brick: Brick, at coordinate: Coordinate) {
    level.place(brick, at: coordinate)
}

public func brickAt(_ coordinate: Coordinate) -> Brick? {
    return level.brick(at: coordinate)
}

public func remove(_ brick: Brick) {
    level.remove(brick, withEffect: .zoomOut)
}

public func playSound(_ sound: Sound) {
    level.play(sound)
}

public extension Brick {
    public var neighbors: [Brick] {
        let neighbors: [Brick?] = [
            level.brick(at: Coordinate(column: coordinate.column, row: coordinate.row + 1)),
            level.brick(at: Coordinate(column: coordinate.column, row: coordinate.row - 1)),
            level.brick(at: Coordinate(column: coordinate.column + 1, row: coordinate.row)),
            level.brick(at: Coordinate(column: coordinate.column - 1, row: coordinate.row)),
            level.brick(at: Coordinate(column: coordinate.column + 1, row: coordinate.row - 1)),
            level.brick(at: Coordinate(column: coordinate.column + 1, row: coordinate.row + 1)),
            level.brick(at: Coordinate(column: coordinate.column - 1, row: coordinate.row - 1)),
            level.brick(at: Coordinate(column: coordinate.column - 1, row: coordinate.row + 1))
        ]
        
        return neighbors.flatMap { $0 }
    }
}

// Delcare a typealias to allow color arrays to be created without having to specify the type.

public typealias _ColorLiteralType = UIColor
