//
//  Coordinate.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation

/// A brick coordinate in level space.
public struct Coordinate: Equatable {
    public var column: Int
    public var row: Int
    
    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }

    public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}
