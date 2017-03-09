// 
//  SoundBoard.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import SpriteKit

/// A class that configures a keyboard that can play an instrument or speech.
public class SoundBoard {
    
    // MARK: Public Properties
    
    public var soundProducer: SoundProducer? {
        didSet {
            createNoteSprites(for: noteCount)
        }
    }
    
    public var instrument: Instrument? {
        return soundProducer as? Instrument
    }
    
    public var speech: Speech? {
        return soundProducer as? Speech
    }
    
    // MARK: Properties

    // Whenever the sustained notes are updated, automatically fade any previously sustained notes.
    var sustainedNoteValues: [UInt8] = [] {
        didSet {
            let notesToFade = oldValue.filter { !sustainedNoteValues.contains($0) }
            for noteValue in notesToFade {
                fade(noteValue: noteValue)
            }
        }
    }
    
    var newNoteValues: [UInt8] = []
    
    // Fading notes only applies to instruments.
    private var fadingNoteValues: [UInt8] = []
    
    var spriteNode: SKSpriteNode
    
    private var noteSprites: [SKSpriteNode] = []
    
    private var channel: UInt8 = 0
    
    var firstKeyColor: SKColor = SKColor.green
    var secondKeyColor: SKColor = SKColor.blue
    
    var noteSize: CGSize {
        return CGSize(width: spriteNode.size.width, height: spriteNode.size.height / CGFloat(noteCount))
    }
    
    private var noteCount: Int {
        return soundProducer?.noteCount ?? 1
    }
    
    func noteValue(for touchPoint: CGPoint) -> UInt8 {
        let normalizedTouchValue = touchPoint.y / spriteNode.size.height
        let noteIndex = UInt8(normalizedTouchValue * CGFloat(noteCount))
        if let instrument = instrument {
            return instrument.playableNotes[Int(noteIndex)]
        } else {
            return noteIndex
        }
    }
    
    func normalized(_ noteValue: UInt8) -> CGFloat {
        return CGFloat(noteValue) / CGFloat(noteCount)
    }

    // MARK: Initialization
    
    init(spriteNode: SKSpriteNode) {
        self.spriteNode = spriteNode
    }
    
    
    // MARK: Interaction Handling
    
    func handleTap(withTouchPoints touchPoints: [CGPoint], recognizerState: UIGestureRecognizerState) {
        for touchPoint in touchPoints {
            let noteValue = self.noteValue(for: touchPoint)

            // Only play a note that is not currently being sustained.
            if !sustainedNoteValues.contains(noteValue) {
                play(noteValue: noteValue, withXValue: touchPoint.x)
                fade(noteValue: noteValue, hasExtendedFade: true)
            }
        }
    }

    func handlePan(withTouchPoints touchPoints: [CGPoint], recognizerState: UIGestureRecognizerState) {
        
        newNoteValues = []
        
        for touchPoint in touchPoints {
            let noteValue = self.noteValue(for: touchPoint)
             // Keep track of all the notes playing on this pan call (sustained or just started).
            newNoteValues.append(noteValue)
            
            // Only play a sound if this note wasn't played on the previous pan gesture
            if sustainedNoteValues.contains(noteValue) == false {
                play(noteValue: noteValue, withXValue: touchPoint.x)
            }
        }
        
        if recognizerState == .ended || recognizerState == .cancelled {
            sustainedNoteValues = []
        } else {
            sustainedNoteValues = newNoteValues
        }
    }
    
    // MARK: Audio Playback
    
