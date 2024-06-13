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
        
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .assign(to: &$sessions)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
    }
    
    func recordingCellPlayButtonTapped(for session: Session) {
        audioManager.startPlayback(session: session)
    }
    
    func recordingCellStopButtonTapped() {
        audioManager.stopPlayback()
    }
    
    func recordingCellTrashButtonTapped(for session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            // TODO: Handle Error
        }
    }
    
    func sessionDetailViewDidAppear(for session: Session) {
        
    }
    
    func sessionDetailViewDidDisappear() {
        
    }
        
    // MARK: - Variables
    
    private let audioManager: AudioManager
}
