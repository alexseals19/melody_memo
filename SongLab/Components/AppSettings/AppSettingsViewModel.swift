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
    
    @Published var metronomeBpm: Double {
        didSet {
            metronome.bpm = metronomeBpm
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
        self.metronomeBpm = metronome.bpm
        self.trackLengthLimit = audioManager.trackLengthLimit
    }
    
    func saveSettings() {
        metronome.saveSettings()
    }
    
    func setTrackLengthLimit(increase: Bool) {
        let limit = audioManager.trackLengthLimit
        if increase, limit < 5 {
            audioManager.trackLengthLimit += 1
        } else if !increase, limit > 0 {
            audioManager.trackLengthLimit -= 1
        }
    }
    
    // MARK: - Variables
    
    private var metronome: Metronome
    private var audioManager: AudioManager
    
    // MARK: - Functions
    
}
