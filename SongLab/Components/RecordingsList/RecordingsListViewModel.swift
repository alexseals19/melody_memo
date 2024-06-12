//
//  RecordingsListViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Combine
import Foundation

@MainActor
class RecordingsListViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var currentlyPlaying: Session? {
        didSet {
            if currentlyPlaying != nil {
                guard let session = currentlyPlaying else {
                    assertionFailure("Could not set recording")
                    return
                }
                audioManager.startPlayback(recording: session)
            } else {
                audioManager.stopPlayback()
            }
        }
    }
    
    @Published var sessions: [Session] = []
    @Published var audioIsPlaying: Bool = false
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .assign(to: &$sessions)
        audioManager.audioIsPlaying
            .assign(to: &$audioIsPlaying)
    }
    
    func trashButtonAction(_ session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            // TODO: Handle Error
        }
        
    }
        
    // MARK: - Variables
    
    private let audioManager: AudioManager
    private let recordingManager: RecordingManager
}
