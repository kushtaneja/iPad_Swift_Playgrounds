// 
//  InstrumentFilter.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import AVFoundation


/**
 Different types of filters for the instrument.
 These can be alienChatter, distortion, cubedDistortion, echo, multiEcho, cathedral, smallRoom, and cellphoneConcert.
*/
public enum InstrumentFilterType {
    case alienChatter, distortion, cubedDistortion, echo, multiEcho, cathedral, smallRoom, cellphoneConcert
}

/// A filter will modify how the instrument will sound.
public struct InstrumentFilter {
    
    /// The type of filter that is applied.
    public var type: InstrumentFilterType
    
    var audioUnitEffect: AVAudioUnitEffect {
        let audioEffect: AVAudioUnitEffect
        switch type {
        case .alienChatter:
            let alienChatter = AVAudioUnitDistortion()
            alienChatter.loadFactoryPreset(.speechAlienChatter)
            audioEffect = alienChatter
        case .cubedDistortion:
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.multiDistortedCubed)
            audioEffect = distortion
        case .multiEcho:
            let multiEcho = AVAudioUnitDistortion()
            multiEcho.loadFactoryPreset(.multiEcho2)
            audioEffect = multiEcho
        case .echo:
            let echo = AVAudioUnitDistortion()
            echo.loadFactoryPreset(.multiEchoTight2)
            audioEffect = echo
        case .cathedral:
            let cathedral = AVAudioUnitReverb()
            cathedral.loadFactoryPreset(.cathedral)
            audioEffect = cathedral
        case .smallRoom:
            let smallRoom = AVAudioUnitReverb()
            smallRoom.loadFactoryPreset(.smallRoom)
            audioEffect = smallRoom
        case .distortion:
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.multiDistortedSquared)
            audioEffect = distortion
        case .cellphoneConcert:
            let cellphoneConcert = AVAudioUnitDistortion()
            cellphoneConcert.loadFactoryPreset(.multiCellphoneConcert)
            audioEffect = cellphoneConcert
        }
        
        return audioEffect
    }
    
    public init(type: InstrumentFilterType) {
        self.type = type
    }
}
