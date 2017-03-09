//
//  SoundEffectsManager.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import AVFoundation

enum SoundEffect {
    case random
    case scroll
    case select
    case roundTie
    case roundLose
    case roundWin
    case gameLose
    case gameWin
}

class SoundEffectsManager {
    
    static let `default` = SoundEffectsManager()
    
    private var randomSoundBuffer: AVAudioPCMBuffer
    
    private var scrollSoundBuffer: AVAudioPCMBuffer

    private var selectSoundBuffer: AVAudioPCMBuffer

    private var roundTieSoundBuffer: AVAudioPCMBuffer

    private var roundLoseSoundBuffer: AVAudioPCMBuffer

    private var roundWinSoundBuffer: AVAudioPCMBuffer

    private var gameLoseSoundBuffer: AVAudioPCMBuffer

    private var gameWinSoundBuffer: AVAudioPCMBuffer
    
    private let audioEngine = AVAudioEngine()
    
    private let audioPlayerNode = AVAudioPlayerNode()
    
    init() {
        func audioBuffer(withResource resource: String) -> AVAudioPCMBuffer {
            let audioUrl = Bundle.main.url(forResource: resource, withExtension: "")!
            let audioFile = try! AVAudioFile(forReading: audioUrl)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
            try! audioFile.read(into: audioFileBuffer)
            return audioFileBuffer
        }

        randomSoundBuffer = audioBuffer(withResource: "Random.caf")
        scrollSoundBuffer = audioBuffer(withResource: "Scroll.caf")
        selectSoundBuffer = audioBuffer(withResource: "Select.caf")
        roundTieSoundBuffer = audioBuffer(withResource: "RoundTie.caf")
        roundLoseSoundBuffer = audioBuffer(withResource: "RoundLose.caf")
        roundWinSoundBuffer = audioBuffer(withResource: "RoundWin.caf")
        gameLoseSoundBuffer = audioBuffer(withResource: "GameLose.caf")
        gameWinSoundBuffer = audioBuffer(withResource: "GameWin.caf")

        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: selectSoundBuffer.format)
        
        do {
            try audioEngine.start()
            audioPlayerNode.play()
        }
        catch {}
    }
    
    func play(soundEffect: SoundEffect) {
        var audioBuffer: AVAudioPCMBuffer
        
        switch soundEffect {
            case .random:
                audioBuffer = randomSoundBuffer
            case .scroll:
                audioBuffer = scrollSoundBuffer
            case .select:
                audioBuffer = selectSoundBuffer
            case .roundTie:
                audioBuffer = roundTieSoundBuffer
            case .roundLose:
                audioBuffer = roundLoseSoundBuffer
            case .roundWin:
                audioBuffer = roundWinSoundBuffer
            case .gameLose:
                audioBuffer = gameLoseSoundBuffer
            case .gameWin:
                audioBuffer = gameWinSoundBuffer
        }

        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            }
            catch {}
        }
        
        audioPlayerNode.scheduleBuffer(audioBuffer, at: nil, options: .interrupts, completionHandler: nil)
    }
}
