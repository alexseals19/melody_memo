//
//  Metronome.swift
//  SongLab
//
//  Created by Alex Seals on 6/19/24.
//

import Foundation
import AVFoundation
import SwiftUI

class Metronome: Observable {
    
    //MARK: - API
    
    @AppStorage("bpm") var bpm: Int = 120
        
    func playMetronome(timeSignature: Int, beat: Int) throws {
        
        let beatInterval: Double = 60 / Double(bpm)
        
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
            metronomeActive = true
            beatOffset = 0.5 * sampleRate
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
                if self.metronomeActive {
                    try self.playMetronome(
                        timeSignature: timeSignature,
                        beat: beat == timeSignature - 1 ? 0 : beat + 1
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
        metronomeActive = false
        metronome.stop()
        self.engine.stop()
        self.engine.detach(metronome)
        firstBeat = true
    }
    
    //MARK: - Variables
    
    private var metronome = AVAudioPlayerNode()
    private var engine = AVAudioEngine()
    private var firstBeat: Bool = true
    private var metronomeActive: Bool = true
}
