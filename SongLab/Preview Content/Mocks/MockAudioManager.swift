//
//  MockAudioManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation
import AVFoundation

class MockAudioManager: AudioManager {
    var currentlyPlaying: CurrentValueSubject<Session?, Never>
    var isRecording: CurrentValueSubject<Bool, Never>
    
    func startTracking() {}
    func startTracking(for session: Session) throws {}
    func stopTracking() async {}
    func stopTracking(for _: Session) async {}
    func startPlayback(for tracks: [Track], session: Session) throws {}
    func stopPlayback() {}
    func playMetronome(bpm: Double, timeSignature: Int, beat: Int) throws {}
    func stopMetronome() {}
    
    init() {
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
    }
}
