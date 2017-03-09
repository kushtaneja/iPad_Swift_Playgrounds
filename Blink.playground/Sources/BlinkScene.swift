//
//  BlinkScene.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit

class BlinkScene : SKScene {
    
    var simulation: Simulation? {
        didSet {
            resetToInitialState()
       }
    }

    private var cells = [[Cell]]()
    private var nodeToCell = [SKSpriteNode : Cell]()
    
    private var isUserTouchingView = false
    
    private var previousUpdateTime: TimeInterval?
    
    var horizontalCellCount: Int = 0
    
    var verticalCellCount: Int = 0
    
    var isSimulationPaused: Bool {
        if let simulation = simulation, simulation.isPaused == false && !isUserTouchingView  {
            return false
        }
        return true
    }
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        if let simulation = simulation {
            setupCells(with: simulation)
        }
    }
    
    override func didMove(to view: SKView) {
        if let simulation = simulation {
            setupCells(with: simulation)
        }
    }
    
    func positionForCell(atColumn column: Int, row: Int) -> CGPoint {
        if let cellSize = simulation?.cellSize {
            return CGPoint(x: CGFloat(column) * cellSize.width, y: size.height - (CGFloat(row) * cellSize.height))
        }
        return CGPoint()
    }
    
    func resetToInitialState() {
        removeAllChildren()
        cells = [[Cell]]()
        nodeToCell = [SKSpriteNode : Cell]()
        
        if let simulation = simulation {
            setupCells(with: simulation)
        }
    }
    
    func setupCells(with simulation: Simulation) {
        let isInitialState = cells.count == 0 ? true : false
        let cellSize = simulation.cellSize
        let newHorizontalCount = Int(ceilf(Float(size.width / cellSize.width)))
        let newVerticalCount = Int(ceilf(Float(size.height / cellSize.height)))
        
        /*
         If the size has increased since before, new cells are added. This
         does not handle deletion as it will remain off screen in a static state.
         */
        let totalRows = max(newVerticalCount, cells.count)
        
        for y in 0 ..< totalRows {
            
            var isNewRow = false
            var rowCells: [Cell]
            if y < newVerticalCount && y >= cells.count {
                rowCells = [Cell]()
                isNewRow = true
            }
            else {
                rowCells = cells[y]
            }
            
            let totalColumns = max(newHorizontalCount, rowCells.count)
            
            for x in 0 ..< totalColumns {
                
                var cell: Cell
                if x < newHorizontalCount && x >= rowCells.count {
                    // Create a new cell.
                    cell = Cell()

                    let node = SKSpriteNode()
                    node.size = cellSize
                    node.anchorPoint = CGPoint(x: 0, y: 1)
                    node.position = positionForCell(atColumn: x, row: y)
                    addChild(node)
                    
                    cell.spriteNode = node
                    nodeToCell[node] = cell
                    
                    cell.cellConfigurator = simulation.cellConfigurator

                    rowCells.append(cell)
                }
                else {
                    cell = rowCells[x]
                }
                
                /*
                 This resizes the position of all the cells, including those that are inactive.
                 This is needed to ensure they remain offscreen after a rotation.
                 */
                if let node = cell.spriteNode {
                    node.position = positionForCell(atColumn: x, row: y)
                }
                
                // If there was an initial state set for a cell, set it on the first run.
                if isInitialState, let state = simulation.initialState[Coordinate(column: x, row:y)] {
                    cell.forceState(state)
                }
            }
            if isNewRow {
                cells.append(rowCells)
            } else {
                cells[y] = rowCells
            }
        }
        
        horizontalCellCount = newHorizontalCount
        verticalCellCount = newVerticalCount
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard !isSimulationPaused && cells.count > 0 else { return }

        if previousUpdateTime == nil {
            previousUpdateTime = currentTime
        }
        
        if let simulationSpeed = simulation?.speed {
            if simulationSpeed > 0 {
                let deltaTime = currentTime - previousUpdateTime!
                if deltaTime > (1 / Double(simulationSpeed)) {
                    updateSimulationCycle()
                    previousUpdateTime = currentTime
                }
            }
        }
    }
    
    /// Update the simulation cycle for all of the cells.
    func updateSimulationCycle() {
        for y in 0 ..< verticalCellCount {
            for x in 0 ..< horizontalCellCount {
                let cell = cells[y][x]
                
                cell.stateNeighborCounts[.alive] = numberOfNeighbors(forState: .alive, atColumn: x, row: y)
                cell.stateNeighborCounts[.dead] = numberOfNeighbors(forState: .alive, atColumn: x, row: y)
                cell.stateNeighborCounts[.idle] = numberOfNeighbors(forState: .idle, atColumn: x, row: y)
                
                // This calls the user's function to configure each cell.
                simulation?.configureCell?(cell)
            }
        }
        
        for y in 0 ..< verticalCellCount {
            for x in 0 ..< horizontalCellCount {
                let cell = cells[y][x]
                cell.updatePriorState()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isUserTouchingView = true
        for touch in touches {
            let locationOfTouch = touch.location(in: self)
            
            if let node = atPoint(locationOfTouch) as? SKSpriteNode, let cell = nodeToCell[node]  {
                cell.forceState(.alive)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            let locationOfTouch = touch.location(in: self)
            if let node = atPoint(locationOfTouch) as? SKSpriteNode, let cell = nodeToCell[node]  {
                cell.forceState(.alive)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isUserTouchingView = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isUserTouchingView = false
    }
    
    func numberOfNeighbors(forState state: State, atColumn column: Int, row: Int)  -> Int {
        var numberOfNeighbors = 0
        
        // Check cell to the left.
        if column > 0 && cells[row][column-1].priorState == state {
            numberOfNeighbors += 1
        }
        // Check upper-left cell.
        if column > 0 &&  row > 0 && cells[row-1][column-1].priorState == state {
            numberOfNeighbors += 1
        }
        
        // Check cell above.
        if row > 0 && cells[row-1][column].priorState == state {
            numberOfNeighbors += 1
        }
        
        // Check upper right cell.
        if column < horizontalCellCount-1 && row > 0 && cells[row-1][column+1].priorState == state {
            numberOfNeighbors += 1
        }
        
        // Check cell to the right.
        if column < horizontalCellCount-1 && cells[row][column+1].priorState == state {
            numberOfNeighbors += 1
        }
        
        // Check bottom-right cell.
        if column < horizontalCellCount-1 && row < verticalCellCount-1 && cells[row+1][column+1].priorState == state {
            numberOfNeighbors += 1
        }
        
        // Check cell below.
        if row < verticalCellCount-1 && cells[row+1][column].priorState == state {
            numberOfNeighbors += 1
        }
        
        // Check bottom-left cell.
        if column > 0 &&  row < verticalCellCount-1 && cells[row+1][column-1].priorState ==  state {
            numberOfNeighbors += 1
        }
        
        return numberOfNeighbors
    }
}


