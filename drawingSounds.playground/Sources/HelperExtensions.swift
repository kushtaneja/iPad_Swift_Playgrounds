// 
//  HelperExtensions.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return fabs(self.x - point.x) + fabs(self.y - point.y)
    }
}

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }

    func clamped(min: Int, max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}

// In this app we are clamping the values the user can enter to a defined range to be more approachable. This extension is used to apply it consistently across the app.
extension ClampedInteger {
    init(clampedUserValueWithDefaultOf integer: Int) {
        self.init(integer, in: Constants.userValueRange)
    }
}

struct Constants {
    static let userValueRange: ClosedRange<Int> = 0...100

    static var maxUserValue: Int {
        return userValueRange.upperBound
    }
}
