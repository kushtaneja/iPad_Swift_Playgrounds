// 
//  RoundedVisualEffectView.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

@objc(RoundedVisualEffectView)
class RoundedVisualEffectView: UIVisualEffectView {
    
    var cornerRadius: CGFloat = 22
        
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
