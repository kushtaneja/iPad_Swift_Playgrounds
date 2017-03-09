//
//  CoordinateDetails.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation

/// Represents the properties of a `Coordinate` in a `Maze`.
public struct CoordinateDetails {
    /// The `Coordinate`'s type.
    public let type: CoordinateType
    
    /// A flag to determine if the `Coordinate`'s has been marked as having been searched.
    internal(set) public var isSearched = false
    
    /// The `Coordinate` for the previous location in a computed path.
    /// Set by the running algorithm.
    internal(set) var previousCoordinate: Coordinate = .invalid
    
    public init(type: CoordinateType) {
        self.type = type
    }
}

/// Used to define the type of `Coordinate` within a `Maze`.
public enum CoordinateType {
    case start, goal, floor, wall
}
