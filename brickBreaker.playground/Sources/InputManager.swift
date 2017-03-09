//
//  InputManager.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation
import GameController

class InputManager: NSObject {
    
    private let maximumControllerCount: Int
    
    private(set) var controllers = Set<GCController>()
    
    private var panRecognizer: UIPanGestureRecognizer!
    
    weak var delegate: InputManagerDelegate?
    
    // MARK: Initialization
    
    init(view: UIView, maximumControllerCount: Int = 1) {
        self.maximumControllerCount = maximumControllerCount
        
        super.init()
        
        let noticiationCenter = NotificationCenter.default
        noticiationCenter.addObserver(self, selector: #selector(InputManager.didConnectController(_:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        noticiationCenter.addObserver(self, selector: #selector(InputManager.didDisconnectController(_:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        GCController.startWirelessControllerDiscovery {}
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(InputManager.handlePanRecognizer))
        view.addGestureRecognizer(panRecognizer)
    }
    
    deinit {
        let noticiationCenter = NotificationCenter.default
        noticiationCenter.removeObserver(self, name: NSNotification.Name.GCControllerDidConnect, object: nil)
        noticiationCenter.removeObserver(self, name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    // MARK: Convenience
    
    func controller(for player: Int) -> GCController? {
        let playerIndex = GCControllerPlayerIndex(rawValue: player)!
        for controller in controllers {
            if controller.playerIndex == playerIndex {
                return controller
            }
        }
        
        return nil
    }
    
    // MARK: Notification handlers
    
    func didConnectController(_ notification: Notification) {
        guard controllers.count < maximumControllerCount else { return }
        let controller = notification.object as! GCController
        
        // Determine the player index to associate with the controller.
        let usedIndexes: [Int] = controllers.map { $0.playerIndex.rawValue }
        for index in 0 ..< maximumControllerCount {
            guard !usedIndexes.contains(index) else { continue }
            
            controller.playerIndex = GCControllerPlayerIndex(rawValue: index)!
            break
        }

        controllers.insert(controller)
        
        delegate?.inputManager(self, didConnect: controller)
    }
    
    func didDisconnectController(_ notification: Notification) {
        let controller = notification.object as! GCController
        controllers.remove(controller)
        
        delegate?.inputManager(self, didDisconnect: controller)
    }
    
    // MARK: Gesture recognizer handlers
    
    func handlePanRecognizer() {
        let point = panRecognizer.location(in: panRecognizer.view)
        
        switch panRecognizer.state {
        case .began:
            delegate?.inputManager(self, didBeginDragAt: point)
            
        case .changed:
            delegate?.inputManager(self, didDragTo: point)
            
        case .possible, .cancelled, .ended, .failed:
            break
        }
    }
}


protocol InputManagerDelegate: class {
    func inputManager(_ manager: InputManager, didConnect controller: GCController)
    func inputManager(_ manager: InputManager, didDisconnect controller: GCController)
    
    func inputManager(_ manager: InputManager, didBeginDragAt point: CGPoint)
    func inputManager(_ manager: InputManager, didDragTo point: CGPoint)
}
