//
//  SpiralViewController.swift
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import PlaygroundSupport

public class SpiralViewController: UIViewController {
    // MARK: Properties
    
    /// Struct representing the roulette values, transferred back and forth across playground proxy
    var roulette: Roulette
    /// Main view which draws the roulette shapes
    var spiralView: SpiralView?
    
    /// Minimum scale to which the user may 'pinch to zoom'
    private let maxScaleLimit: CGFloat = 4
    /// Maximum scale to which the user may 'pinch to zoom'
    private let minScaleLimit: CGFloat = 0.3
    /// Variable to track how far the spiralView has been cumulatively scaled
    private var spiralViewCumulativeScale: CGFloat = 1.0
    
    /// Keeps track of whether the wheel and spoke are showing or not
    private var showingWheelAndSpoke = true
    
    private var displayLink: CADisplayLink?
    
    // MARK: Initialization
    
    public init(initialRoulette: Roulette) {
        self.roulette = initialRoulette
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController overrides
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wwdcGray()
        addAndConstrainSpiralView()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(zoom(gestureRecognizer:)))
        view.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(pan(gestureRecognizer:)))
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tap(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spiralView?.reset()
        // Reset the scale counter on redraw
        spiralViewCumulativeScale = 1.0

        displayLink = CADisplayLink(target: self,
                                  selector: #selector(displayLinkDidFire))
        displayLink?.add(to: .main,
                    forMode: .defaultRunLoopMode)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spiralView?.reset()
    }
    
    // MARK: Gesture recognizer handling
    
    func zoom(gestureRecognizer: UIPinchGestureRecognizer) {
        guard let spiralView = spiralView else { return }
        
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            
            // Ensure the cumulative scale is within the set range
            if spiralViewCumulativeScale > minScaleLimit && spiralViewCumulativeScale < maxScaleLimit {
                
                // Increment the scale
                spiralViewCumulativeScale *= gestureRecognizer.scale
                
                // Execute the transform
                spiralView.transform = spiralView.transform.scaledBy(x: gestureRecognizer.scale,
                                                                     y: gestureRecognizer.scale);
            } else {
                // If the cumulative scale has extended beyond the range, check
                // to see if the user is attempting to scale it back within range
                let nextScale = spiralViewCumulativeScale * gestureRecognizer.scale
                
                if spiralViewCumulativeScale < minScaleLimit && nextScale > minScaleLimit
                || spiralViewCumulativeScale > maxScaleLimit && nextScale < maxScaleLimit {
                    
                    // If the user is trying to get back in-range, allow the transform
                    spiralViewCumulativeScale *= gestureRecognizer.scale
                    spiralView.transform = spiralView.transform.scaledBy(x: gestureRecognizer.scale,
                                                                         y: gestureRecognizer.scale);
                }
            }
        }
        
        gestureRecognizer.scale = 1;
    }
    
    func pan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let spiralView = spiralView else { return }
        
        let translation = gestureRecognizer.translation(in: view)
        
        spiralView.center = CGPoint(x: spiralView.center.x + translation.x,
                                    y: spiralView.center.y + translation.y)
        
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        
    }
    
    func tap(gestureRecognizer: UITapGestureRecognizer) {
        guard let spiralView = spiralView else { return }
        
        if showingWheelAndSpoke {
            spiralView.wheelLayer.strokeColor = UIColor.clear.cgColor
            spiralView.spokeLayer.strokeColor = UIColor.clear.cgColor
            spiralView.spokeLayer.fillColor = UIColor.clear.cgColor
            spiralView.trackLayer.strokeColor = UIColor.clear.cgColor
            showingWheelAndSpoke = false
        } else {
            spiralView.wheelLayer.strokeColor = roulette.wheelStrokeColor.cgColor
            spiralView.spokeLayer.strokeColor = roulette.spokeColor.cgColor
            spiralView.spokeLayer.fillColor = roulette.spokeColor.cgColor
            spiralView.trackLayer.strokeColor = roulette.trackStrokeColor.cgColor
            showingWheelAndSpoke = true
        }
    }
    
    // MARK: DisplayLink handling
    
    func displayLinkDidFire(_ sender: CADisplayLink) {
        spiralView?.update()
    }

    // MARK: Convenience methods
    
    fileprivate func addAndConstrainSpiralView() {
        let spiralView = SpiralView(frame: view.frame, roulette: roulette)
        view.addSubview(spiralView)
        spiralView.translatesAutoresizingMaskIntoConstraints = false
        // Always reset the spiralScale when we reset the spiral
        spiralViewCumulativeScale = 1.0
        
        // Constrain `spiralView` to a square whose size matches the shorter of width and height.
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        
        if view.frame.width > view.frame.height {
            widthConstraint = spiralView.widthAnchor.constraint(equalToConstant: view.frame.width)
            heightConstraint = spiralView.heightAnchor.constraint(equalToConstant: view.frame.width)
        } else {
            widthConstraint = spiralView.widthAnchor.constraint(equalToConstant: view.frame.height)
            heightConstraint = spiralView.heightAnchor.constraint(equalToConstant: view.frame.height)
        }
        
        let centerYConstraint = spiralView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let centerXConstraint = spiralView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        NSLayoutConstraint.activate([widthConstraint,
                                     heightConstraint,
                                     centerYConstraint,
                                     centerXConstraint])
        
        self.spiralView = spiralView
    }
}

//extension SpiralViewController: PlaygroundLiveViewMessageHandler {
//    
//    // Removes current drawing when the user begins stepping through code to avoid confusion
//    public func liveViewMessageConnectionOpened() {
//        spiralView?.removeFromSuperview()
//    }
//    
//    public func receive(_ message: PlaygroundValue) {
//        switch message {
//        case .dictionary:
//            spiralView?.removeFromSuperview()
//            roulette = Roulette(playgroundValue: message)
//            // We can set custom spiral background colors, so make sure to update the view's background color as well
//            view.backgroundColor = roulette.backgroundColor
//            addAndConstrainSpiralView()
//        default:
//            return
//        }
//    }
//}
