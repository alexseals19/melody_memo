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
    
    @Published var currentlyPlaying: SessionGroup?
    @Published var isUpdatingSessionModels: Bool?
    @Published var sessions: [Session] = []
    @Published var playerProgress: Double = 0.0
    @Published var nameChangeText: String = ""
    
    @Published var errorMessage: String?
    @Published var isEditingSession: Session?
    
    let recordingManager: RecordingManager
    let audioManager: AudioManager
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .assign(to: &$sessions)
        recordingManager.isUpdatingSessionModels
            .assign(to: &$isUpdatingSessionModels)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
        audioManager.playerProgress
            .assign(to: &$playerProgress)
    }
    
    func sessionCellPlayButtonTapped(for group: SessionGroup) {
        do {
            try audioManager.startPlayback(for: group, at: 0.0)
        } catch {
            errorMessage = "ERROR: Cannot play session."
        }
    }
    
    func sessionCellStopButtonTapped() {
        
        guard let currentlyPlaying else {
            return
        }
        
        var group = currentlyPlaying
        
        do {
            try audioManager.stopPlayback(stopTimer: true)
        } catch {
            errorMessage = "ERROR: Could not stop playback."
        }
        
        if let  session = sessions.first (where:  { $0.id == group.id } ) {
            var updatedSession = session
            group.lastPlayheadPosition = 0.0
            updatedSession.groups[group.id] = group
            if updatedSession.armedGroup.id == group.id {
                updatedSession.armedGroup = group
            }
            do {
                try recordingManager.updateSession(updatedSession)
            } catch {
                errorMessage = "ERROR: Could not update session."
            }
        }
        
    }
    
    func sessionCellTrashButtonTapped(for session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            errorMessage = "ERROR: Cannot remove session."
        }
    }
    
    func sessionNameDidChange(session: Session, name: String) {
        var updatedSession = session
        updatedSession.name = name
        do {
            try recordingManager.saveSession(updatedSession)
        } catch {
            errorMessage = "ERROR: Could not update session."
        }
        nameChangeText = ""
    }
    
    // MARK: - Variables
    
}
