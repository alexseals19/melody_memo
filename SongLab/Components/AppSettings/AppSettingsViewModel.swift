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
    
    init(metronome: Metronome) {
        self.metronome = metronome
        self.metronomeBpm = metronome.bpm
    }
    
    func saveSettings() {
        metronome.saveSettings()
    }
    
    // MARK: - Variables
    
    private let metronome: Metronome
    
    // MARK: - Functions
    
}
