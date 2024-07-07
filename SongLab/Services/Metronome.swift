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
    var downBuffer: AVAudioPCMBuffer
    var offBuffer: AVAudioPCMBuffer
    
    init(player: AVAudioPlayerNode, 
         downBuffer: AVAudioPCMBuffer,
         offBuffer: AVAudioPCMBuffer
    ) {
        self.player = player
        self.downBuffer = downBuffer
        self.offBuffer = offBuffer
    }
    
    init() {
        player = AVAudioPlayerNode()
        downBuffer = AVAudioPCMBuffer()
        offBuffer = AVAudioPCMBuffer()
    }
}

@MainActor
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
        
        let beatHighFile = try AVAudioFile(forReading: beatHighUrl)
        let beatLowFile = try AVAudioFile(forReading: beatLowUrl)
        
        guard let bufferHigh = AVAudioPCMBuffer(pcmFormat: beatHighFile.processingFormat, frameCapacity: AVAudioFrameCount(beatHighFile.length)) else {
            return
        }
        guard let bufferLow = AVAudioPCMBuffer(pcmFormat: beatLowFile.processingFormat, frameCapacity: AVAudioFrameCount(beatLowFile.length)) else {
            return
        }
        
        metronome = Beat(player: AVAudioPlayerNode(), downBuffer: bufferHigh, offBuffer: bufferLow)

        engine.attach(metronome.player)
        engine.connect(metronome.player,
                       to: engine.mainMixerNode,
                       format: beatHighFile.processingFormat)
        try beatHighFile.read(into: metronome.downBuffer)
        try beatLowFile.read(into: metronome.offBuffer)
        
        engine.prepare()
        try engine.start()
    }
    
    func start(at startTime: AVAudioTime) {
        isMetronomePlaying = true
        
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
        let timer = Timer.publish(every: 60 / bpm, on: RunLoop.main, in: .common).autoconnect()
        
        subscription = timer.sink { date in
            do {
                try self.playBeat()
            } catch {}
        }
    }
    
    func playBeat() throws {
                        
        metronome.player.scheduleBuffer(
            beatCount % timeSignature == 0 ? metronome.downBuffer : metronome.offBuffer,
            at: nil,
            options: [.interrupts],
            completionCallbackType: .dataPlayedBack
        ) { _ in
            Task { @MainActor in
                if self.isMetronomePlaying {
                    self.metronome.player.stop()
                } else {
                    self.engine.stop()
                    self.engine.detach(self.metronome.player)
                    self.metronome.player.stop()
                }
            }
        }
        metronome.player.play()
        
        beatCount += 1
    }
    
    func stopMetronome() {
        isMetronomePlaying = false
        subscription?.cancel()
        beatCount = 0
        self.engine.stop()
        self.engine.detach(metronome.player)
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
    
    private var lastPlayTime: TimeInterval = 0
    private var metronome = Beat()
    private var engine = AVAudioEngine()
    private var firstBeat: Bool = true
    private var isMetronomePlaying: Bool = false
    private var beatCount: Int = 0
    private var now: AVAudioFramePosition = 0
    
    private var beatHighUrl: URL {
        guard let beatHighPath = Bundle.main.path(forResource: "metrohigh.wav", ofType: nil) else {
            print("Could not find metronome.wav")
            return URL(filePath: "")
        }
        return URL(filePath: beatHighPath)
    }
    private var beatLowUrl: URL {
        guard let beatLowPath = Bundle.main.path(forResource: "metrolow.wav", ofType: nil) else {
            print("Could not find metronome.wav")
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
