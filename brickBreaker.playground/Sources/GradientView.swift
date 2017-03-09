//
//  GradientView.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

@objc(GradientView)
class GradientView: UIView {
    // MARK: Types
    
    enum Gradient {
        case background
        
        var colors: [UIColor] {
            switch self {
            case .background:
                return [
                    UIColor(colorLiteralRed: 151.0/255.0, green: 212.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                    UIColor(colorLiteralRed: 171.0/255.0, green: 223.0/255.0, blue: 208.0/255.0, alpha: 1.0)
                ]
            }
        }
        
        var startPoint: CGPoint {
            switch self {
            case .background:
                return .zero
            }
        }
        
        var endPoint: CGPoint {
            switch self {
            case .background:
                return CGPoint(x: 0.0, y: 1.0)
            }
        }
    }
    
    // MARK: Properties
    
    var gradient: Gradient = .background {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let colors = gradient.colors.map { $0.cgColor }
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let cgGradient = CGGradient(colorsSpace: colorSpace, colors: colors as NSArray as CFArray, locations: [0, 1])!
        
        let startPoint = CGPoint(x: bounds.size.width * gradient.startPoint.x, y: bounds.size.height * gradient.startPoint.y)
        let endPoint = CGPoint(x: bounds.size.width * gradient.endPoint.x, y: bounds.size.height * gradient.endPoint.y)

        context.drawLinearGradient(cgGradient, start: startPoint, end: endPoint, options: [])
    }
}
