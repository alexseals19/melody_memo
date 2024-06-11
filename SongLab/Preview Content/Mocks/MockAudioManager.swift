//
//  MockAudioManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Foundation

class MockAudioManager: AudioManager {
    
    func startTracking() {}
    
    func stopTracking() async {}
    
    func startPlayback(recording: Recording) {}
    
    func stopPlayback() {}
}
