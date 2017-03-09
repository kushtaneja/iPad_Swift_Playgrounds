//
//  Maze.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation
import SpriteKit


/// User API

public typealias MazeLayout = [[CoordinateType?]]

/// Represents a grid of `Coordinate`s. Each `Coordinate` has associated `CoordinateDetails` that can be retrieved and set.
public class Maze {
    
    weak var delegate: MazeDelegate?

    /// The number of columns in the `Maze`.
    public let columnCount: Int
    
    /// The number of rows in the `Maze`.
    public let rowCount: Int
    
    /// The coordinate for the start of the `Maze`.
    public let start: Coordinate
    
    /// The coordinate for the goal of the `Maze`.
    public let goal: Coordinate
    
    var searchCount = 0
    
    var coordinateDetails: [Coordinate: CoordinateDetails]
    
    /// Initializes a `Maze` with a `MazeLayout` that specifies the types of content for each `Coordinate`.
    /// The `MazeLayout` must contain one start and one goal coordinate.
    public init(layout: MazeLayout) {
        var maxColumnCount = 0
        var coordinateDetails = [Coordinate: CoordinateDetails]()
        
        var start: Coordinate?
        var goal: Coordinate?
        
        for (rowIndex, row) in layout.reversed().enumerated() {
            maxColumnCount = max(maxColumnCount, row.count)
            
            for (columnIndex, type) in row.enumerated() {
                guard let type = type else { continue }

                let coordinate = Coordinate(column: columnIndex, row: rowIndex)
                let details = CoordinateDetails(type: type)
                
                coordinateDetails[coordinate] = details
                
                switch type {
                    case .start:
                        guard start == nil else { fatalError("Cannot have more than one start tile") }
                        start = coordinate
                    
                    case .goal:
                        guard goal == nil else { fatalError("Cannot have more than one goal tile") }
                        goal = coordinate
                    
                    default:
                        break
                }

            }
        }
        
        guard let unwrappedStart = start else { fatalError("No start defined") }
        guard let unwrappedGoal = goal else { fatalError("No goal defined") }
        
        self.columnCount = maxColumnCount
        self.rowCount = layout.count
        self.coordinateDetails = coordinateDetails
        self.start = unwrappedStart
        self.goal = unwrappedGoal
    }
    
    /// Returns `true` if the specified `Coordinate` lies within the bounds of the `Maze`.
    public func coordinateIsValid(_ coordinate: Coordinate) -> Bool {
        return (0..<columnCount).contains(coordinate.column) && (0..<rowCount).contains(coordinate.row)
    }
    
    /// Returns an array of coordinates that are immediate neigbors of the specified `Coordinate` and who's details represent a searchable location.
    /// Diagonal neighbors are not included in the return value.
    ///
    /// Calling this method will mark the passed coordinate as searched and add each neighbor to the coordinate's path.
    public func searchNeighbors(of coordinate: Coordinate) -> [Coordinate] {
        // Mark the coordinate as having been searched.
        var coordinateDetails = details(for: coordinate)
        coordinateDetails.isSearched = true
        setDetails(coordinateDetails, for: coordinate)
        
        let neighbors = [
            Coordinate(column: coordinate.column + 1, row: coordinate.row),
            Coordinate(column: coordinate.column, row: coordinate.row - 1),
            Coordinate(column: coordinate.column - 1, row: coordinate.row),
            Coordinate(column: coordinate.column, row: coordinate.row + 1),
        ].filter { coordinate in
            guard coordinateIsValid(coordinate) else { return false }
            let coordDetails = details(for: coordinate)
            
            return !coordDetails.isSearched && coordDetails.type != .wall
        }
        
        // Update the path to each neighbor
        for neighbor in neighbors {
            coordinateDetails = details(for: neighbor)
            coordinateDetails.previousCoordinate = coordinate
            setDetails(coordinateDetails, for: neighbor)
        }
        
        return neighbors
    }
    
    /// Returns the calculated path distance from the start to the given coordinate.
    public func pathDistance(to coordinate: Coordinate) -> Int {
        var distance = 0
        var coordinateDetails = details(for: coordinate)
        
        while coordinateDetails.previousCoordinate != .invalid {
            distance += 1
            coordinateDetails = details(for: coordinateDetails.previousCoordinate)
        }
        
        return distance
    }
    
    // MARK: Convenience

    /// Returns the `CoordinateDetails` for the specified `Coordinate`.
    func details(for coordinate: Coordinate) -> CoordinateDetails {
        return coordinateDetails[coordinate]!
    }
    
    /// Sets the `CoordinateDetails` for the specified `Coordinate`.
    func setDetails(_ details: CoordinateDetails, for coordinate: Coordinate) {
        let oldValue = coordinateDetails[coordinate]
        coordinateDetails[coordinate] = details
        
        let searchedSquares: [CoordinateDetails] = coordinateDetails.values.filter { $0.isSearched && $0.type != .start }
        searchCount = max(searchCount, searchedSquares.count)
        
        delegate?.maze(self, didUpdate: coordinate, from: oldValue, to: details)
    }
    
    /// Returns an array of `Coordinates` representing the calculated path through the maze.
    /// Returns a nil array and a hint string if there is no calculated path or the path is invalid.
    var path: (coordinates: [Coordinate]?, hint: String?) {
        let hint = "There’s no path defined between the start and the goal. Plot a path through the maze by calling `maze.searchNeighbors(of:)` and inspecting its return value."
        
        let goalDetails = details(for: goal)
        guard goalDetails.previousCoordinate != .invalid else {
            return (nil, hint)
        }
        
        var route = [Coordinate]()
        var coordinate = goal
        while coordinate != start {
            // Check the coordinate hasn't already been used in the route.
            guard route.index(of: coordinate) == nil else { return (nil, hint) }

            // Check the coordinate is valid.
            guard coordinate != .invalid else { return (nil, hint) }

            route.append(coordinate)
            
            let coordinateDetails = details(for: coordinate)

            // Check if the previous coordinate has been set.
            guard coordinateDetails.previousCoordinate != .invalid else { return (nil, hint) }

            // Check the distance between this and the next in the route is 1 tile in any direction.
            let distance = abs(coordinate.column - coordinateDetails.previousCoordinate.column) + abs(coordinate.row - coordinateDetails.previousCoordinate.row)
            guard distance == 1 else { return (nil, hint) }
            
            // Check the coordinate doesn't represent a wall.
            guard coordinateDetails.type != .wall else { return (nil, hint) }
                
            coordinate = coordinateDetails.previousCoordinate
        }
        
        route.append(start)
        return (route.reversed(), nil)
    }
}

protocol MazeDelegate: class {
    func maze(_ maze: Maze, didUpdate coordinate: Coordinate, from: CoordinateDetails?, to: CoordinateDetails?)
}
