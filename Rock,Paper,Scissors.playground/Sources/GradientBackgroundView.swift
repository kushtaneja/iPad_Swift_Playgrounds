//
//  GradientBackgroundView.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class GradientView: UIView {
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
}
