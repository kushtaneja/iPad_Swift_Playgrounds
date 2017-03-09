//
//  CGRect+RectContainingPointAndInset.swift
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

extension CGRect {
    init(rectContaining point1: CGPoint, point2: CGPoint, inset: CGFloat) {
        self.init(x: min(point1.x, point2.x),
                  y: min(point1.y, point2.y),
              width: abs(point1.x - point2.x),
             height: abs(point1.y - point2.y))
        
        self = self.insetBy(dx: -inset, dy: -inset)
    }
}
