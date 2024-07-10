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
    var currentlyPlaying: CurrentValueSubject<Session?, Never>
    var isRecording: CurrentValueSubject<Bool, Never>
    var playerProgress: CurrentValueSubject<Double, Never>
    var inputSamples: CurrentValueSubject<[SampleModel]?, Never>
    
    func startTracking() {}
    func startTracking(for session: Session) throws {}
    func stopTracking() async {}
    func stopTracking(for _: Session) async {}
    func startPlayback(for session: Session) throws {}
    func stopPlayback() {}
    func playMetronome(bpm: Double, timeSignature: Int, beat: Int) throws {}
    func stopMetronome() {}
    func removeTrack(track: Track) {}
    func toggleMute(for tracks: [Track]) {}
    func setTrackVolume(for track: Track) {}
    func getImage(for fileName: String, colorScheme: ColorScheme) throws -> Image {Image(systemName: "doc")}
    
    init() {
        trackLengthLimit = 0
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
        playerProgress = CurrentValueSubject(0.0)
        inputSamples = CurrentValueSubject(nil)
    }
}
