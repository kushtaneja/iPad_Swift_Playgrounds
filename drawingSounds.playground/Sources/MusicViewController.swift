// 
//  MusicViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import SpriteKit

@objc(MusicViewController)
public class MusicViewController: UIViewController {

    public var engine: AudioPlayerEngine?

    var scene: MusicScene?
    
    public var makeLeftSoundProducer: (() -> SoundProducer)? {
        didSet {
            scene?.makeLeftSoundProducer = makeLeftSoundProducer
        }
    }
    
    public var makeRightSoundProducer: (() -> SoundProducer)? {
        didSet {
            scene?.makeRightSoundProducer = makeRightSoundProducer
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        if let engine = engine {
            engine.start()
        }
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        engine?.stop()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        engine = AudioPlayerEngine()
        
        scene = MusicScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene?.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        // For testing as an iPad app.
        #if DEBUG
        scene?.makeLeftSoundProducer = { () -> SoundProducer in
            let guitar = self.Bass()
            guitar.xEffect = InstrumentTweak(type: .pressure, effectFrom: 1244, to: 20)
            guitar.defaultVelocity = 80
            guitar.filter = InstrumentFilter(type: .cathedral)
            return guitar
        }
        
        scene?.makeRightSoundProducer = { () -> SoundProducer in
            let speech = Speech(words: "Here's to the crazy ones. The misfits.")
            speech.defaultSpeed = 40
            speech.defaultVolume = 100
            speech.xEffect = SpeechTweak(type: .pitch, effectFrom: 120, to: -50)
            return speech
        }
        #endif
    }
    
    // MARK: iPad app testing only

    // Note: These functions are not following Swift conventions but are instead trying to mimic the feel of a class for a beginner audience.
    func ElectricGuitar() -> Instrument {
        let instrument = Instrument(kind: .electricGuitar)
        instrument.connect(engine!)
        instrument.defaultVelocity = 64
        return instrument
    }
    
    func Bass() -> Instrument {
        let instrument = Instrument(kind: .bass)
        instrument.connect(engine!)
        instrument.defaultVelocity = 64
        return instrument
    }
}



