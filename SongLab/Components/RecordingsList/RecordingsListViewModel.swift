//
//  RecordingsListViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

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
                audioManager.removeRecording(with: recording.name)
            }
        }
    }
    
    @Published var recordings: [Recording] = []
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        recordings = self.audioManager.getRecordings()
        self.audioManager.delegate = self
    }
        
    // MARK: - Variables
    
    private var audioManager: AudioManager
    
}

extension RecordingsListViewModel: AudioManagerDelegate {
    func audioManagerDidUpdate(recordings: [Recording]) {
        self.recordings = recordings
    }
}
