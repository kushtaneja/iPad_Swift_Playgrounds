// 
//  SpeechTweak.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import AVFoundation

/**
 An enum of different tweaks that can be applied to an instrument.
 These can be pitch, speed, and volume.
 */
public enum SpeechTweakType {
    case pitch, speed, volume
    
    // The range that the particular tweak modifier can be between.
    var tweakRange: ClosedRange<Float> {
        switch self {
        case .pitch:
            return 0.5 ... 2.0
        case .speed:
            return 0.1 ... 2.0
        case .volume:
            return 0.0 ... 1.0
        }
    }
}

/// This class provides effects to tweak how the speech sounds.
public struct SpeechTweak {
    
    var type: SpeechTweakType
    
    private var valueRange: ClosedRange<Int>
    
    /// Create an speech tweak whose effect varies by the values (from 0 to 100). Depending on where you tap on the keyboard it will apply a different value within the range.
    public init(type: SpeechTweakType, effectFrom startValue: Int, to endValue: Int) {
        self.type = type
        
        let firstValue = startValue.clamped(to: Constants.userValueRange)
        let secondValue = endValue.clamped(to: Constants.userValueRange)
        if firstValue < secondValue {
            self.valueRange = firstValue...secondValue
        } else {
            self.valueRange = secondValue...firstValue
        }
    }
    
    // When passed in a normalized value between 0 to 1, places it within the user's specified valueRange and then converts that to the actual value for the underlying speech tweak.
    func tweakValue(fromNormalizedValue normalizedValue: CGFloat) -> Float {
        let valueRangeCount = CGFloat(valueRange.count)
        let normalizedValueInDefinedRange = ((normalizedValue * valueRangeCount) + CGFloat(valueRange.lowerBound)) / CGFloat(Constants.userValueRange.count)
        
        return SpeechTweak.tweak(normalizedValue: normalizedValueInDefinedRange, forType: type)
    }
    
    static func tweak(normalizedValue: CGFloat, forType type: SpeechTweakType) -> Float {
        let tweakRange = type.tweakRange
        return (Float(normalizedValue) * (tweakRange.upperBound - tweakRange.lowerBound)) + tweakRange.lowerBound
    }
}

