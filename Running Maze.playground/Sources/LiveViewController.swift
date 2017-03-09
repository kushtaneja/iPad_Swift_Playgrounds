//
//  LiveViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit
import PlaygroundSupport

@objc(LiveViewController)
public class LiveViewController: UIViewController {
    // MARK: Properties
    
    private static let topPadding: CGFloat = 20
    
    private static let stepDelay: TimeInterval = 0.1
    
    @IBOutlet weak var contentContainer: UIView!
    
    @IBOutlet weak var gridView: GridView!
    
    @IBOutlet weak var searchCountLabel: UILabel!
    
    @IBOutlet weak var pathLengthLabel: UILabel!

    @IBOutlet var verticalStackViews: [UIStackView]!
    
    @IBOutlet var horizontalStackViews: [UIStackView]!
    
    @IBOutlet var seperatorView: UIView!
    
    @IBOutlet var pathLengthView: UIView!
    
    var maze: Maze? {
        didSet {
            if let maze = maze {
                configureView(with: maze)
            }
        }
    }
    
    private enum State {
        case invalid, preparingMaze, runningUserCode, completed
    }
    
    private var state = State.invalid {
        didSet {
            if isViewLoaded {
                configureStackViews(for: view.bounds.size)
            }
        }
    }
    
    // MARK: View Controller LifeCycle

    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let maze = maze {
            configureView(with: maze)
        }
    }
    
    public override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if let parent = parent, parent.isViewLoaded {
//            NSLayoutConstraint.activate([
//                contentContainer.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: LiveViewController.topPadding),
//                contentContainer.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor),
//            ])
//            
            configureStackViews(for: view.bounds.size)
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.configureStackViews(for: size)
        }, completion: nil)
    }
    
    public override func viewWillLayoutSubviews() {
        configureStackViews(for: view.bounds.size)
        super.viewWillLayoutSubviews()
    }
    
    // MARK: Configuration
    
    public func configureWith(_ layout: MazeLayout) {
        maze = Maze(layout: layout)
    }
    
    private func configureView(with maze: Maze) {
        guard isViewLoaded else { return }
        
        state = .preparingMaze
        
        gridView.setInnerLineStyle(GridView.LineStyle(width: 2.0, color: UIColor(red: 172/255.0, green: 138/255.0, blue: 47/255.0, alpha: 1.0)),
                                   outerLineStyle: GridView.LineStyle(width: 2.0, color: UIColor(red: 172/255.0, green: 138/255.0, blue: 47/255.0, alpha: 1.0)))
        gridView.setColumnCount(maze.columnCount, rowCount: maze.rowCount)
        
        // Create maze nodes.
        for (coordinate, details) in maze.coordinateDetails {
            guard let gridNode = gridView.tile(at: coordinate) else { continue }
            let node = MazeNode(color: .clear, size: CGSize(width: gridView.tileDimension, height: gridView.tileDimension))
            gridNode.addChild(node)
            node.coordinateDetails = details
            
            // If this is the goal node, make sure it appears above everything else.
            if details.type == .goal {
                node.zPosition = 1000
            }
        }
        
        // Clear the counters.
        maze.searchCount = 0
        searchCountLabel.text = "0"
        pathLengthLabel.text = "-"
    }

    private func configureStackViews(for size: CGSize) {
        // Determine the current and required configuration for the stack views.
        let viewIsPortrait = size.width < size.height
        let currentLayoutIsPortrait = verticalStackViews.first!.axis == .vertical

        // Toggle visibility of views based on the state.
        if state == .completed {
            seperatorView.isHidden = viewIsPortrait
            pathLengthView.isHidden = false
        }
        else {
            seperatorView.isHidden = true
            pathLengthView.isHidden = true
        }

        // Update the stack view axis.
        if viewIsPortrait != currentLayoutIsPortrait {
            for stackView in verticalStackViews {
                stackView.axis = viewIsPortrait ? .vertical : .horizontal
            }
            for stackView in horizontalStackViews {
                stackView.axis = viewIsPortrait ? .horizontal : .vertical
            }
        }
    }
    
    // MARK: Public interface
    
    public static func instantiateFromStoryboard() -> LiveViewController {
        let bundle = Bundle(for: LiveViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! LiveViewController
    }

    public func play(_ steps: [MazeRunner.Step]) {
        guard let maze = maze, state == .preparingMaze else { return }
        state = .runningUserCode

        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        // Create operations for each step of the search.
        for step in steps {
            operationQueue.addOperation {
                // Update the maze with the details in the next step.
                maze.setDetails(step.coordinateDetails, for: step.coordinate)
                
                // Update the nodes on the main thread.
                DispatchQueue.main.sync {
                    let node = self.gridView.tile(at: step.coordinate)?.children.first as? MazeNode
                    node?.coordinateDetails = step.coordinateDetails
                    self.searchCountLabel.text = "\(step.searchCount)"
                }
                
                // If the step shows an animated change, sleep for a short period.
                if step.isAnimated {
                    Thread.sleep(until: Date().addingTimeInterval(LiveViewController.stepDelay))
                }
            }
        }
        
        // Add an operation to pause while animations complete.
        operationQueue.addOperation {
            Thread.sleep(until: Date().addingTimeInterval(1.0))
        }
        
        // Create an operation to plot the calculated path through the maze after all the steps have been performed.
        let plotPath = BlockOperation {
            let pathDetails = maze.path
            
            if let hint = pathDetails.hint {
                // Pass the hint back to the user.
//                PlaygroundPage.current.assessmentStatus = PlaygroundPage.AssessmentStatus.fail(hints: [hint], solution: nil)
            }
            
            if let coordinates = pathDetails.coordinates {
                // Build a bezier path that represents the path through the maze
                let path = UIBezierPath()
                path.move(to: self.gridView.tile(at: maze.start)!.position)
                
                for coordinate in coordinates {
                    guard coordinate != maze.start else { continue }
                    path.addLine(to: self.gridView.tile(at: coordinate)!.position)
                }
                
                let routeNode = SKShapeNode(path: path.cgPath)
                routeNode.lineWidth = 10
                
                self.gridView.scene.addChild(routeNode)
                self.pathLengthLabel.text = "\(coordinates.count - 1)" // -1 to not include the start coordinate.
            }
            else {
                self.pathLengthLabel.text = "∞"
            }
            
            self.state = .completed
        }
        
        // The `plotPath` operation should be dependant on the last search step operation.
        plotPath.addDependency(operationQueue.operations.last!)
        OperationQueue.main.addOperation(plotPath)
        
        // Add an operation to finish playground exectution.
        let finishExecution = BlockOperation {
            // Add a delay if there are hints to show to allow the hint bubble time to animate.
            let pathDetails = maze.path
            let delay = pathDetails.hint == nil ? 0.1 : 0.5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                PlaygroundPage.current.finishExecution()
            }
        }
        
        // The `finishExection` operation should be dependant on the `plotPath` operation.
        finishExecution.addDependency(plotPath)
        OperationQueue.main.addOperation(finishExecution)
    }
}
