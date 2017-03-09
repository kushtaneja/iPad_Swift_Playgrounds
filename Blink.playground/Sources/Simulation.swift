// 
//  Simulation.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import CoreGraphics

/// Different preset options to set up the initial cells' states.
public enum Pattern {
    case glider, pulsar, pentadecathlon, capitalL
}

/**
    A class to simulate a collection of cells. You can set a color, image, or text to customize your cell's states (alive, dead, or idle).
 
 - `cellDimension`: The width and height for each cell from 4 to 512.
 - `speed`: How many times per second the simulation updates.
 
 - `set(_ image: UIImage, forState state: State)`: Displays an image on all cells of the chosen state.
 - `set(_ text: String, forState state: State)`: Displays an emoji or letters on all cells of the chosen state.
 - `set(_ color: UIColor, forState state: State)`: Changes the color for all cells of the chosen state.

 - `placePattern(_ pattern: Pattern, atColumn column: Int, row: Int, state: State = .alive)`: Places different patterns of cells onto the grid, starting at the specified row and column. These cells will be in the specified state.
 - `setState(_ state: State, atColumn column: Int, row: Int)` Sets the initial state for a cell at a particular row and column.
 */
public class Simulation {
    
    var cellSize: CGSize
    
    public var gridLineThickness: CGFloat = 0 {
        didSet {
            cellConfigurator.gridLineThickness = gridLineThickness
        }
    }

    public var gridColor: UIColor? {
        didSet {
            cellConfigurator.gridColor = gridColor
        }
    }
    
    /// The width and height for each cell. This value can be from 4 to 512.
    public var cellDimension: Int {
        get {
            return Int(cellSize.width)
        }
        set(newValue) {
            let adjustedValue = newValue.clamped(to: 4...512)
            cellSize = CGSize(width: adjustedValue, height: adjustedValue)
        }
    }
    
    /// Sets the initial state of cells based on different preset options starting at the specified column and row.
    public func placePattern(_ pattern: Pattern, atColumn column: Int, row: Int, state: State = .alive) {
        switch pattern {
        case .capitalL:
            setState(state, atPositions: [(0,0),(0,1),(0,2),(0,3),(1,3)],
                     withOffset: (column, row))
        case .glider:
            setState(state, atPositions: [(0,2),(1,0),(1,2),(2,1),(2,2)],
                     withOffset: (column, row))
        case .pulsar:
            setState(state, atPositions: [(2,0),(3,0),(4,0),(8,0),(9,0),(10,0),
                                          (0,2),(5,2),(7,2),(12,2),
                                          (0,3),(5,3),(7,3),(12,3),
                                          (0,4),(5,4),(7,4),(12,4),
                                          (2,5),(3,5),(4,5),(8,5),(9,5),(10,5),
                                          (2,7),(3,7),(4,7),(8,7),(9,7),(10,7),
                                          (0,8),(5,8),(7,8),(12,8),
                                          (0,9),(5,9),(7,9),(12,9),
                                          (0,10),(5,10),(7,10),(12,10),
                                          (2,12),(3,12),(4,12),(8,12),(9,12),(10,12)],
                     withOffset: (column, row))
        case .pentadecathlon:
            setState(state, atPositions: [(0,2),(0,3),(1,0),(2,0),(3,0),(4,2),(4,3),(1,5),(2,5),(3,5),(1,8),(2,8),(3,8),(0,10),(0,11),(4,10),(4,11),(1,13),(2,13),(3,13)],
                     withOffset: (column, row))
        }
    }

    var initialState = [Coordinate: State]()
    
    var isPaused: Bool = false
    
    /*
     Note: This name does not conform to the proper naming within the project, but 
     rather is adjusted for the perspective of the playground user. Currently it 
     only effects the initial state and does not modify anything once the simulation 
     is running.
    */
    /// Sets the initial state for a cell at a particular row and column.
    public func setState(_ state: State, atColumn column: Int, row: Int ) {
        let coordinate = Coordinate(column: column, row: row)
        initialState[coordinate] = state
    }
    
    /// A convenience method to set multiple positions to the same state
    func setState(_ state: State, atPositions positions: [(Int, Int)], withOffset offsetPosition: (Int, Int) = (0, 0)) {
        for position in positions {
            setState(state, atColumn: position.0 + offsetPosition.0, row: position.1 + offsetPosition.1)
        }
    }
    
    var cellConfigurator: CellConfigurator = CellConfigurator()
    
    /// Speed adjusts how many times per second the simulation updates.
    public var speed: Int = 2
        
    /** 
     The user will set this function in the playground page and then during
     the update we will call it.
    */
    public var configureCell: ((_ cell: Cell) -> Void)?
    
    /// Initializes a new simulation.
    public init() {
        self.cellSize = CGSize(width: 32, height: 32)
    }

    /// Displays an emoji or letters on all cells of the chosen state.
    public func set(_ text: String, forState state: State) {
        

        let sourceCharacter = text as NSString
        /*
         This is an approximation of the appropriate font size based on the cell 
         dimension, which is always constrainted between 4 and 512.
        */
        let font = UIFont.systemFont(ofSize: cellSize.width)
        let attributes = [NSFontAttributeName : font,
                          NSForegroundColorAttributeName: UIColor.white]
        var textSize = sourceCharacter.size(attributes: attributes)
        if textSize.width < 1 || textSize.height < 1 {
            textSize = cellSize
        }

        UIGraphicsBeginImageContextWithOptions(textSize, false, 0.0)
        
        sourceCharacter.draw(in: CGRect(x:0, y:0, width:textSize.width,  height:textSize.height), withAttributes: attributes)
        cellConfigurator.set( UIGraphicsGetImageFromCurrentImageContext()!, forState:  state)
        
        UIGraphicsEndImageContext()

    }
    
    /// Displays an image on all cells of the chosen state.
    public func set(_ image: UIImage, forState state: State) {
        cellConfigurator.set(image, forState: state)
    }
    
    /// Changes the color for all cells of the chosen state.
    public func set(_ color: UIColor, forState state: State) {
        cellConfigurator.set(color, forState: state)
    }
}
