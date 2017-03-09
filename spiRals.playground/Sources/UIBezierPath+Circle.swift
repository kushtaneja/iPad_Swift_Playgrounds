//
//  UIBezierPath+Circle.swift
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience init(circleWithCenter center: CGPoint, radius: CGFloat) {
        self.init(arcCenter: center,
                     radius: radius,
                 startAngle: 0,
                   endAngle: CGFloat(M_PI * 2.0),
                  clockwise: true)
    }
}
