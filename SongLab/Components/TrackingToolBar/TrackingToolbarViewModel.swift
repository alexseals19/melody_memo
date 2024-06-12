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
    @Published var isRecording: Bool = false
        
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        audioManager.isRecording
            .assign(to: &$isRecording)
    }
    
    // MARK: - Variables
    
    private let audioManager: AudioManager
    
    // MARK: - Functions
    
    func recordButtonAction() {
        if isRecording {
            Task{
                await audioManager.stopTracking()
            }
        } else {
            audioManager.startTracking()
        }
    }
}
