//
//  HomeViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var selectedSession: Session?
    @Published var isSettingsPresented: Bool = false
    @Published var inputSamples: [Float]?
    @Published var trackTimer: Double = 0.0
    
    @Published var isMetronomeArmed: Bool {
        didSet {
            metronome.isArmed = isMetronomeArmed
            metronome.saveSettings()
        }
    }
    
    @Published var metronomeBpm: Double {
        didSet {
            metronome.bpm = metronomeBpm
            metronome.saveSettings()
        }
    }
    
    @Published var isCountInActive: Bool {
        didSet {
            metronome.isCountInActive = isCountInActive
        }
    }
    
    @Published var isRecording: Bool = false {
        didSet {
            if isRecording {
                if let selectedSession {
                    do {
                        try audioManager.startTracking(for: selectedSession)
                    } catch {
                        //TODO
                    }
                } else {
                    audioManager.stopPlayback(stopTimer: true)
                    do {
                        try audioManager.startTracking()
                    } catch {
                        //TODO
                        print(error.localizedDescription)
                    }
                }
            } else {
                Task{
                    if let selectedSession {
                        await audioManager.stopTracking(for: selectedSession)
                    } else {
                        await audioManager.stopTracking()
                    }
                }
            }
        }
    }
    
    let audioManager: AudioManager
    let recordingManager: RecordingManager
    
    var metronome = Metronome.shared
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        self.isMetronomeArmed = metronome.isArmed
        self.metronomeBpm = metronome.bpm
        self.isCountInActive = metronome.isCountInActive
        recordingManager.sessions
            .compactMap { $0.first { $0.id == self.selectedSession?.id }}
            .assign(to: &$selectedSession)  
        audioManager.inputSamples
            .assign(to: &$inputSamples)
        audioManager.playerProgress
            .assign(to: &$trackTimer)
        
    }
    
    // MARK: - Variables
    
    // MARK: - Functions
    
}
