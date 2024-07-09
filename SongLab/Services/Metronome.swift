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

struct Beat {
    var player: AVAudioPlayerNode
    var number: Int
    var buffer: AVAudioPCMBuffer
    var playTime: TimeInterval
    
    init(player: AVAudioPlayerNode, 
         number: Int,
         buffer: AVAudioPCMBuffer,
         playTime: TimeInterval
    ) {
        self.player = player
        self.number = number
        self.buffer = buffer
        self.playTime = playTime
    }
    
    init() {
        player = AVAudioPlayerNode()
        number = 0
        buffer = AVAudioPCMBuffer()
        playTime = CACurrentMediaTime()
    }
}

class Metronome {
    
    //MARK: - API
    
    static let shared = Metronome()
    
    var bpm: Double
    var timeSignature: Int
    var isArmed: Bool
    var isCountInActive: Bool
    var subscription: AnyCancellable?
    
    var countInDelay: Double {
        if isArmed, isCountInActive {
            return 60 / bpm * Double(timeSignature)
        }
        return 0.0
    }
    
    func prepare() throws {
        
        for index in 0 ..< beatSetLength {
            
            let beatHighFile = try AVAudioFile(forReading: beatHighUrl)
            let beatLowFile = try AVAudioFile(forReading: beatLowUrl)
            
            guard let bufferHigh = AVAudioPCMBuffer(pcmFormat: beatHighFile.processingFormat, frameCapacity: AVAudioFrameCount(beatHighFile.length)) else {
                return
            }
            guard let bufferLow = AVAudioPCMBuffer(pcmFormat: beatLowFile.processingFormat, frameCapacity: AVAudioFrameCount(beatLowFile.length)) else {
                return
            }
            
            if index % timeSignature == 0 {
                beatSetOne.append(Beat(player: AVAudioPlayerNode(), number: 0, buffer: bufferHigh, playTime: CACurrentMediaTime()))
                engine.attach(beatSetOne[index].player)
                engine.connect(beatSetOne[index].player,
                               to: engine.mainMixerNode,
                               format: beatHighFile.processingFormat)
                try beatHighFile.read(into: beatSetOne[index].buffer)
            } else {
                beatSetOne.append(Beat(player: AVAudioPlayerNode(), number: index, buffer: bufferLow, playTime: CACurrentMediaTime()))
                engine.attach(beatSetOne[index].player)
                engine.connect(beatSetOne[index].player,
                               to: engine.mainMixerNode,
                               format: beatLowFile.processingFormat)
                try beatLowFile.read(into: beatSetOne[index].buffer)
            }
        }
        
        for index in 0 ..< beatSetLength {
            
            let beatHighFile = try AVAudioFile(forReading: beatHighUrl)
            let beatLowFile = try AVAudioFile(forReading: beatLowUrl)
            
            guard let bufferHigh = AVAudioPCMBuffer(
                pcmFormat: beatHighFile.processingFormat,
                frameCapacity: AVAudioFrameCount(beatHighFile.length)
            ) else {
                assertionFailure("Could not assign bufferHigh.")
                return
            }
            guard let bufferLow = AVAudioPCMBuffer(
                pcmFormat: beatLowFile.processingFormat,
                frameCapacity: AVAudioFrameCount(beatLowFile.length)
            ) else {
                assertionFailure("Could not assign bufferLow.")
                return
            }
            
            if index % timeSignature == 0 {
                beatSetTwo.append(Beat(player: AVAudioPlayerNode(), number: 0, buffer: bufferHigh, playTime: CACurrentMediaTime()))
                engine.attach(beatSetTwo[index].player)
                engine.connect(beatSetTwo[index].player,
                               to: engine.mainMixerNode,
                               format: beatHighFile.processingFormat)
                try beatHighFile.read(into: beatSetTwo[index].buffer)
            } else {
                beatSetTwo.append(Beat(player: AVAudioPlayerNode(), number: index, buffer: bufferLow, playTime: CACurrentMediaTime()))
                engine.attach(beatSetTwo[index].player)
                engine.connect(beatSetTwo[index].player,
                               to: engine.mainMixerNode,
                               format: beatLowFile.processingFormat)
                try beatLowFile.read(into: beatSetTwo[index].buffer)
            }
        }
        engine.prepare()
        try engine.start()
    }
    
