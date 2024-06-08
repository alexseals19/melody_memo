//
//  PlaybackManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import AVFoundation

@MainActor
protocol PlaybackManager {
    func startPlayback(recording: Recording)
    func stopPlayback()
}

@MainActor
class DefaultPlaybackManager: PlaybackManager {
    
    // MARK: - API
    
    static let shared = DefaultPlaybackManager(
        playbackSession: AVAudioSession(),
        player: AVAudioPlayer()
    )
    
    func startPlayback(recording: Recording) {
        
        let url = DataPersistenceManager.createDocumentURL(withFileName: recording.name, fileType: .caf)
        do {
//            try playbackSession.overrideOutputAudioPort(.none)
            print(playbackSession.currentRoute.outputs)
//            player.channelAssignments
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("\(url)")
            print(error.localizedDescription)
        }
    }
    
    func stopPlayback() {
        player.stop()
    }
    
    // MARK: - Variables
    
    private var playbackSession: AVAudioSession
    private var player: AVAudioPlayer
    private var isRecording = false
    
    private var recordings: [Recording] = []
    
    // MARK: - Functions
    
    private init(
        playbackSession: AVAudioSession,
        player: AVAudioPlayer) {
            self.playbackSession = playbackSession
            self.player = player
            loadRecordingsFromDisk()
            setUpSession()
    }
    
    private func setUpSession() {
        do {
            playbackSession = AVAudioSession.sharedInstance()
            try playbackSession.setCategory(.multiRoute)
            try playbackSession.setSupportsMultichannelContent(true)
            try playbackSession.setActive(true)
            
        } catch {
            print(error.localizedDescription)
            print("Playback")
        }
    }

    private func loadRecordingsFromDisk() {
        do {
            recordings = try DataPersistenceManager.retrieve([Recording].self, from: "recordings")
        } catch {}
    }
}

class MockPlaybackManager: PlaybackManager {
    
    func startPlayback(recording: Recording) {}
    
    func stopPlayback() {}
    
}
