//
//  RecordingsListViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class RecordingsListViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var currentlyPlaying: Session?
    @Published var sessions: [Session] = []
    @Published var playerProgress: Double = 0.0
    
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
    
    func recordingCellPlayButtonTapped(for session: Session) {
        do {
            try audioManager.startPlayback(for: session)
        } catch {
            //TODO
        }
    }
    
    func recordingCellStopButtonTapped() {
        audioManager.stopPlayback(stopTimer: true)
    }
    
    func recordingCellTrashButtonTapped(for session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            // TODO: Handle Error
        }
    }
    
    // MARK: - Variables
    
}
