//
//  HomeViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var selectedSession: Session?
    @Published var appTheme: String = "superglass"
    
    @Published var isRecording: Bool = false {
        didSet {
            if isRecording {
                audioManager.startTracking()
            } else {
                Task{
                    if let selectedSession {
                        await audioManager.stopTracking(for: selectedSession)
                    } else {
                        await audioManager.stopTracking()
                    }
                }
            }
        }
    }
    
    let audioManager: AudioManager
    let recordingManager: RecordingManager
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .compactMap { $0.first { $0.id == self.selectedSession?.id }}
            .assign(to: &$selectedSession)        
    }
    
    // MARK: - Variables
    
    
    // MARK: - Functions
    
}
