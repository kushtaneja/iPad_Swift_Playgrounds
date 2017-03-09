//
//  LevelScene.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit
import GameController

@objc(LevelScene)
class LevelScene: SKScene, SKPhysicsContactDelegate, InputManagerDelegate {
    // MARK: Properties
    
    private var inputManager: InputManager?
    
    weak var levelSceneDelegate: LevelSceneDelegate?
    
    private var lastUpdateTime: TimeInterval?
    
    // MARK: SKScene
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        physicsWorld.contactDelegate = self
        
        inputManager = InputManager(view: view)
        inputManager?.delegate = self
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        inputManager = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        defer {
            if let lastUpdateTime = lastUpdateTime {
                levelSceneDelegate?.levelSceneDidUpdate(self, deltaTime: currentTime - lastUpdateTime)
            }
            
            lastUpdateTime = currentTime
        }
        
        // Do nothing if this is the first call to update or there's no controller for player 0.
        guard let lastUpdateTime = lastUpdateTime, let controller = inputManager?.controller(for: 0) else { return }
        
        // Calculate the time since the last update call.
        let timeDelta = currentTime - lastUpdateTime
        
        // Get an array of possible input pads.
        let dpads: [GCControllerDirectionPad] = [controller.microGamepad?.dpad, controller.extendedGamepad?.dpad].flatMap { $0 }
        
        // Get the x-delta from the gamepad.
        var directionDelta = Float(0.0)
        for dpad in dpads {
            let absoluteValue = abs(dpad.xAxis.value)
            if absoluteValue > abs(directionDelta) {
                directionDelta = dpad.xAxis.value
            }
        }
        
        // Map the value to a distance to move the paddle by.
        if directionDelta < -0.1 {
            directionDelta = -1000

        }
        else if directionDelta > 0.1 {
            directionDelta = 1000
        }
        
        levelSceneDelegate?.levelScene(self, controllerDidMoveXValue: CGFloat(timeDelta) * CGFloat(directionDelta), yValue: 0.0)
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        // Make sure all the updated balls are still within the walls of the level.
        for ball in updatedBallNodes {
            ball.position.x = max(ball.position.x, level.leftWall.frame.maxX + ball.size.width)
            ball.position.x = min(ball.position.x, level.rightWall.frame.minX - ball.size.width)
            ball.position.y = min(ball.position.y, level.topWall.frame.minY - ball.size.width)
        }
        
