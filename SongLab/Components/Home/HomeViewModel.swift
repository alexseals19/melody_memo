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
    
    @Published var isSettingsPresented: Bool = false
    @Published var inputSamples: [SampleModel]?
    @Published var trackTimer: Double = 0.0
    
    @Published var errorMessage: String?
    @Published var selectedSession: Session?
    
    @Published var isMetronomeArmed: Bool {
        didSet {
            
            Task {
                await metronome.setIsArmed(value: isMetronomeArmed)
                await metronome.saveSettings()
            }
        }
    }
    
    @Published var metronomeBpm: Double {
        didSet {
            Task {
                await metronome.setBpm(newBpm: metronomeBpm)
                await metronome.saveSettings()
            }
        }
    }
    
    @Published var metronomeVolume: Float {
        didSet {
            Task {
                await metronome.setVolume(newVolume: metronomeVolume)
            }
        }
    }
    
    @Published var isCountInActive: Bool {
        didSet {
            Task {
                await metronome.setIsCountInActive(value: isCountInActive)
            }
        }
    }
    
    @Published var isRecording: Bool = false {
        didSet {
            if isRecording {
                if let selectedSession {
                    Task {
                        do {
                            try await audioManager.startTracking(for: selectedSession)
                        } catch {
                            errorMessage = "ERROR: Could not begin recording."
                        }
                    }
                } else {
                    do {
                        try audioManager.stopPlayback(stopTimer: false)
                    } catch {
                        errorMessage = "ERROR: Could not stop playback."
                    }
                    Task {
                        do {
                            try await audioManager.startTracking()
                        } catch {
                            errorMessage = "ERROR: Could not begin recording."
                        }
                    }
                }
            } else {
                if let selectedSession {
                    Task {
                        do {
                            try await audioManager.stopTracking(for: selectedSession)
                        } catch {
                            errorMessage = "ERROR: Could not stop recording."
                        }
                    }
                } else {
                    Task {
                        do {
                            try await audioManager.stopTracking()
                        } catch {
                            errorMessage = "ERROR: Could not stop recording."
                        }
                    }
                }
            }
        }
    }
    
    func sessionDetailDismissButtonTapped() {
        if isRecording {
            isRecording.toggle()
        }
    }
    
    let audioManager: AudioManager
    let recordingManager: RecordingManager
    
    var metronome = Metronome.shared
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        self.isMetronomeArmed = false
        self.metronomeBpm = 120
        self.metronomeVolume = 1
        self.isCountInActive = false
        recordingManager.sessions
            .compactMap { $0.first { $0.id == self.selectedSession?.id }}
            .assign(to: &$selectedSession)  
        audioManager.inputSamples
            .assign(to: &$inputSamples)
        audioManager.playerProgress
            .assign(to: &$trackTimer)
        
        setVariables()
        
    }
    
    // MARK: - Variables
    
    // MARK: - Functions
    
    private func setVariables() {
        Task {
            await isMetronomeArmed = metronome.isArmed
            await metronomeBpm = metronome.bpm
            await metronomeVolume = metronome.volume
            await isCountInActive = metronome.isCountInActive
        }
    }
}
