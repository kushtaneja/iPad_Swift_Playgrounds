// 
//  HelperExtensions.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }
    
    func clamped(min: Int, max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}
