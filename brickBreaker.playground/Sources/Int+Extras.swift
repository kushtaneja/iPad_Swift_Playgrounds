//
//  Int+Extras.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation

public extension Int {
    public var isOdd: Bool {
        return (self % 2) == 1
    }
    
    public var isEven: Bool {
        return !isOdd
    }
}

public func randomInt(from: Int, to: Int) -> Int {
    let maxValue: Int = max(from, to)
    let minValue: Int = min(from, to)
    if minValue == maxValue {
        return minValue
    } else {
        return (Int(arc4random())%(1 + maxValue - minValue)) + minValue
    }
}
