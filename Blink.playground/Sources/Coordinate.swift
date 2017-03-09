// 
//  Coordinate.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation

public struct Coordinate {
    public let column, row: Int
    
    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }
}

extension Coordinate: CustomStringConvertible {
    
    public var description: String {
        return "column \(column), row \(row)"
    }
    
    public var accessibilityCoordindates: String {
        return "column \(column + 1), row \(row + 1)"
    }
}

extension Coordinate: Equatable {}

extension Coordinate: Hashable {
    public var hashValue: Int {
        // Pairing function: https://en.wikipedia.org/wiki/Pairing_function
        return (((row + column) * (row + column + 1)) / 2) + column
    }
}

public func ==(c1: Coordinate, c2: Coordinate) -> Bool {
    return c1.row == c2.row && c1.column == c2.column
}
