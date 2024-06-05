//
//  TrackingToolbarViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation

@MainActor
class TrackingToolBarViewModel: ObservableObject {
    
    //MARK: - API
    
    init(recordingManager: RecordingManager) {
        self.recordingManager = recordingManager
    }
    
    // MARK: - Variables
    
    private let recordingManager: RecordingManager
    
    // MARK: - Functions
    
    private func playRecording(_ recording: Recording) {
        recordingManager.playRecording(id: recording.id)
    }
    
    private func recordRecording(_ recording: Recording) {
        recordingManager.recordRecording()
    }
}
