//
//  PlayerViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import CoreGraphics

class PlayerViewController: UIViewController, CAAnimationDelegate {
    
    enum Defaults {
        static let prizeTimerInterval: TimeInterval = 2
        
        static let animationIDKey = "id"

        static let strokeEndAnimationKey = "strokeEnd"
        
        static let increaseWinRingAnimationValue = "increaseWinRingAnimationValue"
    }

    var game: Game
    
    let player: Player
    
    let actionView = ActionView()
    
    private let ringGradientMaskLayer = CAGradientLayer()
    
    let roundsWonLayer = CAShapeLayer()
    
    let innerCircleShapeLayer = CAShapeLayer()
    
    let trackShapeLayer = CAShapeLayer()
    
    var prizeLabel: UILabel?
    
    private var winnerParticleView: BubbleParticleView?

    private var winnerTimer: Timer?

    var ringTrackMultiplier: CGFloat = 0
    
    var ringTrackStrokeWidth: CGFloat = 0

    var innerCircleMultiplier: CGFloat = 0
    
    var action: Action {
        get {
            return player.action
        }
        set {
            actionView.action = newValue
            player.action = newValue
        }
    }
    
    init(player: Player, game: Game) {
        self.player = player
        self.game = game
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        func path(withRadius radius: CGFloat) -> CGPath {
            let centerPoint = CGPoint(x: view.frame.width / 2 , y: view.frame.height / 2)
            return UIBezierPath(arcCenter:centerPoint, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI_2 * 3), clockwise: true).cgPath
        }
        
        ringTrackStrokeWidth = floor(view.bounds.width * ringTrackMultiplier)
        
        let defaultRadius = floor((view.bounds.width - ringTrackStrokeWidth) / 2)
        let innerCircleSize = floor(view.bounds.width * innerCircleMultiplier)
        
        innerCircleShapeLayer.path = path(withRadius: (innerCircleSize / 2))
        
        trackShapeLayer.path = path(withRadius: defaultRadius)
        trackShapeLayer.lineWidth = ringTrackStrokeWidth
        
