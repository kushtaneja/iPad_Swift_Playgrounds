// 
//  ClampedInteger.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

public struct ClampedInteger {
    private let range: ClosedRange<Int>
    private var _integer: Int
    
    var clamped: Int {
        set {
            _integer = newValue.clamped(to: range)
        }
        get {
            return _integer
        }
    }
    
    init(_ integer: Int, in range: ClosedRange<Int>) {
        self.range = range
        self._integer = integer.clamped(to: range)
    }
}
