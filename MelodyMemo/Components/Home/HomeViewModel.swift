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
    @Published var metronomeBpm: Int = 120
    
    @Published var errorMessage: String?
    @Published var selectedSession: Session?
    
    @Published var didFinishRecording: Bool = false
    
    var sessionBpm: Int {
        if let selectedSession, selectedSession.sessionBpm != 0, !selectedSession.isUsingGlobalBpm {
            Task {
                await metronome.setSessionBpm(selectedSession.sessionBpm)
            }
            return selectedSession.sessionBpm
        } else {
            Task {
                await metronome.setSessionBpm(nil)
            }
            return metronomeBpm
        }
    }
    
    @Published var isMetronomeArmed: Bool {
        didSet {
            Task {
                await metronome.setIsArmed(value: isMetronomeArmed)
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
                            try await audioManager.startTracking(for: selectedSession.armedGroup)
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
                            try await audioManager.startTracking(for: nil)
                        } catch {
                            errorMessage = "ERROR: Could not begin recording."
                        }
                    }
                }
            } else {
                if let selectedSession {
                    Task {
                        do {
                            try await audioManager.stopTracking(for: selectedSession, group: selectedSession.armedGroup)
                            didFinishRecording.toggle()
                        } catch {
                            errorMessage = "ERROR: Could not stop recording."
                        }
                    }
                } else {
                    Task {
                        do {
                            try await audioManager.stopTracking(for: nil, group: nil)
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
    
    func saveSettings() {
        Task {
            await metronome.saveSettings()
        }
    }
    
    func resetTapIn() {
        Task {
            await metronome.resetTapIn()
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
        
        setAssignments()
        setVariables()
        
    }
    
    // MARK: - Variables
    
    // MARK: - Functions
    
    private func setVariables() {
        Task {
            await isMetronomeArmed = metronome.isArmed
            await metronomeVolume = metronome.volume
            await isCountInActive = metronome.isCountInActive
        }
    }
    
    private func setAssignments() {
        recordingManager.sessions
            .compactMap { $0.first { $0.id == self.selectedSession?.id }}
            .assign(to: &$selectedSession)
        audioManager.inputSamples
            .assign(to: &$inputSamples)
        audioManager.playerProgress
            .assign(to: &$trackTimer)
        Task {
            await metronome.bpm
                .assign(to: &$metronomeBpm)
        }
    }
}
