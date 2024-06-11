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
    
    @Published var currentlyPlaying: Recording? {
        didSet {
            if currentlyPlaying != nil {
                guard let recording = currentlyPlaying else {
                    assertionFailure("Could not set recording")
                    return
                }
                audioManager.startPlayback(recording: recording)
            } else {
                audioManager.stopPlayback()
            }
        }
    }
    
    @Published var removeRecording: Recording? {
        didSet {
            if let recording = removeRecording {
                do {
                    try recordingManager.removeRecording(recording)
                } catch {
                    // TODO: Handle error
                }
            }
        }
    }
    
    @Published var recordings: [Recording] = []
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.recordings
            .assign(to: &$recordings)
    }
        
    // MARK: - Variables
    
    private let audioManager: AudioManager
    private let recordingManager: RecordingManager
}
