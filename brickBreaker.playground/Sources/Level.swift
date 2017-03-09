//
//  Level.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit

/// Represents a Breakout level. The underlying SKScene implementation is hidden from the learner.
public class Level {
    // MARK: Types
    
    public typealias SetupBricks = (Int, Int) -> Void // (columnCount: Int, rowCount: Int)
    
    public typealias BallHitBrick = (Ball, Brick) -> Void

    public typealias BallHitPaddle = (Ball) -> Void

    public typealias BallHitWall = (Ball) -> Void
    
    public typealias BallMissed = (Ball) -> Void
    
    public enum Background {
        case colored(UIColor)
        case gradient(UIColor, UIColor)
        case image(UIImage)
    }
    
    enum State {
        case setup
        case ballOnPaddle
        case ballInPlay
        case paused
        case ended
    }
    
    private struct NodeName {
        static let BricksContainer = "BricksContainer"
        static let PaddleContainer = "PaddleContainer"
        static let Brick = "Brick"
        static let LeftWall = "Walls/LeftWall"
        static let RightWall = "Walls/RightWall"
        static let TopWall = "Walls/TopWall"
    }
    
    // MARK: Internal properties
    
    var scene: LevelScene
    
    fileprivate var bricksContainer: SKSpriteNode
    
    fileprivate var paddleContainer: SKSpriteNode
    
    let leftWall: SKSpriteNode
    
    let rightWall: SKSpriteNode
    
    let topWall: SKSpriteNode
    
    var state: State = .ended {
        didSet {
            switch state {
            case .setup:
                // Clear any old content.
                bricksContainer.removeAllChildren()
                paddleContainer.removeAllChildren()
                
                // Setup the bricks and the paddle.
                setupBricks!(brickColumnCount, brickRowCount)
                setupPaddle()
                guard !bricks.isEmpty else { fatalError("No bricks have been added to the level") }
                
            case .ballOnPaddle:
                // Remove any balls
                for ball in balls {
                    ball.spriteNode.removeFromParent()
                }
                
                balls = [setupBall(on: paddle)]
                
            case .ballInPlay, .paused, .ended:
                break
                
            }
        }
    }
    
    // MARK: Public properties
    
    public let brickColumnCount = 8
    
    public let brickRowCount = 12
    
    /// The size of bricks in SpriteKit points.
    public let brickSize: CGSize
    
    public var bricks = [Brick]()
    
    public private(set) var balls = [Ball]()
    
    public private(set) var paddle = Paddle()
    
    fileprivate var paddleTouchOffset = CGPoint.zero
    
    public var background: Background = .colored(.black)
    
    public var setupBricks: SetupBricks?
    
    public var ballHitBrick: BallHitBrick?
    
    public var ballHitPaddle: BallHitPaddle?
    
    public var ballHitWall: BallHitWall?
    
    public var ballMissed: BallMissed?
    
    // MARK: Initialization
    
    public init() {
        scene = SKScene(fileNamed: "Level") as! LevelScene

        bricksContainer = scene.childNode(withName: NodeName.BricksContainer) as! SKSpriteNode
        paddleContainer = scene.childNode(withName: NodeName.PaddleContainer) as! SKSpriteNode
        leftWall = scene.childNode(withName: NodeName.LeftWall) as! SKSpriteNode
        rightWall = scene.childNode(withName: NodeName.RightWall) as! SKSpriteNode
        topWall = scene.childNode(withName: NodeName.TopWall) as! SKSpriteNode
        
        brickSize = CGSize(width: bricksContainer.size.width / CGFloat(brickColumnCount),
                           height: bricksContainer.size.height / CGFloat(brickRowCount))
        
        scene.levelSceneDelegate = self
        
        // Set default callback implementations.
        ballHitBrick = { ball, brick in
            brick.strength -= 1
            
            if brick.strength <= 0 {
                self.play(.pop)
                self.remove(brick, withEffect: .zoomOut)
            }
        }
        
        ballHitPaddle = { ball in
            self.play(.blip)
        }
        
        ballHitWall = { ball in
            self.play(.sonar)
        }
        
        ballMissed = { ball in
            if self.balls.isEmpty {
                self.play(.radiant)
            }
        }
    }
    
