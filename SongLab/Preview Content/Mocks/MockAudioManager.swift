//
//  MockAudioManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

class MockAudioManager: AudioManager {
    
    var audioIsPlaying: CurrentValueSubject<Bool, Never>
    
    var isRecording: CurrentValueSubject<Bool, Never>
    
    func startTracking() {}
    
    func stopTracking() async {}
    
    func startPlayback(recording: Session) {}
    
    func stopPlayback() {}
    
    init() {
        audioIsPlaying = CurrentValueSubject(false)
        isRecording = CurrentValueSubject(false)
    }
}
