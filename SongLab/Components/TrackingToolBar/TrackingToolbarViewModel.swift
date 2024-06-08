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
                Task {
                    await stopTracking()
                }
            }
        }
    }
    
    init(recordingManager: RecordingManager) {
        self.recordingManager = recordingManager
    }
    
    // MARK: - Variables
    
    private let recordingManager: RecordingManager
    
    // MARK: - Functions
   
    private func startTracking() {
        recordingManager.startTracking()
    }
    
    private func stopTracking() async {
        await recordingManager.stopTracking()
    }
    
    private func setUpSession(_ recording: Recording) {
        recordingManager.setUpSession()
    }
}