    // MARK: Setup
    
    private func setupPaddle() {
        let node = paddle.spriteNode
        
        // Size the paddle correctly.
        let ratio = node.size.width / node.size.height
        node.size.height = paddleContainer.size.height
        node.size.width = node.size.height * ratio
        
        // Set the paddle's physics body.
        let physicsBody = SKPhysicsBody(rectangleOf: node.size)
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = PhysicsCategory.Paddle
        node.physicsBody = physicsBody
        
        paddleContainer.addChild(node)
        
        // Constrain the paddle to its container.
        node.constraints = [
            SKConstraint.positionY(SKRange(constantValue: node.position.y)),
            SKConstraint.positionX(SKRange(lowerLimit: (-paddleContainer.size.width / 2.0) + (node.size.width / 2.0))),
            SKConstraint.positionX(SKRange(upperLimit: (paddleContainer.size.width / 2.0) - (node.size.width / 2.0)))
        ]
    }
    
    private func setupBall(on paddle: Paddle) -> Ball {
        // Create a new ball.
        let ball = Ball()
        
        // Set the ball's physics body.
        let physicsBody = SKPhysicsBody(circleOfRadius: brickSize.height / 2.5)
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 1
        physicsBody.allowsRotation = false
        physicsBody.angularDamping = 0
        physicsBody.density =  0.1
        physicsBody.linearDamping = 0
        physicsBody.categoryBitMask = PhysicsCategory.Ball
        physicsBody.collisionBitMask = 0
        physicsBody.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Wall | PhysicsCategory.Brick
        ball.spriteNode.physicsBody = physicsBody
        
        scene.addChild(ball.spriteNode)
        
        // Constrain the ball's position to the paddle
        let xConstraint = SKConstraint.positionX(SKRange(constantValue: 0))
        xConstraint.referenceNode = paddle.spriteNode
        let yConstraint = SKConstraint.positionY(SKRange(constantValue: paddle.spriteNode.size.height / 2.0 + ball.spriteNode.size.height / 2.0))
        yConstraint.referenceNode = paddle.spriteNode
        
        ball.spriteNode.constraints = [xConstraint, yConstraint]
        
        return ball
    }
    
    func launchBalls() {
        for ball in balls {
            guard let constraints = ball.spriteNode.constraints, !constraints.isEmpty else { continue }
            
            ball.spriteNode.constraints = nil
            ball.spriteNode.physicsBody?.velocity = CGVector(dx: 200.0, dy: 450.0)
        }
        
        state = .ballInPlay
    }
    
    // MARK: Brick lookup and effects.
    
    public func place(_ brick: Brick, at coordinate: Coordinate) {
        guard brick.spriteNode.parent == nil else { fatalError("The brick has already been added to the level") }
        
        brick.spriteNode.name = NodeName.Brick
        brick.spriteNode.position = convertCoordinateToPosition(coordinate)
        brick.spriteNode.size = brickSize
        brick.coordinate = coordinate
        
        // Set the brick's physics body.
        let physicsBody = SKPhysicsBody(rectangleOf: brickSize)
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = PhysicsCategory.Brick
        brick.spriteNode.physicsBody = physicsBody
        
        bricksContainer.addChild(brick.spriteNode)
        bricks.append(brick)
    }
    
    public func brick(at coordinate: Coordinate) -> Brick? {
        return bricks.filter( { brick in
            return brick.coordinate == coordinate
        }).first
    }
    
    public func remove(_ brick: Brick, withEffect effect: Effect) {
        brick.spriteNode.physicsBody?.categoryBitMask = 0
        effect.apply(to: brick.spriteNode)
        
        // Remove the brick from the bricks array.
        for (index, object) in bricks.enumerated() {
            if object.spriteNode == brick.spriteNode {
                bricks.remove(at: index)
                break
            }
        }
    }
    
