// 
//  Speech.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import AVFoundation

/// A speech class that can speak various words and have filters and effects applied to the speech.
public class Speech: SoundProducer {
    // MARK: Properties
    
    private var _defaultVolume = ClampedInteger(clampedUserValueWithDefaultOf: 5)
    public var defaultVolume: Int {
        get { return _defaultVolume.clamped }
        set { _defaultVolume.clamped = newValue }
    }
    
    var normalizedVolume: CGFloat {
        return CGFloat(defaultVolume) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultSpeed = ClampedInteger(clampedUserValueWithDefaultOf: 30)
    public var defaultSpeed: Int {
        get { return _defaultSpeed.clamped }
        set { _defaultSpeed.clamped = newValue }
    }
    
    var normalizedSpeed: CGFloat {
        return CGFloat(defaultSpeed) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultPitch = ClampedInteger(clampedUserValueWithDefaultOf: 33)
    public var defaultPitch: Int {
        get { return _defaultPitch.clamped }
        set { _defaultPitch.clamped = newValue }
    }
    
    var normalizedPitch: CGFloat {
        return CGFloat(defaultPitch) / CGFloat(Constants.maxUserValue)
    }
    
    // If any effect is applied on touches across the X axis.
    public var xEffect: SpeechTweak?
    
    // MARK: Private Properties
    
    private var speechWords: [String] = []
    
    private var speechSynthesizer = AVSpeechSynthesizer()

    // MARK: SoundProducer
    
    public var noteCount: Int {
        return speechWords.count
    }
    
    // MARK: Initializers
    
    public init(words: String) {
        self.speechWords = words.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func word(forIndex index: Int) -> String? {
        if index >= 0 && index < speechWords.count {
            return speechWords[index]
        }
        
        return nil
    }
    
    func speak(_ text: String, rate: Float = 0.6, pitchMultiplier: Float = 1.0, volume: Float = 1.0) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.volume = volume
        utterance.pitchMultiplier = pitchMultiplier
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .word)
    }
}
