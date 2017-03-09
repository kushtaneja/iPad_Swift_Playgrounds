//
//  ActionView.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class ActionView: UIView {
    
    var action: Action? {
        didSet {
            if let action = action {
                setText(action.emoji)
            }
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        let fontDescriptor = UIFontDescriptor(name: "Futura-CondensedExtraBold", size: 0)
        label.font = UIFont(descriptor: fontDescriptor, size: 200)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.01
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.numberOfLines = 0
        
        let sizeMultiplier: CGFloat = 0.6
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: sizeMultiplier).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: sizeMultiplier).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
    }
    
    func setText(_ text: String) {
        label.text = text
    }
}
