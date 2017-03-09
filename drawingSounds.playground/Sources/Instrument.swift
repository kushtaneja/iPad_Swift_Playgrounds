// 
//  Instrument.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import AVFoundation

/// An instrument that can play notes and have filters and effects applied to it.
public class Instrument: SoundProducer {

    /// The kind of instrument, which can be either an electricGuitar or bass.
    public enum Kind {
        case electricGuitar, bass

        var wavURLs: [URL] {
            let fileNames: [String]
            
            switch self {
            case .electricGuitar:
                fileNames = ["80s Electric Guitar A1", "80s Electric Guitar A2", "80s Electric Guitar A4", "80s Electric Guitar B1", "80s Electric Guitar B3", "80s Electric Guitar C#5", "80s Electric Guitar D2", "80s Electric Guitar D3", "80s Electric Guitar D4", "80s Electric Guitar E1", "80s Electric Guitar E2", "80s Electric Guitar E3", "80s Electric Guitar E4", "80s Electric Guitar F#4", "80s Electric Guitar F3", "80s Electric Guitar G2"]
            case .bass:
                fileNames = ["Trad E Bass C1", "Trad E Bass C2", "Trad E Bass C3", "Trad E Bass C4", "Trad E Bass C5", "Trad E Bass E1", "Trad E Bass E2", "Trad E Bass E3", "Trad E Bass E4", "Trad E Bass E5", "Trad E Bass G#1", "Trad E Bass G#2", "Trad E Bass G#3", "Trad E Bass G#4", "Trad E Bass G#5"]
            }
            
            return fileNames.map { Bundle.main.url(forResource: $0, withExtension: "wav")! }
        }
        
        var potentialNotes: [UInt8] {
            switch self {
            case .electricGuitar:
                return [28, 33,35, 38, 40, 43, 45, 50, 52, 53, 59, 62, 64, 66, 69, 73]
            case .bass:
                return [24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80]
            }
        }
    }
    
    // Private to prevent the user to edit the instrument type after it is created and playing.
    private var kind: Kind
    
    private let sampler = AVAudioUnitSampler()
    
    private weak var audioEngine: AudioPlayerEngine?
    
    var playableNotes: [UInt8]
    

    // If any effect is applied on touches across the X axis.
    public var xEffect: InstrumentTweak?
    
    // Any filters that are applied to the instrument
    public var filter: InstrumentFilter? {
        didSet {
            // If it is already connected to an audio engine, reconnect it to apply the filter
            if let engine = audioEngine {
                connect(engine)
            }
        }
    }
    
    private var _defaultVelocity = ClampedInteger(clampedUserValueWithDefaultOf: 80)
    public var defaultVelocity: Int {
        get { return _defaultVelocity.clamped }
        set { _defaultVelocity.clamped = newValue }
    }
    
    var normalizedVelocity: CGFloat {
        return CGFloat(defaultVelocity) / CGFloat(Constants.maxUserValue)
    }

    // The time before the sound is shutoff after the note is started.
    var fadeTime: Double {
        switch kind {
        case .electricGuitar:
            return 0.3
        case .bass:
            return 0.3
        }
    }
    
    var extendedFadeTime: Double {
        switch kind {
        case .electricGuitar:
            return 1.5
        case .bass:
            return 2.0
        }
    }
    
    public init(kind: Kind) {
        self.kind = kind
        self.playableNotes = kind.potentialNotes
    }
    
    
    // MARK: SoundProducer
    
    public var noteCount: Int {
        return playableNotes.count
    }

    // MARK: MIDI Playback
    
    func startPlaying(noteValue: UInt8, withVelocity velocity: UInt8 = 64, onChannel channel: UInt8 ) {
        sampler.startNote(noteValue, withVelocity: velocity, onChannel: channel)
    }

    func stopPlaying(noteValue: UInt8, onChannel channel: UInt8) {
        sampler.stopNote(noteValue, onChannel: channel)
    }

    /// Sets the pressure on a specific channel. Range is 0 -> 127
    func setPressure(_ pressure: UInt8, onChannel channel: UInt8) {
        sampler.sendPressure(pressure, onChannel: channel)
    }
    
    /// Sets the pitch bend on a specific channel. Range is 0 -> 16383
    func setPitchBend(_ pitchBend: UInt16, onChannel channel: UInt8) {
        sampler.sendPitchBend(UInt16(pitchBend), onChannel: channel)
    }
    
    // MARK: AudioEngineSetup
    
    public func connect(_ engine: AudioPlayerEngine) {
        if sampler.engine != nil, let audioEngine = audioEngine {
            disconnect(audioEngine)
        }
        
        // Attach the player to the audio engine with an optional filter.
        engine.add(node: sampler, format: sampler.outputFormat(forBus: 0), audioUnitEffect: filter?.audioUnitEffect)
        let wavURLs = kind.wavURLs
        do {
            try sampler.loadAudioFiles(at: wavURLs)
            audioEngine = engine
        } catch {
            print("Failed to load \(wavURLs) \(error)")
        }
    }
    
    func disconnect(_ engine: AudioPlayerEngine) {
        if sampler.engine != nil {
            engine.remove(node: sampler)
        }
    }
}


