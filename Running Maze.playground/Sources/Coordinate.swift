//
//  Coordinate.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation
import simd

/// Specifies a 2D location in a grid (column, row) -> (x, y)
public struct Coordinate {
    public var column: Int
    public var row: Int
    
    /// Intializes a `Coordinate` with column and row values.
    public init(column: Int, row: Int) {
        // This initializer needs to be explicitiy defined to allow autocomplete in the Swift Playgrounds app to detect it.
        self.column = column
        self.row = row
    }
    
    /// A static instance of a `Coordinate` that can be used to indicate an invalid coordinate.
    static public let invalid = Coordinate(column: Int.max, row: Int.max)
}

extension Coordinate: Equatable {
    public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Coordinate: Hashable {
    public var hashValue: Int {
        guard row != Int.max && column != Int.max else { return Int.max }
        
        return (((row + column) * (row + column + 1)) / 2) + column
    }
}

extension Coordinate {
    static func coordinatesFor(columns: CountableRange<Int>, rows: CountableRange<Int>) -> [Coordinate] {
        var coordinates = [Coordinate]()
        
        for row in rows {
            for column in columns {
                let coordinate = Coordinate(column: column, row: row)
                coordinates.append(coordinate)
            }
        }
        
        return coordinates
    }
}


extension Coordinate {
    
    /// Returns the sum of the vertical and horizontal distances between two `Coordinate`s.
    public func manhattanDistance(to goal: Coordinate) -> Int {
        let rowDelta = abs(row - goal.row)
        let columnDelta = abs(column - goal.column)
        
        return rowDelta + columnDelta
    }
}