        // Clear the array of ball nodes that have had their velocity updated by collisions.
        updatedBallNodes.removeAll()
    }
    
    // MARK: InputManagerDelegate
    
    func inputManager(_ manager: InputManager, didConnect controller: GCController) {}
    
    func inputManager(_ manager: InputManager, didDisconnect controller: GCController) {}
    
    func inputManager(_ manager: InputManager, didBeginDragAt point: CGPoint) {
        guard let view = view else { return }
        
        let pointInScene = view.convert(point, to: self)
        levelSceneDelegate?.levelScene(self, didStartDragAt: pointInScene)
    }
    
    func inputManager(_ manager: InputManager, didDragTo point: CGPoint) {
        guard let view = view else { return }
        
        let pointInScene = view.convert(point, to: self)
        levelSceneDelegate?.levelScene(self, didDragTo: pointInScene)
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        handleBallContact(contact)
        
        levelSceneDelegate?.levelScene(self, beganContactBetween: contact.bodyA, bodyB: contact.bodyB)
    }
    
    // MARK: Convenience
    
    /// An array of nodes for balls that have had their velocity updated due to a collision.
    private var updatedBallNodes = [SKSpriteNode]()
    
    private func handleBallContact(_ contact: SKPhysicsContact) {
        // Check if the contact is for a ball hitting another type of object.
        var ball: SKSpriteNode!
        var other: SKSpriteNode!
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.Ball && contact.bodyB.categoryBitMask != PhysicsCategory.Ball {
            ball = contact.bodyA.node as? SKSpriteNode
            other = contact.bodyB.node as? SKSpriteNode
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Ball && contact.bodyA.categoryBitMask != PhysicsCategory.Ball {
            ball = contact.bodyB.node as? SKSpriteNode
            other = contact.bodyA.node as? SKSpriteNode
        }
        
        guard ball != nil && other != nil && !updatedBallNodes.contains(ball) else { return }
        updatedBallNodes.append(ball)
        
        // Update the velocity of the ball
        if other.physicsBody!.categoryBitMask == PhysicsCategory.Paddle {
            updateVolocity(of: ball, afterContact: contact, withPaddle: other)
        }
        else {
            updateVolocity(of: ball, afterContact: contact, withScenery: other)
        }

        // Move the ball it's no longer in contact with that edges of the contacted body.
        let ballFrame = frameOfSprite(ball)
        let otherFrame = frameOfSprite(other)

        if fabs(contact.contactNormal.dx) > 0.0 {
            if ball.physicsBody!.velocity.dx > 0 {
                ball.position.x = max(ball.position.x, otherFrame.maxX + ballFrame.size.width / 2.0)
            }
            else {
                ball.position.x = min(ball.position.x, otherFrame.minX - ballFrame.size.width / 2.0)
            }
        }
        
        if fabs(contact.contactNormal.dy) > 0.0 {
            if ball.physicsBody!.velocity.dy > 0 {
                ball.position.y = max(ball.position.y, otherFrame.maxY + ballFrame.size.height / 2.0)
            }
            else {
                ball.position.y = min(ball.position.y, otherFrame.minY - ballFrame.size.height / 2.0)
            }
        }
    }
    
    private func updateVolocity(of ball: SKSpriteNode, afterContact contact: SKPhysicsContact, withPaddle paddle: SKSpriteNode) {
        guard fabs(contact.contactNormal.dy) > 0.0 else { return }

        // Bounce the ball back up the screen.
        ball.physicsBody!.velocity.dy *= -1

        // Determine which third of the paddle the ball hit.
        let ballX = convert(ball.position, from: ball.parent!).x
        let paddleX = convert(paddle.position, from: paddle.parent!).x
        
        let minimumDx = CGFloat(100)
        let maximumDx = CGFloat(300)
        let mediumDx = CGFloat(200)
        
        if ballX < paddleX - (paddle.size.width / 6.0) {
            // The ball hit on the left third of the paddle.
            if ball.physicsBody!.velocity.dx > 0.0 {
                // The ball is moving right, use a slow x-axis speed.
                ball.physicsBody!.velocity.dx = minimumDx
            }
            else {
                // The ball is moving left, use a fast x-axis speed.
                ball.physicsBody!.velocity.dx = -maximumDx
            }
        }
        else if ballX > paddleX + (paddle.size.width / 6.0) {
            // The ball hit on the right third of the paddle.
            if ball.physicsBody!.velocity.dx < 0.0 {
                // The ball is moving left, use a slow x-axis speed.
                ball.physicsBody!.velocity.dx = -minimumDx
            }
            else {
                // The ball is moving right, use a fast x-axis speed.
                ball.physicsBody!.velocity.dx = maximumDx
            }
        }
        else {
            // The ball hit the center third of the paddle; use an medium x-axis speed.
            if ball.physicsBody!.velocity.dx < 0.0 {
                ball.physicsBody!.velocity.dx = -mediumDx
            }
            else {
                ball.physicsBody!.velocity.dx = mediumDx
            }
        }
    }
    
    private func updateVolocity(of ball: SKSpriteNode, afterContact contact: SKPhysicsContact, withScenery scenery: SKSpriteNode) {
        // Use the `contactNormal` to determine which edge of the object the ball hit.
        if fabs(contact.contactNormal.dx) > 0.0 {
            // Start the ball moving in the opposite direction.
            ball.physicsBody!.velocity.dx *= -1
            
        }
        
        if fabs(contact.contactNormal.dy) > 0.0 {
            // Start the ball moving in the opposite direction.
            ball.physicsBody!.velocity.dy *= -1
        }
    }
    
    private func frameOfSprite(_ node: SKSpriteNode) -> CGRect {
        let position = self.convert(node.position, from: node.parent!)
        let frame = CGRect(x: position.x - node.size.width / 2.0,
                           y: position.y - node.size.height / 2.0,
                           width: node.size.width,
                           height: node.size.height)
        return frame
    }
}


protocol LevelSceneDelegate: class {
    func levelSceneDidUpdate(_ scene: LevelScene, deltaTime: TimeInterval)
    
    func levelScene(_ scene: LevelScene, controllerDidMoveXValue xValue: CGFloat, yValue: CGFloat)

    func levelScene(_ scene: LevelScene, didStartDragAt point: CGPoint)
    func levelScene(_ scene: LevelScene, didDragTo point: CGPoint)
    
    func levelScene(_ scene: LevelScene, beganContactBetween bodyA: SKPhysicsBody, bodyB: SKPhysicsBody)
}
