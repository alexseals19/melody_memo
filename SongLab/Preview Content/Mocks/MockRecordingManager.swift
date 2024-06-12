//
//  MockRecordingManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

class MockRecordingManager: RecordingManager {
    
    var sessions: CurrentValueSubject<[Session], Never>
    
    func removeSession(_ session: Session) throws {}
    
    func removeTrack(_ track: Track) throws {}
    
    func saveRecording(_ recording: Session) throws {}
    
    init() {
        sessions = CurrentValueSubject([])
    }
}
