//: Playground - noun: a place where people can play

//#-hidden-code
//
//  Contents.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
//#-end-hidden-code
/*:
 Configure and play your own instruments! Follow the code comments below to find tips for modifying the audio loop and instruments to make new sounds.
 */
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(module, show, Swift)
//#-code-completion(module, show, Drawing_Sounds_Sources)
//#-code-completion(identifier, show, if, func, var, let, ., =, <=, >=, <, >, ==, !=, +, -, true, false, &&, ||, !, *, /, (, ))
//#-code-completion(identifier, hide, leftSoundProducer(), rightSoundProducer(), SoundProducer, viewController, storyBoard, SoundBoard, MusicViewController, Instrument, ClampedInteger, AudioPlayerEngine, connect(_:))
import UIKit
import PlaygroundSupport

let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
let viewController = storyBoard.instantiateInitialViewController() as! MusicViewController

PlaygroundPage.current.liveView = viewController

// Note: These functions are not following Swift conventions but are instead trying to mimic the feel of a class for a beginner audience.
/// Creates an electric guitar.
func ElectricGuitar() -> Instrument {
    let instrument = Instrument(kind: .electricGuitar)
    instrument.connect(viewController.engine!)
    instrument.defaultVelocity = 64
    return instrument
}

/// Creates a bass guitar.
func Bass() -> Instrument {
    let instrument = Instrument(kind: .bass)
    instrument.connect(viewController.engine!)
    instrument.defaultVelocity = 64
    return instrument
}
//#-end-hidden-code
//#-editable-code
// Try other types of loops!
let loop = Loop(type: LoopType.aboveAndBeyond)
// Numbers in this playground can be from 0 to 100. Increase the volume to hear the loop.
loop.volume = 0
loop.play()

// This code configures the instrument keyboard on the left.
//#-end-editable-code
func leftSoundProducer() -> SoundProducer {
    //#-editable-code
    // Try changing the instrument to ElectricGuitar().
    let instrument = Bass()
    instrument.defaultVelocity = 80
    // Try changing the type or values for xEffect, which changes the sound depending on where you touch the keyboard.
    instrument.xEffect = InstrumentTweak(type: InstrumentTweakType.velocity, effectFrom: 50, to: 100)
    // Try another filter, such as multiEcho.
    instrument.filter = InstrumentFilter(type: InstrumentFilterType.cathedral)
    return instrument
    //#-end-editable-code
}
//#-editable-code
// This code configures the voice keyboard on the right.
//#-end-editable-code
func rightSoundProducer() -> SoundProducer {
    //#-editable-code
    // Put your own words here.
    let speech = Speech(words: "Aayush to the crazy ones.")
    speech.defaultSpeed = 30
    speech.defaultVolume = 60
    // Try changing the type to speed to see how it impacts the sound.
    speech.xEffect = SpeechTweak(type: SpeechTweakType.pitch, effectFrom: 0, to: 100)
    return speech
    //#-end-editable-code
}
//#-hidden-code
viewController.makeLeftSoundProducer = leftSoundProducer
viewController.makeRightSoundProducer = rightSoundProducer
//#-end-hidden-code
