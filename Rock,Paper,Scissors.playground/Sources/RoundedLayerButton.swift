//
//  RoundedLayerButton.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class RoundedLayerButton: UIButton {
    
    let backgroundLayer = CAShapeLayer()

    init(type buttonType: UIButtonType) {
        super.init(frame: CGRect.zero)
        
        guard let titleLabel = titleLabel else {
            return
        }
        
        layer.insertSublayer(backgroundLayer, below: titleLabel.layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: (bounds.size.height * 0.3)).cgPath
    }
}
