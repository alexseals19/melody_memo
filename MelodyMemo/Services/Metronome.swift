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

struct TapInModel {
    var date = Date()
    var interval: TimeInterval
}

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

actor Metronome {
    
    //MARK: - API
    
    static let shared = Metronome()
    
    var bpm: CurrentValueSubject<Int, Never>
    
    var taps: [TapInModel] = []
    
    var timeSignature: Int
    var isArmed: Bool
    var isCountInActive: Bool
    var volume: Float
    
    var lockEngine: Bool = false
    
    var countInDelay: Double {
        if isArmed, isCountInActive {
            return 60 / Double(bpm.value) * Double(timeSignature)
        }
        return 0.0
    }
    
    func prepare() throws {
                
        beatSetOne.removeAll()
        beatSetTwo.removeAll()
        
        engine = AVAudioEngine()
        guard let mainMixerNode = engine?.mainMixerNode else {
            return
        }
        
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
                beatSetOne[index].player.volume = volume
                engine?.attach(beatSetOne[index].player)
                engine?.connect(beatSetOne[index].player,
                               to: mainMixerNode,
                               format: beatHighFile.processingFormat)
                try beatHighFile.read(into: beatSetOne[index].buffer)
            } else {
                beatSetOne.append(Beat(player: AVAudioPlayerNode(), number: index, buffer: bufferLow, playTime: CACurrentMediaTime()))
                beatSetOne[index].player.volume = volume
                engine?.attach(beatSetOne[index].player)
                engine?.connect(beatSetOne[index].player,
                               to: mainMixerNode,
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
                beatSetTwo[index].player.volume = volume
                engine?.attach(beatSetTwo[index].player)
                engine?.connect(beatSetTwo[index].player,
                               to: mainMixerNode,
                               format: beatHighFile.processingFormat)
                try beatHighFile.read(into: beatSetTwo[index].buffer)
            } else {
                beatSetTwo.append(Beat(player: AVAudioPlayerNode(), number: index, buffer: bufferLow, playTime: CACurrentMediaTime()))
                beatSetTwo[index].player.volume = volume
                engine?.attach(beatSetTwo[index].player)
                engine?.connect(beatSetTwo[index].player,
                               to: mainMixerNode,
                               format: beatLowFile.processingFormat)
                try beatLowFile.read(into: beatSetTwo[index].buffer)
            }
        }
        engine?.prepare()
        try engine?.start()
    }
    
    func start(at startTime: TimeInterval) {
        isMetronomePlaying = true
        setSchedule(at: startTime)
        playSetOne()
    }
    
    func stopMetronome() {
        isMetronomePlaying = false
        engine?.stop()
        for index in 0 ..< beatSetLength {
            beatSetOne[index].player.stop()
            beatSetTwo[index].player.stop()
            engine?.detach(beatSetOne[index].player)
            engine?.detach(beatSetTwo[index].player)
        }
        
        engine = nil
    }
    
    func saveSettings() {
        do {
            try DataPersistenceManager.save(bpm.value, to: "bpm")
            try DataPersistenceManager.save(timeSignature, to: "timeSignature")
            try DataPersistenceManager.save(isArmed, to: "isArmed")
            try DataPersistenceManager.save(isCountInActive, to: "isCountInActive")
            try DataPersistenceManager.save(volume, to: "volume")
        } catch {}
    }
    
    func tapInCalculator() {
        if taps.isEmpty {
            taps.append(TapInModel(interval: 0.0))
        } else {
            taps.append(TapInModel(interval: Date().timeIntervalSince(taps[taps.count - 1].date)))
            
            var intervalTotal: Double = 0.0
            
            for tap in taps {
                intervalTotal += tap.interval
            }
            let averageInterval = intervalTotal / Double(taps.count)
            let newBpm = 60 / averageInterval
            
            Task { @MainActor in
                await bpm.send(Int(newBpm))
            }
        }
        
        if taps.count == 5 {
            taps.removeFirst()
        }
    }
    
    func setBpm(newBpm: Int) {
        Task { @MainActor in
            await bpm.send(newBpm)
        }
    }
    
    func setIsArmed(value: Bool) {
        isArmed = value
    }
    
    func setVolume(newVolume: Float) {
        volume = newVolume
    }
    
    func setIsCountInActive(value: Bool) {
        isCountInActive = value
    }
    
    //MARK: - Variables
    
    private var engine: AVAudioEngine?
    private var isMetronomePlaying: Bool = false
    
    private var beatSetOne: [Beat] = []
    private var beatSetTwo: [Beat] = []
    
    private var subscription: AnyCancellable?
    
    private var beatInterval: Double {
        60.0 / Double(bpm.value)
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
            bpm = CurrentValueSubject(try DataPersistenceManager.retrieve(Int.self, from: "bpm"))
            bpm.send(bpm.value)
            timeSignature = try DataPersistenceManager.retrieve(Int.self, from: "timeSignature")
            isArmed = try DataPersistenceManager.retrieve(Bool.self, from: "isArmed")
            isCountInActive = try DataPersistenceManager.retrieve(Bool.self, from: "isCountInActive")
            volume = try DataPersistenceManager.retrieve(Float.self, from: "volume")
        } catch {
            bpm = CurrentValueSubject(130)
            timeSignature = 4
            isArmed = false
            isCountInActive = false
            volume = 1.0
        }
    }
    
    private func setSchedule(at startTime: TimeInterval) {
        for index in 0 ..< self.beatSetLength {
            if index == 0 {
                self.beatSetOne[index].playTime = startTime
            } else {
                self.beatSetOne[index].playTime = self.beatSetOne[index - 1].playTime + self.beatInterval
            }
        }
    }
    
    private func playSetOne() {
        for index in 0 ..< self.beatSetLength {
            if self.isMetronomePlaying {
                self.beatSetOne[index].player.scheduleBuffer(self.beatSetOne[index].buffer,
                                            at: nil,
                                            options: [.interrupts],
                                            completionCallbackType: .dataPlayedBack
                ) { _ in
                    Task { @MainActor in
                        await self.beatSetOne[index].player.stop()
                        if await self.isMetronomePlaying {
                            if await index == self.beatSetLength - 2 {
                                
                            } else if await index == self.beatSetLength / 2 {
                                await self.playSetTwo()
                                
                            }
                        }
                        
                    }
                }
                let time = AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: self.beatSetOne[index].playTime))
                self.beatSetOne[index].player.play(at: time)
                self.beatSetTwo[index].playTime = self.beatSetOne[index].playTime + (self.beatInterval * Double(self.beatSetLength))
            }
        }
    }
    
    private func playSetTwo() {
        for index in 0 ..< self.beatSetLength {
            if self.isMetronomePlaying {
                self.beatSetTwo[index].player.scheduleBuffer(self.beatSetTwo[index].buffer,
                                            at: nil,
                                            options: [.interrupts],
                                            completionCallbackType: .dataPlayedBack
                ) { _ in
                    Task { @MainActor in
                        await self.beatSetTwo[index].player.stop()
                        if await self.isMetronomePlaying {
                            if await index == self.beatSetLength - 2 {
                                
                            } else if await index == self.beatSetLength / 2 {
                                await self.playSetOne()
                            }
                        }
                    }
                }
                let time = AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: self.beatSetTwo[index].playTime))
                self.beatSetTwo[index].player.play(at: time)
                self.beatSetOne[index].playTime = self.beatSetTwo[index].playTime + (self.beatInterval * Double(self.beatSetLength))
            }
        }
    }
}