    public func remove(_ ball: Ball, withEffect effect: Effect) {
        ball.spriteNode.physicsBody?.categoryBitMask = 0
        effect.apply(to: ball.spriteNode)
        
        // Remove the ball from the balls array.
        for (index, object) in balls.enumerated() {
            if object.spriteNode == ball.spriteNode {
                balls.remove(at: index)
                break
            }
        }
    }
    
    // MARK: Other cool stuff
    
    public func play(_ sound: Sound, completion: (() -> Void)? = nil) {
        let file = "\(sound.rawValue).m4a"
        let play = SKAction.playSoundFileNamed(file, waitForCompletion: true)
        let fireCompletion = SKAction.run {
            if let completion = completion {
                completion()
            }
        }
        
        scene.run(SKAction.sequence([play, fireCompletion]))
    }
    
    // MARK: Convenience
    
    func convertCoordinateToPosition(_ coordinate: Coordinate) -> CGPoint {
        var position = CGPoint(x: brickSize.width * CGFloat(coordinate.column), y: brickSize.height * CGFloat(coordinate.row))
        
        // Offset the position for the default SKNode anchor point.
        position.x += brickSize.width / 2.0
        position.y += brickSize.height / 2.0
        
        return position
    }
    
    func coordinate(of node: SKNode) -> Coordinate? { return nil }
}

extension Level: LevelSceneDelegate {
    func levelScene(_ scene: LevelScene, didStartDragAt point: CGPoint) {
        paddleTouchOffset = paddle.spriteNode.convert(point, from: scene)
    }
    
    func levelScene(_ scene: LevelScene, didDragTo point: CGPoint) {
        var newPaddlePoint = paddleContainer.convert(point, from: scene)
        newPaddlePoint.x -= paddleTouchOffset.x
        newPaddlePoint.y = paddle.spriteNode.position.y
        
        let move = SKAction.move(to: newPaddlePoint, duration: 0.0)
        paddle.spriteNode.run(move)
    }
    
    func levelScene(_ scene: LevelScene, controllerDidMoveXValue xValue: CGFloat, yValue: CGFloat) {
        var newPaddlePoint = paddle.spriteNode.position
        newPaddlePoint.x += xValue
        
        let move = SKAction.move(to: newPaddlePoint, duration: 0.0)
        paddle.spriteNode.run(move)
    }
    
    func levelScene(_ scene: LevelScene, beganContactBetween bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
        // Only call collision callbacks when the ball is in play.
        guard state == .ballInPlay else { return }
        
        // Determine which two nodes contacted
        var hitBall: Ball?
        var hitBrick: Brick?
        var hitPaddle: Paddle?
        
        for ball in balls {
            if bodyA.node == ball.spriteNode || bodyB.node == ball.spriteNode {
                hitBall = ball
                break
            }
        }
        
        for brick in bricks {
            if bodyA.node == brick.spriteNode || bodyB.node == brick.spriteNode {
                hitBrick = brick
                break
            }
        }
        
        if bodyA.node == paddle.spriteNode || bodyB.node == paddle.spriteNode {
            hitPaddle = paddle
        }
        
        let hitWall = bodyA.categoryBitMask == PhysicsCategory.Wall || bodyB.categoryBitMask == PhysicsCategory.Wall
        
        // Call the appropriate callback.
        if let ball = hitBall, let brick = hitBrick {
            self.ballHitBrick?(ball, brick)
        }
        else if let ball = hitBall, hitPaddle != nil {
            self.ballHitPaddle?(ball)
        }
        else if let ball = hitBall, hitWall {
            self.ballHitWall?(ball)
        }
    }
    
    func levelSceneDidUpdate(_ scene: LevelScene, deltaTime: TimeInterval) {
        // Check if any balls have fallen out of the scene.
        let sceneBottom = scene.size.height * -scene.anchorPoint.y
        
        let ballsToRemove = balls.filter { ball in
            var ballTop = scene.convert(ball.spriteNode.position, from: ball.spriteNode.parent!).y
            ballTop += ball.spriteNode.size.height
            
            return ballTop < sceneBottom
        }
        
        for ball in ballsToRemove {
            remove(ball, withEffect: .none)
            ballMissed?(ball)
        }
        
        if balls.isEmpty {
            state = .ended
        }
    }
}
