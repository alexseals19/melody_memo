//
//  RecordingManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import AVKit

protocol RecordingManager {
    func recordRecording()
    func playRecording(id: UUID)
    func requestPermission() async
}

class DefaultRecordingManager: RecordingManager {
    
    static let shared = DefaultRecordingManager(session: AVAudioSession(), recorder: AVAudioRecorder())
    
    private var session: AVAudioSession
    private var recorder: AVAudioRecorder
    private var isRecording = false
    
    func recordRecording() {}
    
    func playRecording(id: UUID) {}
    
    func requestPermission() async {}
    
    private init(session: AVAudioSession, recorder: AVAudioRecorder) {
        self.session = session
        self.recorder = recorder
    }
}

class MockRecordingManager: RecordingManager {
    func recordRecording() {}
    
    func playRecording(id: UUID) {}
    
    func requestPermission() {}
}
