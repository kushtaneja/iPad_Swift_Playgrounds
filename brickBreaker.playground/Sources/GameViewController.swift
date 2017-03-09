//
//  GameViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit
import GameController
import PlaygroundSupport

@objc(GameViewController)
public class GameViewController: UIViewController{
    
    @IBOutlet var safeArea: UIView!

    @IBOutlet var gameContainer: SKView!
    
    public var game: Game? {
        didSet {
            if let game = game {
                present(game)
            }
        }
    }
    
    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSLayoutConstraint.activate([
////            safeArea.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20),
////            safeArea.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor)
//        ])
        
        gameContainer.constrainToCenterOfParent(withAspectRatio: 1.0)

        if let game = game {
            present(game)
        }
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Convenience
    
    private func present(_ game: Game) {
        guard isViewLoaded else { return }
        
        let level = game.currentLevel
        level.scene.scaleMode = .aspectFit
        gameContainer.presentScene(level.scene)
        
        assertScale(of: level.scene)

        level.state = .setup
        level.state = .ballOnPaddle
        
        level.play(.crystal) {
            level.launchBalls()
        }
    }
    
    /// Checks that a node and all its children have a scale factor of 1.
    private func assertScale(of node: SKNode, includingChildren: Bool = true) {
        assert(node.xScale == 1 && node.xScale == 1, "Expected nodes to be loaded with a scale of 1")
        
        if includingChildren {
            for child in node.children {
                assertScale(of: child)
            }
        }
    }
}

public extension GameViewController {
    class func loadFromStoryboard() -> GameViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController() as! GameViewController
    }
}
