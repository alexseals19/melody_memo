//
//  AppSettingsViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/19/24.
//

import Foundation

@MainActor
class AppSettingsViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var metronomeBpm: Int = 120
    @Published var timeSignature: Int = 4 {
        didSet {
            Task {
                await metronome.setTimeSignature(timeSignature)
            }
        }
    }
        
    @Published var trackLengthLimit: Int {
        didSet {
            audioManager.trackLengthLimit = trackLengthLimit
        }
    }
    
    init(metronome: Metronome, audioManager: AudioManager) {
        self.metronome = metronome
        self.audioManager = audioManager
        self.trackLengthLimit = audioManager.trackLengthLimit
        setAssignment()
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
    
    func setTrackLengthLimit(increase: Bool) {
        let limit = audioManager.trackLengthLimit
        if increase, limit < 5 {
            audioManager.trackLengthLimit += 1
        } else if !increase, limit > 0 {
            audioManager.trackLengthLimit -= 1
        }
    }
    
    func setBpm(bpm: Int) {
        Task {
            await metronome.setBpm(newBpm: bpm)
        }
    }
    
    func addTap() {
        Task {
            await metronome.tapInCalculator()
        }
    }
    
    // MARK: - Variables
    
    private var metronome: Metronome
    private var audioManager: AudioManager
    
    // MARK: - Functions
    
    private func setAssignment() {
        Task {
            timeSignature = await metronome.timeSignature
            await metronome.bpm
                .assign(to: &$metronomeBpm)
        }
    }
    
}
