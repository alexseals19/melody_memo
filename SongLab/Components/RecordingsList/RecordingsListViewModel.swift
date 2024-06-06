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
    
    @Published var currentlyPlaying: Recording?
    @Published var recordings: [Recording] = []
    
    init(recordingManager: RecordingManager) {
        self.recordingManager = recordingManager
        recordings = self.recordingManager.getRecordings()
        self.recordingManager.delegate = self
    }
    
    public func doSomethingPublic() {}
    
    // MARK: - Variables
    
    private var recordingManager: RecordingManager
}

extension RecordingsListViewModel: RecordingManagerDelegate {
    func recordingManagerDidUpdate(recordings: [Recording]) {
        self.recordings = recordings
    }
}
