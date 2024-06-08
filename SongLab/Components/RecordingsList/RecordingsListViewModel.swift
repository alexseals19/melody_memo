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
                startPlayback()
            } else {
                playbackManager.stopPlayback()
            }
            
        }
    }
    
    @Published var removeRecording: Recording? {
        didSet {
            if let recording = removeRecording {
                recordingManager.removeRecording(with: recording.name)
            }
        }
    }
    
    @Published var recordings: [Recording] = []
    
    init(recordingManager: RecordingManager, playbackManager: PlaybackManager) {
        self.recordingManager = recordingManager
        self.playbackManager = playbackManager
        recordings = self.recordingManager.getRecordings()
        self.recordingManager.delegate = self
    }
    
    public func doSomethingPublic() {}
    
    // MARK: - Variables
    
    private var recordingManager: RecordingManager
    private var playbackManager: PlaybackManager
    
    private func startPlayback() {
        if let recording = currentlyPlaying {
            playbackManager.startPlayback(recording: recording)
        } else {}
    }
}

extension RecordingsListViewModel: RecordingManagerDelegate {
    func recordingManagerDidUpdate(recordings: [Recording]) {
        self.recordings = recordings
    }
}