    func play(noteValue: UInt8, withXValue xValue: CGFloat) {
        
        let normalizedXValue = xValue / spriteNode.size.width
        
        if let instrument = instrument {

            var velocity = UInt8(InstrumentTweak.tweak(normalizedValue: instrument.normalizedVelocity, forType: .velocity))
            
            if let xEffect = instrument.xEffect {
                let tweakValue = xEffect.tweakValue(fromNormalizedValue: normalizedXValue)
                switch(xEffect.type) {
                case .velocity:
                    velocity = UInt8(tweakValue)
                case .pitchBend:
                    instrument.setPitchBend(UInt16(tweakValue), onChannel: channel)
                case .pressure:
                    instrument.setPressure(UInt8(tweakValue), onChannel: channel)
                }
            }
            instrument.startPlaying(noteValue: noteValue, withVelocity: velocity, onChannel: channel)
        } else if let speech = speech {
            
            var volume = SpeechTweak.tweak(normalizedValue: speech.normalizedVolume, forType: .volume)
            var rate = SpeechTweak.tweak(normalizedValue: speech.normalizedSpeed, forType: .speed)
            var pitch = SpeechTweak.tweak(normalizedValue: speech.normalizedPitch, forType: .pitch)
            if let xEffect = speech.xEffect {
                let tweakValue = xEffect.tweakValue(fromNormalizedValue: normalizedXValue)
                switch(xEffect.type) {
                case .pitch:
                    pitch = tweakValue
                case .speed:
                    rate = tweakValue
                case .volume:
                    volume = tweakValue
                }
            }
            
            if let word = speech.word(forIndex: Int(noteValue)) {
                speech.speak(word, rate: rate, pitchMultiplier: pitch, volume: volume)
            }
        }
    }
    
    
    
    // Instruments Only: To let the sound fade away, the midi value needs to be shutoff after some time interval. For sustained instruments additional effects need to be applied.
    func fade(noteValue: UInt8, hasExtendedFade: Bool = false) {
        if let instrument = instrument {
            fadingNoteValues.append(noteValue)
            
            let delayTime: DispatchTime
            if hasExtendedFade {
                delayTime = DispatchTime.now() + instrument.extendedFadeTime
            } else {
                delayTime = DispatchTime.now() + instrument.fadeTime
            }

            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                instrument.stopPlaying(noteValue: noteValue, onChannel: self.channel)
            })
        }
    }
    
    func stopPlaying(noteValue: UInt8) {
        // The note should be faded out before it is removed but this handles stopping sustained notes as well.
        if let noteIndex = fadingNoteValues.index(of: noteValue) {
            fadingNoteValues.remove(at: noteIndex)
        } else if let noteIndex = sustainedNoteValues.index(of: noteValue) {
            sustainedNoteValues.remove(at: noteIndex)
        }
        
        if let instrument = instrument {
            instrument.stopPlaying(noteValue: noteValue, onChannel: channel)
        }
    }
    

    // MARK: View layout
    
    func rectFor(noteValue: UInt8) -> CGRect {
        return CGRect(origin: CGPoint(x: CGFloat(0.0), y: normalized(noteValue)), size: noteSize)
    }
    
    private func createNoteSprites(for noteCount: Int) {
        spriteNode.removeAllChildren()
        let size = noteSize
        
        var firstColorRGB: (CGFloat, CGFloat, CGFloat) = (0,0,0)
        var secondColorRGB: (CGFloat, CGFloat, CGFloat) = (0,0,0)
        let colorIncrement: (CGFloat, CGFloat, CGFloat)

        firstKeyColor.getRed(&firstColorRGB.0, green: &firstColorRGB.1, blue: &firstColorRGB.2, alpha: nil)
        secondKeyColor.getRed(&secondColorRGB.0, green: &secondColorRGB.1, blue: &secondColorRGB.2, alpha: nil)
        let count = CGFloat(noteCount)
        colorIncrement = ((secondColorRGB.0 - firstColorRGB.0) / count, (secondColorRGB.1 - firstColorRGB.1) / count, (secondColorRGB.2 - firstColorRGB.2) / count)
        
        noteSprites = (1...noteCount).map { idx in
            let color = SKColor(red: firstColorRGB.0 + (colorIncrement.0 * CGFloat(idx)),
                                green: firstColorRGB.1 + (colorIncrement.1 * CGFloat(idx)),
                                blue: firstColorRGB.2 + (colorIncrement.2 * CGFloat(idx)),
                                alpha: 1.0)
            let noteSprite = SKSpriteNode(color: color, size: size)
            
            spriteNode.addChild(noteSprite)
            
            return noteSprite
        }

        layoutNoteSprites()
    }
    
    func layoutNoteSprites() {
        let size = noteSize
        var yPosition: CGFloat = (size.height - spriteNode.size.height) / 2.0

        for noteSprite in noteSprites {
            noteSprite.size = size
            noteSprite.position = CGPoint(x: noteSprite.position.x, y: yPosition)
            yPosition += size.height
        }
    }
}
