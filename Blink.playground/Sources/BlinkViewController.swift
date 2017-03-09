// 
//  BlinkViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit
import PlaygroundSupport

@objc(BlinkViewController)
public class BlinkViewController: UIViewController{
    
    let scene = BlinkScene()
    
    @IBOutlet weak var skView: SKView!
    
    @IBOutlet weak var stepButton: UIButton!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var playPauseWidthConstraint: NSLayoutConstraint!
    
    public var simulation: Simulation? {
        get {
            return scene.simulation
        }
        set(newValue) {
            scene.simulation = newValue
            if let simulation = simulation, simulation.isPaused {
                pauseSimulation()
            }
            else {
                resumeSimulation()
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scene.backgroundColor = SKColor.clear
        scene.scaleMode = .resizeFill
        
        skView.preferredFramesPerSecond = 60
        skView.presentScene(scene)
        
//        NSLayoutConstraint.activate([
//            resetButton.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 15.0),
//            playPauseButton.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 15.0),
//            stepButton.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 15.0),
//        ])
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // For testing as an iPad app.
        #if DEBUG
            simulation = makeSimulation()
        #endif
    }
    
    @IBAction func stepTapped(_ sender: AnyObject) {
        pauseSimulation()
        scene.updateSimulationCycle()
    }
    
    @IBAction func playPauseTapped(_ sender: AnyObject) {
        if let simulation = simulation, simulation.isPaused {
            resumeSimulation()
        }
        else {
            pauseSimulation()
        }
    }
    
    func resumeSimulation() {
        if let simulation = simulation {
            simulation.isPaused = false
        }
        playPauseButton.setTitle("Pause Simulation", for: [])
        self.playPauseWidthConstraint.constant = 160.0
    }
    
    func pauseSimulation() {
        if let simulation = simulation {
            simulation.isPaused = true
        }
        playPauseButton.setTitle("Resume Simulation", for: [])
        self.playPauseWidthConstraint.constant = 168.0
    }
    
    @IBAction func resetTapped(_ sender: AnyObject) {
        scene.resetToInitialState()
    }
    
    // MARK: User Code Simulation
    
    // This is simulating the user code that is in the playground page for testing.
    func makeSimulation() -> Simulation {
        
        let simulation = Simulation()
        simulation.cellDimension = 36
        simulation.placePattern(.pulsar, atColumn: 3, row: 3)
        simulation.speed = 2
        
        simulation.set("😀", forState: .alive)
        simulation.set("👻", forState: .dead)
        simulation.set(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), forState: .idle)
        
        simulation.configureCell = configureCell
        
        return simulation
    }
    
    func configureCell(_ cell: Cell) {
        
        switch cell.state {
        case .alive:
            if cell.numberOfAliveNeighbors < 2 {
                cell.state = .dead
            } else if cell.numberOfAliveNeighbors > 3 {
                cell.state = .dead
            }
        case .dead:
            if cell.numberOfAliveNeighbors == 3 {
                cell.state = .alive
            }
        case .idle:
            if cell.numberOfAliveNeighbors == 3 {
                cell.state = .alive
            }
        }
    }
    // End User Code Simulation
}


