//
//  MockAudioManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation
import AVFoundation
import SwiftUI

class MockAudioManager: AudioManager {
    var trackLengthLimit: Int
    var currentlyPlaying: CurrentValueSubject<SessionGroup?, Never>
    var isRecording: CurrentValueSubject<Bool, Never>
    var playerProgress: CurrentValueSubject<Double, Never>
    var lastPlayheadPosition: CurrentValueSubject<Double, Never>
    var inputSamples: CurrentValueSubject<[SampleModel]?, Never>
    
    func startTracking(for group: SessionGroup?) throws {}
    func stopTracking(for _: Session?, group: SessionGroup?) async {}
    func startPlayback(for group: SessionGroup, at time: Double) throws {}
    func stopPlayback(stopTimer: Bool) {}
    func playMetronome(bpm: Double, timeSignature: Int, beat: Int) throws {}
    func stopMetronome() {}
    func removeTrack(track: Track) {}
    func toggleMute(for tracks: [Track]) {}
    func setTrackVolume(for track: Track) {}
    func setTrackPan(for track: Track) {}
    func getImage(for fileName: String, colorScheme: ColorScheme) throws -> UIImage {UIImage(imageLiteralResourceName: "waveform")}
    func updateCurrentlyPlaying(_ group: SessionGroup) {}
    func updatePlayheadPosition(position: Double) {}
    func stopTimer(willReset: Bool) {}
    func setLastPlayheadPosition(_ position: Double) {}
    func loopIndicatorChangedPosition() throws {}
    func restartPlayback(from position: Double) throws {}
    
    init() {
        trackLengthLimit = 0
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
        playerProgress = CurrentValueSubject(0.0)
        lastPlayheadPosition = CurrentValueSubject(0.0)
        inputSamples = CurrentValueSubject(nil)
    }
}
