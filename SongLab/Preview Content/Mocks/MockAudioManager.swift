//
//  MockAudioManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

class MockAudioManager: AudioManager {
    
    var currentlyPlaying: CurrentValueSubject<Session?, Never>
    
    var isRecording: CurrentValueSubject<Bool, Never>
    
    func startTracking() {}
    
    func stopTracking() async {}
    
    func stopTracking(for _: Session) async {}
    
    func startPlayback(session: Session) {}
    
    func stopPlayback() {}
    
    init() {
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
    }
}
