//
//  MockRecordingManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

class MockRecordingManager: RecordingManager {
    
    var recordings: CurrentValueSubject<[Recording], Never>
    
    func removeRecording(_ recording: Recording) throws {}
    
    func saveRecording(_ recording: Recording) throws {}
    
    init() {
        recordings = CurrentValueSubject([])
    }
}
