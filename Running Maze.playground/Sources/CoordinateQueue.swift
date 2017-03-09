//
//  CoordinateQueue.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation

/// A first in, first out collection of `Coordinates`.
public struct CoordinateQueue {
    
    fileprivate var coordinates = [Coordinate]()
    
    /// Intializes a new `CoordinateQueue`.
    public init() {
        // This initializer needs to be explicitiy defined to allow autocomplete in the Swift Playgrounds app to detect it.
    }
    
    /// A Boolean value indicating whether the queue is empty.
    public var isEmpty: Bool {
        return coordinates.isEmpty
    }
    
    /// The number of `Coordinates` in the queue.
    public var count: Int {
        return coordinates.count
    }
    
    /// An array of all the `Coordinates` in the queue.
    public var allCoordinates: [Coordinate] {
        return coordinates
    }
    
    /// Adds a `Coordinate` to the end of the queue.
    public mutating func add(_ coordinate: Coordinate) {
        if !coordinates.contains(coordinate) {
            coordinates.append(coordinate)
        }
    }
    
    /// Adds an array of `Coordinate`s to the end of the queue.
    public mutating func add(_ coordinates: [Coordinate]) {
        for coordinate in coordinates {
            add(coordinate)
        }
    }
    
    /// Removes a `Coordinate` from the queue.
    public mutating func remove(_ coordinate: Coordinate) {
        if let index = coordinates.index(of: coordinate) {
            coordinates.remove(at: index)
        }
    }
    
    /// Returns the `Coordinate` at the given index in the queue.
    public func coordinate(at index: Int) -> Coordinate {
        return coordinates[index]
    }
    
    /// Returns the `Coordinate` at the given index in the queue.
    public subscript(index: Int) -> Coordinate {
        return coordinates[index]
    }

    /// Returns the first `Coordinate` in the queue and removes it.
    public mutating func popFirstCoordinate() -> Coordinate {
        guard let coordinate = coordinates.first else { fatalError("TODO: How to work around no nils?") }
        
        coordinates.removeFirst()
        return coordinate
    }
}

/// Extends `CoordinateQueue` to conform to the `Sequence` protocol.
/// Allows a `CoordinateQueue` to be used in a for-in statement.
extension CoordinateQueue: Sequence {
    public func makeIterator() -> Array<Coordinate>.Iterator {
        return coordinates.makeIterator()
    }
}
