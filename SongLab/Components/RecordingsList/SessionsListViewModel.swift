//
//  SessionsListViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class SessionsListViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var currentlyPlaying: Session?
    @Published var sessions: [Session] = []
    @Published var playerProgress: Double = 0.0
    
    @Published var errorMessage: String?
    
    let recordingManager: RecordingManager
    let audioManager: AudioManager
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .assign(to: &$sessions)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
        audioManager.playerProgress
            .assign(to: &$playerProgress)
    }
    
    func sessionCellPlayButtonTapped(for session: Session) {
        do {
            try audioManager.startPlayback(for: session)
        } catch {
            errorMessage = "ERROR: Cannot play session."
        }
    }
    
    func sessionCellStopButtonTapped() {
        do {
            try audioManager.stopPlayback()
        } catch {
            errorMessage = "ERROR: Could not stop playback."
        }
    }
    
    func sessionCellTrashButtonTapped(for session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            errorMessage = "ERROR: Cannot remove session."
        }
    }
    
    // MARK: - Variables
    
}
