// 
//  Cell.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit

/// The various states a cell can be in (alive, dead, or idle). Idle is the default cell state when the simulation starts.
public enum State: Int {
    case idle = 0
    case alive
    case dead
    
    var description: String {
        switch self {
        case .alive:
            return "Alive"
        case .dead:
            return "Dead"
        case .idle:
            return "Idle"
        }
    }
}

/// A cell in the simulation that can be in one of three states (alive, dead, or idle).
public class Cell {
    
    weak var cellConfigurator: CellConfigurator? {
        didSet {
            updateDisplay()
        }
    }
    
    /// The state a cell is in (alive, dead, or idle).
    public var state: State {
        didSet {
            if state != priorState {
                updateDisplay()
                spriteNode?.accessibilityLabel = state.description + " Cell"
            }
        }
    }
    
    var priorState: State
    
    var spriteNode : SKSpriteNode?

    /// How many alive neighbors the cell has in the 8 adjacent tiles.
    public var numberOfAliveNeighbors: Int {
        return stateNeighborCounts[.alive] ?? 0
    }
    
    /// How many dead neighbors the cell has in the 8 adjacent tiles.
    public var numberOfDeadNeighbors: Int {
        return stateNeighborCounts[.dead] ?? 0
    }
    
    /// How many idle neighbors the cell has in the 8 adjacent tiles.
    public var numberOfIdleNeighbors: Int {
        return stateNeighborCounts[.idle] ?? 0
    }
    
    /// These values are set on the update loop before the cell is configured.
    var stateNeighborCounts: [State: Int] = [:]

    init(state: State = .idle) {
        self.state = state
        self.priorState = .idle
    }
    
    func updateDisplay() {
        if let cellConfigurator = cellConfigurator, let spriteNode = spriteNode {
            if let texture = cellConfigurator.texture(for: state, size: spriteNode.size) {
                spriteNode.texture = texture
            }
            else {
                spriteNode.texture = nil
            }
            
            if let color = cellConfigurator.colors[state.rawValue] {
                spriteNode.color = color
            }
        }
    }
    
    /// This is used when a user touches a cell to force it to be a new state.
    func forceState(_ state: State) {
        self.state = state
        priorState = state
    }
    
    /**
     The internal system updates its prior state, which is used for checking the 
     number of neighbors.
    */
    func updatePriorState() {
        priorState = state
    }
}
