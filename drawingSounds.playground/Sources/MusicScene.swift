// 
//  MusicScene.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit
import AVFoundation
import UIKit

class MusicScene: SKScene {
        
    var tapGestureRecognizers: [UITapGestureRecognizer] = []
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    var loop: Loop?
    
    // MARK: Visual components
    
    var emitters: [SKEmitterNode] = []
    
    var leftSide: SoundBoard!
    var rightSide: SoundBoard!
    
    var suggestedVerticalPaneSize: CGSize {
        return CGSize(width: size.width / 2.0, height: size.height)
    }
    

    var makeLeftSoundProducer: (() -> SoundProducer)? {
        didSet {
            leftSide.soundProducer = makeLeftSoundProducer?()
        }
    }
    
    var makeRightSoundProducer: (() -> SoundProducer)? {
        didSet {
            rightSide.soundProducer = makeRightSoundProducer?()
        }
    }

    override func didMove(to view: SKView) {
        setUpSideViews()
        
        tapGestureRecognizers = (1...5).map { idx in
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
            tapRecognizer.numberOfTouchesRequired = idx
            view.addGestureRecognizer(tapRecognizer)
            return tapRecognizer
        }
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        view.addGestureRecognizer(panRecognizer)
        panGestureRecognizer = panRecognizer
        
        emitters = (1...10).map { idx in
            let emitter = SKEmitterNode(fileNamed: "SparkParticle")!
            emitter.position = CGPoint(x: frame.midX, y: frame.midY)
            emitter.particleBirthRate = 0.0
            emitter.targetNode = self
            self.addChild(emitter)
            return emitter
        }
    }
    
    func setUpSideViews() {
        let leftView = SKSpriteNode(texture: nil, color: .blue, size: suggestedVerticalPaneSize)
        leftSide = SoundBoard(spriteNode: leftView)
        leftSide.firstKeyColor = SKColor(red: 0.75, green: 0.86, blue: 0.38, alpha: 1.0)
        leftSide.secondKeyColor = SKColor(red: 0.07, green: 0.53, blue: 0.49, alpha: 1.0)
        self.addChild(leftView)
        
        let rightView = SKSpriteNode(texture: nil, color: .red, size: suggestedVerticalPaneSize)
        rightSide = SoundBoard(spriteNode: rightView)
        rightSide.firstKeyColor = SKColor(red: 0.41, green: 0.06, blue: 0.84, alpha: 1.0)
        rightSide.secondKeyColor = SKColor(red: 0.75, green: 0.10, blue: 0.69, alpha: 1.0)
        self.addChild(rightView)
        
        handleViewLayout(animated: false)
    }
    
    func handleViewLayout(animated: Bool) {
        if view != nil {
            let leftView = leftSide.spriteNode
            leftView.size = suggestedVerticalPaneSize
            leftView.position = CGPoint(x: size.width * 0.25, y: frame.midY)
            leftSide.layoutNoteSprites()
            
            let rightView = rightSide.spriteNode
            rightView.size = suggestedVerticalPaneSize
            rightView.position = CGPoint(x: size.width * 0.75, y: frame.midY)
            rightSide.layoutNoteSprites()
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        handleViewLayout(animated: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func convertedTouchPoints(fromRecognizer recognizer: UIGestureRecognizer, forNode node: SKSpriteNode) -> [CGPoint] {
        var convertedTouchPoints: [CGPoint] = []
        
        for i in 0 ..< recognizer.numberOfTouches {
            let touchPoint = convertPoint(fromView: recognizer.location(ofTouch: i, in: view))
            
            if node.contains(touchPoint) {
                var touchPointInNode = convert(touchPoint, to: node)
                // Note: This convert sets the point at 0,0 in the center of the touched node. This is converting to to the UIKit format.
                touchPointInNode = CGPoint(x: touchPointInNode.x + node.size.width/2.0, y: touchPointInNode.y + node.size.height/2.0)
                convertedTouchPoints.append(touchPointInNode)
            }
        }
        return convertedTouchPoints
    }
    
    func updateEmitters(fromRecognizer recognizer: UIGestureRecognizer) {
        for i in 0 ..< recognizer.numberOfTouches {
            
            let touchPoint = convertPoint(fromView: recognizer.location(ofTouch: i, in: view))
            
            if i < emitters.count {
                let emitter = emitters[i]
                emitter.position = touchPoint
                emitter.particleBirthRate = 300.0
                
                let wait = SKAction.wait(forDuration: 0.1)
                let stopParticleBirth = SKAction.run({
                    emitter.particleBirthRate = 0.0
                })
                
                let sequence = SKAction.sequence([wait, stopParticleBirth])
                emitter.run(sequence, withKey: "fadeParticles")
            }
        }
    }
    
    // MARK: User Input

    func handlePan(recognizer: UIPanGestureRecognizer) {
        updateEmitters(fromRecognizer: recognizer)
        
        // We need to convert and package along the touches for each side to process.
        let leftSideTouchPoints: [CGPoint] = convertedTouchPoints(fromRecognizer: recognizer, forNode: leftSide.spriteNode)
        let rightSideTouchPoints: [CGPoint] = convertedTouchPoints(fromRecognizer: recognizer, forNode: rightSide.spriteNode)
        
        leftSide.handlePan(withTouchPoints: leftSideTouchPoints, recognizerState: recognizer.state)
        rightSide.handlePan(withTouchPoints: rightSideTouchPoints, recognizerState: recognizer.state)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        updateEmitters(fromRecognizer: recognizer)
        
        let leftSideTouchPoints: [CGPoint] = convertedTouchPoints(fromRecognizer: recognizer, forNode: leftSide.spriteNode)
        let rightSideTouchPoints: [CGPoint] = convertedTouchPoints(fromRecognizer: recognizer, forNode: rightSide.spriteNode)
        
        leftSide.handleTap(withTouchPoints: leftSideTouchPoints, recognizerState: recognizer.state)
        rightSide.handleTap(withTouchPoints: rightSideTouchPoints, recognizerState: recognizer.state)
    }
}
