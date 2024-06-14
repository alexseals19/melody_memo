//
//  TrackingToolbarViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation

@MainActor
class TrackingToolbarViewModel: ObservableObject {
    
    //MARK: - API
    
    var metronomeActive = false
        
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
    }
    
    // MARK: - Variables
    
    private let audioManager: AudioManager
}
