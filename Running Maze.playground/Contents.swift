//: Playground - noun: a place where people can play

public func start(mazeType: MazeType) {
    showViewController(for: mazeType, userCode: findPath)
}

//#-end-hidden-code
//#-editable-code
func findPath(in maze: Maze) {
    // Create a queue of coordinates and add the maze's start coordinate.
    var queue = CoordinateQueue()
    queue.add(maze.start)
    
    // Keep searching coordinates until the queue is empty.
    while !queue.isEmpty {
        let coord = queue.popFirstCoordinate()
        
        // Get the first neighbor.
        let neighbors = maze.searchNeighbors(of: coord)
        if neighbors.isEmpty {
            continue
        }
        let neighbor = neighbors[0]
        
        // If the neighbor coordinate is the goal tile, the path is complete.
        if neighbor == maze.goal {
            return
        }
        
        // Add the neighbor to the queue to search.
        queue.add(neighbor)
    }
}
//#-end-editable-code

/*:
 Check how the algorithm behaves in different situations by changing the maze type.
 */
//#-editable-code
start(mazeType: .simple)
//#-end-editable-code
//#-hidden-code
//#-end-hidden-code
