//
//  TouchGestureRecognizer.swift
//  Shapes
//

import UIKit

internal class TouchGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {

    internal var currentTouches = Set<UITouch>()
    
    internal weak var touchDelegate: TouchGestureRecognizerDelegate?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {

        state = .began
        
        // NOTE: it's important that we capture the current touches BEFORE we notify the handler, since the delegate may access currentTouches.
        currentTouches.formUnion(touches)
        
        touchDelegate?.touchesBegan(touches: touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        touchDelegate?.touchesMoved(touches: touches, with: event)
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        
        touchDelegate?.touchesEnded(touches: touches, with: event)
        
        // NOTE: it's important that we remove the current touches AFTER we notify the handler, since the delegate may access currentTouches.
        currentTouches.subtract(touches)
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        
        touchDelegate?.touchesCancelled(touches: touches, with: event)
        
        // NOTE: it's important that we remove the current touches AFTER we notify the handler, since the delegate may access currentTouches.
        currentTouches.subtract(touches)
        state = .cancelled
    }
    
    // MARK: UIGestureRecognizerDelegate Implementation
    
    override func reset() {
        super.reset()
        currentTouches.removeAll()
    }
    
    @objc(gestureRecognizer:shouldReceiveTouch:) func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        guard let touchDelegate = touchDelegate else { return false }
        
        return touchDelegate.wantsTouch(touch: touch)
    }
}

internal protocol TouchGestureRecognizerDelegate: class {
    
    func touchesBegan(touches: Set<UITouch>, with event: UIEvent)
    func touchesMoved(touches: Set<UITouch>, with event: UIEvent)
    func touchesEnded(touches: Set<UITouch>, with event: UIEvent)
    func touchesCancelled(touches: Set<UITouch>, with event: UIEvent)
    func wantsTouch(touch: UITouch) -> Bool
    
}
