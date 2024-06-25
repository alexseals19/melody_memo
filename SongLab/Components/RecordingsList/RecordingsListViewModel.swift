//
//  RecordingsListViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Combine
import Foundation

protocol RecordingsListViewModelDelegate: AnyObject {
    
}

@MainActor
class RecordingsListViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var currentlyPlaying: Session?
    @Published var sessions: [Session] = []
    
    let recordingManager: RecordingManager
    let audioManager: AudioManager
        
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .assign(to: &$sessions)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
    }
    
    nonisolated func recordingCellPlayButtonTapped(for session: Session) {
        do {
            try audioManager.startPlayback(for: session)
        } catch {
            //TODO
        }
    }
    
    nonisolated func recordingCellStopButtonTapped() {
        audioManager.stopPlayback()
    }
    
    nonisolated func recordingCellTrashButtonTapped(for session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            // TODO: Handle Error
        }
    }
        
    // MARK: - Variables
    
    
}