    func setSchedule(for set: String, at startTime: TimeInterval) {
        Task.detached(priority: .background) {
            for index in 0 ..< self.beatSetLength {
                if index == 0 {
                    self.beatSetOne[index].playTime = startTime
                } else {
                    self.beatSetOne[index].playTime = self.beatSetOne[index - 1].playTime + self.beatInterval
                }
            }
        }
    }
    
    func playSetOne() {
        Task.detached(priority: .background) {
            for index in 0 ..< self.beatSetLength {
                self.beatSetOne[index].player.scheduleBuffer(self.beatSetOne[index].buffer,
                                            at: nil,
                                            options: [.interrupts],
                                            completionCallbackType: .dataPlayedBack
                ) { _ in
                    Task { @MainActor in
                        self.beatSetOne[index].player.stop()
                        if self.isMetronomePlaying {
                            if index == self.beatSetLength - 2 {
                                
                            } else if index == self.beatSetLength / 2 {
                                self.playSetTwo()
                                
                            }
                        } else {
                            self.engine.stop()
                            self.engine.detach(self.beatSetOne[index].player)
                            self.beatSetOne[index].player.stop()
                        }
                        
                    }
                }
                let time = AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: self.beatSetOne[index].playTime))
                self.beatSetOne[index].player.play(at: time)
                self.beatSetTwo[index].playTime = self.beatSetOne[index].playTime + (self.beatInterval * Double(self.beatSetLength))
            }
        }
    }
    
    func playSetTwo() {
        Task.detached(priority: .background) {
            for index in 0 ..< self.beatSetLength {
                
                self.beatSetTwo[index].player.scheduleBuffer(self.beatSetTwo[index].buffer,
                                            at: nil,
                                            options: [.interrupts],
                                            completionCallbackType: .dataPlayedBack
                ) { _ in
                    Task { @MainActor in
                        self.beatSetTwo[index].player.stop()
                        if self.isMetronomePlaying {
                            if index == self.beatSetLength - 2 {
                                
                            } else if index == self.beatSetLength / 2 {
                                self.playSetOne()
                            }
                        } else {
                            self.engine.stop()
                            self.engine.detach(self.beatSetTwo[index].player)
                            self.beatSetTwo[index].player.stop()
                        }
                    }
                }
                let time = AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: self.beatSetTwo[index].playTime))
                self.beatSetTwo[index].player.play(at: time)
                self.beatSetOne[index].playTime = self.beatSetTwo[index].playTime + (self.beatInterval * Double(self.beatSetLength))
            }
        }
    }
    
    func start(at startTime: TimeInterval) {
        isMetronomePlaying = true
        setSchedule(for: "zero", at: startTime)
        playSetOne()
    }
    
    func stopMetronome() {
        isMetronomePlaying = false
        engine.stop()
        for index in 0 ..< beatSetLength {
            beatSetOne[index].player.stop()
            engine.detach(beatSetOne[index].player)
            beatSetTwo[index].player.stop()
            engine.detach(beatSetTwo[index].player)
        }
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
    
    private var engine = AVAudioEngine()
    private var isMetronomePlaying: Bool = false
    
    private var beatSetOne: [Beat] = []
    private var beatSetTwo: [Beat] = []
    
    private var beatInterval: Double {
        60.0 / bpm
    }
    
    private var beatSetLength: Int {
        timeSignature * 2
    }
    
    private var beatHighUrl: URL {
        guard let beatHighPath = Bundle.main.path(forResource: "metrohigh.wav", ofType: nil) else {
            assertionFailure("Could not find metrohigh.wav")
            return URL(filePath: "")
        }
        return URL(filePath: beatHighPath)
    }
    private var beatLowUrl: URL {
        guard let beatLowPath = Bundle.main.path(forResource: "metrolow.wav", ofType: nil) else {
            assertionFailure("Could not find metrolow.wav")
            return URL(filePath: "")
        }
        return URL(filePath: beatLowPath)
    }
        
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
