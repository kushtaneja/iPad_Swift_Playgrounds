//
//  ContentHelpers.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import PlaygroundSupport
import Dispatch

public enum MazeType {
    case empty, simple, medium, hard, impossible
    
    public var layout: MazeLayout {
        switch self {
        case .empty:
            return [
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .start, .floor, .floor, .floor, .floor, .floor, .goal,  .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
            ]
            
        case .simple:
            return [
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .wall,  .wall,  .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .wall,  .floor, .floor, .floor, .floor, .floor],
                [.start, .floor, .floor, .wall,  .floor, .floor, .floor, .goal,  .floor],
                [.floor, .floor, .floor, .wall,  .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .wall,  .wall,  .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
            ]
        
        case .medium:
            return [
                [.floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall,  .wall,  .floor, .wall,  .wall,  .floor],
                [.floor, .floor, .wall,  .wall,  .wall,  .floor, .floor, .wall,  .floor, .floor],
                [.floor, .floor, .wall,  .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.start, .floor, .wall,  .floor, .wall,  .wall,  .wall,  .floor, .floor, .floor],
                [.floor, .floor, .wall,  .floor, .goal,  .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .wall,  .floor, .floor, .wall,  .wall,  .wall,  .floor, .floor],
                [.floor, .floor, .wall,  .wall,  .wall,  .wall,  .floor, .wall,  .floor, .floor],
                [.floor, .floor, .wall,  .floor, .floor, .floor, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .wall,  .floor, .floor, .floor],
            ]

        case .hard:
            return [
                [.wall,  .wall,  .floor, .floor, .floor, .wall,  .floor, .floor, .floor, .floor, .floor],
                [.wall,  .floor, .floor, .wall,  .wall,  .wall,  .floor, .wall,  .floor, .wall,  .floor],
                [.floor, .floor, .wall,  .floor, .floor, .floor, .floor, .wall,  .floor, .wall,  .floor],
                [.floor, .floor, .wall,  .floor, .wall,  .floor, .wall,  .wall,  .wall,  .wall,  .floor],
                [.floor, .wall,   .wall, .floor, .floor, .floor, .wall,  .floor, .floor, .floor, .floor],
                [.floor, .start, .floor, .floor, .floor, .wall,  .floor, .wall,  .wall,  .goal,  .floor],
                [.wall,  .floor, .wall,  .wall,  .wall,  .floor, .floor, .wall,  .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor, .wall,  .floor, .wall,  .floor, .floor],
                [.floor, .wall,  .wall,  .wall,  .wall,  .wall,  .floor, .floor, .floor, .wall,  .floor],
                [.floor, .floor, .floor, .floor, .floor, .floor,  .floor, .wall, .floor, .floor, .floor],
                [.floor, .floor, .wall,  .floor, .floor, .wall,  .floor, .wall,  .wall,  .wall,  .floor],
            ]
            
        case .impossible:
            return [
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .start, .floor, .floor, .wall, .floor, .floor, .goal,  .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
                [.floor, .floor, .floor, .floor, .wall, .floor, .floor, .floor, .floor],
            ]
        }
    }
}

public func showViewController(for mazeType: MazeType, userCode: @escaping ((Maze) -> Void)) {
    let viewController = LiveViewController.instantiateFromStoryboard()
    let layout = mazeType.layout
    
    viewController.configureWith(layout)
    PlaygroundPage.current.liveView = viewController
    
    let mazeRunner = MazeRunner(layout: layout)
    
    // The user code could never end so run it in a background thread to make sure
    // the view controller has chance to render the grid.
    DispatchQueue.global(qos: .background).async {
        mazeRunner.run(userCode: userCode)
        
        DispatchQueue.main.async {
            viewController.play(mazeRunner.steps)
        }
    }
}