        roundsWonLayer.path = path(withRadius: defaultRadius)
        roundsWonLayer.lineWidth = ringTrackStrokeWidth
        roundsWonLayer.strokeEnd = completionPercentage(withWins: player.winCount)
    }

    func setupViews() {
        view.layer.addSublayer(trackShapeLayer)
        trackShapeLayer.fillColor = nil
        trackShapeLayer.strokeColor = game.outerRingColor.cgColor
        trackShapeLayer.strokeStart = 0.0
        trackShapeLayer.strokeEnd = 1
        trackShapeLayer.opacity = 0.7
        
        view.layer.addSublayer(innerCircleShapeLayer)
        innerCircleShapeLayer.lineWidth = 1
        innerCircleShapeLayer.strokeColor = UIColor(white: 0.85, alpha: 1).cgColor
        innerCircleShapeLayer.fillColor = game.innerCircleColor.cgColor
        
        let playerColor = player.color.cgColor

        roundsWonLayer.strokeColor = playerColor
        roundsWonLayer.lineCap = kCALineCapRound
        roundsWonLayer.fillColor = nil
        view.layer.addSublayer(roundsWonLayer)

        view.addSubview(actionView)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.label.textColor = player.color
        actionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        actionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        actionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: innerCircleMultiplier).isActive = true
        actionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: innerCircleMultiplier).isActive = true
    }
    
    func resetToDefault() {
        actionView.alpha = 1
        view.alpha = 1
        prizeLabel?.removeFromSuperview()
        prizeLabel = nil
        winnerTimer?.invalidate()
        winnerTimer = nil
    }
    
    // Used by subclass
    func prepareViewsForCurrentStatus() { }
    
    func gameLose() {
        if game.shouldDimLosers {
            view.alpha = 0.55
        }
    }
    
    private func completionPercentage(withWins winCount: UInt) -> CGFloat {
        return game.roundsToWin > 0 ? CGFloat(winCount) / CGFloat(game.roundsToWin) : 0.0
    }

    func gameEnded() {
        guard player.winCount >= game.roundsToWin else {
            gameLose()
            return
        }
        
        winnerTimer = Timer.scheduledTimer(withTimeInterval: Defaults.prizeTimerInterval, repeats: false) { _ in
            self.actionView.alpha = 0
            
            let prizeLabel = UILabel()
            self.prizeLabel = prizeLabel
            self.view.addSubview(prizeLabel)
            
            prizeLabel.translatesAutoresizingMaskIntoConstraints = false
            prizeLabel.centerXAnchor.constraint(equalTo: self.actionView.centerXAnchor).isActive = true
            prizeLabel.centerYAnchor.constraint(equalTo: self.actionView.centerYAnchor).isActive = true
            prizeLabel.widthAnchor.constraint(equalTo: self.actionView.widthAnchor, multiplier: 0.7).isActive = true
            prizeLabel.heightAnchor.constraint(equalTo: self.actionView.heightAnchor, multiplier: 0.7).isActive = true
            prizeLabel.font = UIFont.systemFont(ofSize: 300, weight: 5)
            prizeLabel.text = self.game.prize
            prizeLabel.adjustsFontSizeToFitWidth = true
            prizeLabel.minimumScaleFactor = 0.01
            prizeLabel.textAlignment = .center
            prizeLabel.baselineAdjustment = .alignCenters
            prizeLabel.numberOfLines = 1
            prizeLabel.transform = prizeLabel.transform.scaledBy(x: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 8, options: .curveEaseInOut, animations: {
                prizeLabel.transform = prizeLabel.transform.scaledBy(x: 10, y: 10)
            })
        }
    }
    
    func increaseWinCount() {
        let animation = CABasicAnimation(keyPath: Defaults.strokeEndAnimationKey)
        animation.beginTime = CACurrentMediaTime()
        animation.duration = 0.3
        animation.fromValue = completionPercentage(withWins: player.winCount)
        animation.delegate = self
        animation.setValue(Defaults.increaseWinRingAnimationValue, forKey: Defaults.animationIDKey)
        player.winCount += 1
        animation.toValue = completionPercentage(withWins: player.winCount)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        roundsWonLayer.strokeEnd = completionPercentage(withWins: player.winCount)
        roundsWonLayer.add(animation, forKey: Defaults.strokeEndAnimationKey)
    }
    
    func animateFullRing() {
        let animation = CABasicAnimation(keyPath: Defaults.strokeEndAnimationKey)
        animation.beginTime = CACurrentMediaTime() + 1
        animation.duration = 0.5
        animation.delegate = self
        animation.setValue(Defaults.increaseWinRingAnimationValue, forKey: Defaults.animationIDKey)
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = completionPercentage(withWins: player.winCount)
        animation.isRemovedOnCompletion = false
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        roundsWonLayer.add(animation, forKey: Defaults.strokeEndAnimationKey)
    }
    
    func reset() {
        let animationDuration = 0.8
        
        if let winnerParticleView = winnerParticleView {
            UIView.animate(withDuration: animationDuration, animations: {
                winnerParticleView.alpha = 0
            }) { _ in
                winnerParticleView.removeFromSuperview()
                self.winnerParticleView = nil
            }
        }
        
        let animation = CABasicAnimation(keyPath: Defaults.strokeEndAnimationKey)
        animation.duration = animationDuration
        animation.fromValue = completionPercentage(withWins: player.winCount)
        
        player.winCount = 0
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        roundsWonLayer.strokeEnd = completionPercentage(withWins: player.winCount)
        roundsWonLayer.add(animation, forKey: Defaults.strokeEndAnimationKey)
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard player.type == .human,
            let animationId = anim.value(forKey: Defaults.animationIDKey) as? String,
            animationId == Defaults.increaseWinRingAnimationValue && player.winCount >= game.roundsToWin else {
                return
        }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        var emitterColor = player.color
        
        if player.color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            emitterColor = UIColor(hue: hue * 0.95, saturation: saturation, brightness: brightness, alpha: alpha)
        }

        let winnerParticleView = BubbleParticleView(frame: view.bounds, color: emitterColor)
        self.winnerParticleView = winnerParticleView
        
        winnerParticleView.birthrate = Float(round(view.bounds.width * 0.06))
        winnerParticleView.scaleRange = CGFloat(round(view.bounds.width * 0.010))
        winnerParticleView.isUserInteractionEnabled = false
        
        if !actionView.label.isHidden {
            view.insertSubview(winnerParticleView, belowSubview: actionView)
        }
        else {
            view.addSubview(winnerParticleView)
        }
        
        winnerParticleView.translatesAutoresizingMaskIntoConstraints = false
        winnerParticleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        winnerParticleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        winnerParticleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        winnerParticleView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        winnerParticleView.alpha = 0
        
        UIView.animate(withDuration: 0.6) {
            winnerParticleView.alpha = 1
        }
    }
}

