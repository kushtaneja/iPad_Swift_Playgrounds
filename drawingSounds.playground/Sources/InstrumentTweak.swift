// 
//  InstrumentTweak.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import AVFoundation

/** 
 An enum of different tweaks that can be applied to an instrument.
 These can be pitchBend, pressure, and velocity.
 */
public enum InstrumentTweakType {
    case pitchBend, pressure, velocity
    
    // The max value that the particular tweak modifier can be.
    var tweakRange: ClosedRange<Int> {
        switch self {
        case .pitchBend:
            return 0...16383
        case .pressure:
            return 0...127
        case .velocity:
            return 0...127
        }
    }
}

/// This class provides effects to tweak how the instrument sounds.
public struct InstrumentTweak {

    var type: InstrumentTweakType
    
    private var valueRange: ClosedRange<Int>
    
    /// Create an instrument tweak whose effect varies by the values (from 0 to 100). Depending on where you tap on the keyboard it will apply a different value within the range.
    public init(type: InstrumentTweakType, effectFrom startValue: Int, to endValue: Int) {
        self.type = type
        let firstValue = startValue.clamped(to: Constants.userValueRange)
        let secondValue = endValue.clamped(to: Constants.userValueRange)
        if firstValue < secondValue {
            self.valueRange = firstValue...secondValue
        } else {
            self.valueRange = secondValue...firstValue
        }
    }
    
    // When passed in a normalized value between 0 to 1, places it within the user's specified valueRange and then converts that to the actual value for the underlying instrument tweak
    func tweakValue(fromNormalizedValue normalizedValue: CGFloat) -> Int {
        let valueRangeCount = CGFloat(valueRange.count)
        let possibleRangeCount = CGFloat(Constants.userValueRange.count)
        let normalizedValueInDefinedRange = ((normalizedValue * valueRangeCount) + CGFloat(valueRange.lowerBound)) / possibleRangeCount
        
        return InstrumentTweak.tweak(normalizedValue: normalizedValueInDefinedRange, forType: type)
    }
    
    static func tweak(normalizedValue: CGFloat, forType type: InstrumentTweakType) -> Int {
        let tweakRange = type.tweakRange
        return Int(normalizedValue * CGFloat(tweakRange.upperBound - tweakRange.lowerBound)) + tweakRange.lowerBound
    }
}
