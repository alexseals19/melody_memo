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
    @Published var isRecording = false {
        didSet {
            if isRecording {
                startTracking()
            } else {
                stopTracking()
            }
        }
    }
    
    init(recordingManager: RecordingManager) {
        self.recordingManager = recordingManager
    }
    
    // MARK: - Variables
    
    private let recordingManager: RecordingManager
    
    // MARK: - Functions
    
    private func playRecording(_ recording: Recording) {
        recordingManager.playRecording(id: recording.id)
    }
    
    private func startTracking() {
        recordingManager.startTracking()
    }
    
    private func stopTracking() {
        recordingManager.stopTracking()
    }
    
    private func setUpSession(_ recording: Recording) async {
        recordingManager.setUpSession()
    }
}
