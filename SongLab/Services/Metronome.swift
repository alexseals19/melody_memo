//
//  Metronome.swift
//  SongLab
//
//  Created by Alex Seals on 6/19/24.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class Metronome {
    
    //MARK: - API
    
    static let shared = Metronome()
    
    var bpm: Double
    var timeSignature: Int
    var isArmed: Bool
    var isCountInActive: Bool
    
    var countInDelay: Double {
        if isArmed, isCountInActive {
            return 60 / bpm * Double(timeSignature)
        }
        return 0.0
    }
        
    func playMetronome(beat: Int = 0, startTime: AVAudioTime) throws {
        
        let beatInterval: Double = 60 / bpm
        
        metronome = AVAudioPlayerNode()
        
        guard let samplePath = Bundle.main.path(forResource: "metrohigh.wav", ofType: nil) else {
            print("Could not find metronome.wav")
            return
        }
        let sampleUrl = URL(filePath: samplePath)
        
        let sampleAudioFile = try AVAudioFile(forReading: sampleUrl)
    
        let sampleRate = sampleAudioFile.processingFormat.sampleRate
        
        engine.attach(metronome)
        engine.connect(metronome,
                               to: engine.mainMixerNode,
                               format: sampleAudioFile.processingFormat)
                
        engine.prepare()
        try engine.start()
                
        guard let renderTime = metronome.lastRenderTime else {
            print("Could not get lastRenderTime")
            return
        }
        let now: AVAudioFramePosition = renderTime.sampleTime
        var beatOffset: Double
        var sampleIntervalTime: AVAudioFramePosition
        
        if firstBeat {
            isMetronomePlaying = true
            beatOffset = 2.0 * sampleRate
            sampleIntervalTime = AVAudioFramePosition(Double(now) + beatOffset)
            
        } else {
            beatOffset = beatInterval * sampleRate
            sampleIntervalTime = AVAudioFramePosition(
                Double(now) + beatOffset - Double(sampleAudioFile.length - sampleAudioFile.framePosition)
            )
        }
        
        let beatIntervalTime = AVAudioTime(sampleTime: sampleIntervalTime, atRate: sampleRate)
        
        var url = URL(filePath: "")        
        
        if beat % timeSignature == 0 {
            guard let beatOnePath = Bundle.main.path(forResource: "metrohigh.wav", ofType: nil) else {
                print("Could not find metronome.wav")
                return
            }
            url = URL(filePath: beatOnePath)
        } else {
            guard let beatPath = Bundle.main.path(forResource: "metrolow.wav", ofType: nil) else {
                print("Could not find metronome.wav")
                return
            }
            url = URL(filePath: beatPath)
        }
        
        let audioFile = try AVAudioFile(forReading: url)
            
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        ) else {
            assertionFailure("Could not assign buffer")
            return
        }
        
        try audioFile.read(into: buffer)
        
        metronome.scheduleBuffer(buffer,
                                    at: nil,
                                    options: [.interrupts],
                                    completionCallbackType: .dataRendered
        ) { _ in
            Task { @MainActor in
                if self.isMetronomePlaying {
                    try self.playMetronome(
                        beat: beat == self.timeSignature - 1 ? 0 : beat + 1
                    )
                } else {
                    self.engine.stop()
                    self.engine.detach(self.metronome)
                    self.metronome.stop()
                }
            }
        }
        if firstBeat {
            metronome.play(at: startTime)
        } else {
            metronome.play(at: beatIntervalTime)
        }
        firstBeat = false
    }
    
    func playMetronome(beat: Int = 0) throws {
        
        let beatInterval: Double = 60 / bpm
        
        metronome = AVAudioPlayerNode()
        
        guard let samplePath = Bundle.main.path(forResource: "metrohigh.wav", ofType: nil) else {
            print("Could not find metronome.wav")
            return
        }
        let sampleUrl = URL(filePath: samplePath)
        
        let sampleAudioFile = try AVAudioFile(forReading: sampleUrl)
    
        let sampleRate = sampleAudioFile.processingFormat.sampleRate
        
        engine.attach(metronome)
        engine.connect(metronome,
                               to: engine.mainMixerNode,
                               format: sampleAudioFile.processingFormat)
                
        engine.prepare()
        try engine.start()
                
        guard let renderTime = metronome.lastRenderTime else {
            print("Could not get lastRenderTime")
            return
        }
        let now: AVAudioFramePosition = renderTime.sampleTime
        var beatOffset: Double
        var sampleIntervalTime: AVAudioFramePosition
        
        if firstBeat {
            isMetronomePlaying = true
            beatOffset = 2.0 * sampleRate
            sampleIntervalTime = AVAudioFramePosition(Double(now) + beatOffset)
            
        } else {
            beatOffset = beatInterval * sampleRate
            sampleIntervalTime = AVAudioFramePosition(
                Double(now) + beatOffset - Double(sampleAudioFile.length - sampleAudioFile.framePosition)
            )
        }
        
        let beatIntervalTime = AVAudioTime(sampleTime: sampleIntervalTime, atRate: sampleRate)
        
        var url = URL(filePath: "")
        
        if beat % timeSignature == 0 {
            guard let beatOnePath = Bundle.main.path(forResource: "metrohigh.wav", ofType: nil) else {
                print("Could not find metronome.wav")
                return
            }
            url = URL(filePath: beatOnePath)
        } else {
            guard let beatPath = Bundle.main.path(forResource: "metrolow.wav", ofType: nil) else {
                print("Could not find metronome.wav")
                return
            }
            url = URL(filePath: beatPath)
        }
        
        let audioFile = try AVAudioFile(forReading: url)
            
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        ) else {
            assertionFailure("Could not assign buffer")
            return
        }
        
        try audioFile.read(into: buffer)
        
        metronome.scheduleBuffer(buffer,
                                    at: nil,
                                    options: [.interrupts],
                                    completionCallbackType: .dataRendered
        ) { _ in
            Task { @MainActor in
                if self.isMetronomePlaying {
                    try self.playMetronome(
                        beat: beat == self.timeSignature - 1 ? 0 : beat + 1
                    )
                } else {
                    self.engine.stop()
                    self.engine.detach(self.metronome)
                    self.metronome.stop()
                }
            }
        }
        metronome.play(at: beatIntervalTime)
        firstBeat = false
    }
    
    func stopMetronome() {
        isMetronomePlaying = false
        metronome.stop()
        self.engine.stop()
        self.engine.detach(metronome)
        firstBeat = true
    }
    
    func saveSettings() {
        do {
            try DataPersistenceManager.save(bpm, to: "bpm")
            try DataPersistenceManager.save(timeSignature, to: "timeSignature")
            try DataPersistenceManager.save(isArmed, to: "isArmed")
            try DataPersistenceManager.save(isCountInActive, to: "isCountInActive")
        } catch {}
    }
    
    //MARK: - Variables
    
    private var metronome = AVAudioPlayerNode()
    private var engine = AVAudioEngine()
    private var firstBeat: Bool = true
    private var isMetronomePlaying: Bool = false
    
    
    // MARK: - Functions
    
    private init() {
        do {
            bpm = try DataPersistenceManager.retrieve(Double.self, from: "bpm")
            timeSignature = try DataPersistenceManager.retrieve(Int.self, from: "timeSignature")
            isArmed = try DataPersistenceManager.retrieve(Bool.self, from: "isArmed")
            isCountInActive = try DataPersistenceManager.retrieve(Bool.self, from: "isCountInActive")
        } catch {
            bpm = 120
            timeSignature = 4
            isArmed = false
            isCountInActive = false
        }
    }
}
