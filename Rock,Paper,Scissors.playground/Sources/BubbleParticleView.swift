//
//  BubbleParticleView.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class BubbleParticleView: UIView {
    
    var birthrate: Float = 6
    
    var scaleRange: CGFloat = 2
    
    var color = UIColor.clear
    
    private var emitter: CAEmitterLayer {
        return layer as! CAEmitterLayer
    }
    
    override class var layerClass: Swift.AnyClass {
        return CAEmitterLayer.self
    }
    
    init(frame: CGRect, color aColor: UIColor) {
        super.init(frame: frame)
        
        color = aColor
        emitter.scale = 0.3
        emitter.emitterShape = kCAEmitterLayerRectangle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil else {
            return
        }
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named:"Particle")!.cgImage
        emitterCell.color = color.cgColor
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let range: Float = 0.7
            if red > green && red > blue {
                emitterCell.redRange = range
            }
            else if green > red && green > blue {
                emitterCell.greenRange = range
            }
            else {
                emitterCell.blueRange = range
            }
        }
        
        emitterCell.birthRate = birthrate
        emitterCell.lifetime = 3
        emitterCell.velocity = 40
        emitterCell.velocityRange = 20
        emitterCell.speed = 2 - (birthrate * 0.08)
        emitterCell.scaleRange = scaleRange
        emitterCell.alphaRange = 2
        emitterCell.emissionRange = CGFloat(M_PI * 2)
        emitter.emitterCells = [emitterCell]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2.0
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emitter.emitterSize = CGSize(width: bounds.width / 4, height: bounds.height / 4)
    }
}
