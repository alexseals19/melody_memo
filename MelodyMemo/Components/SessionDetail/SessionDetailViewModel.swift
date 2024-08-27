//
//  SessionDetailViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/13/24.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SessionDetailViewModel: ObservableObject {
    
    //MARK: - API
            
    @Published var currentlyPlaying: Session?
    @Published var session: Session
    @Published var trackTimer: Double = 0.0
    @Published var errorMessage: String?
    @Published var playbackPosition: Double = 0.0
    @Published var currentPlayheadPosition: Double = 0.0
    @Published var lastPlayheadPosition: Double = 0.0
    @Published var leftIndicatorDragOffset: CGFloat = 0.0
    @Published var rightIndicatorDragOffset: CGFloat = 0.0
    @Published var waveformWidth: Double = 130.0
    
    @Published var loopReferenceTrack: Track {
        didSet {
            session.loopReferenceTrack = loopReferenceTrack
            updateSession()
            if currentlyPlaying != nil {
                audioManager.updateCurrentlyPlaying(session)
            }
        }
    }
    
    @Published var isUsingGlobalBpm: Bool {
        didSet {
            session.isUsingGlobalBpm = isUsingGlobalBpm
            updateSession()
            if currentlyPlaying != nil {
                audioManager.updateCurrentlyPlaying(session)
            }
        }
    }
    
    @Published var sessionBpm: Int {
        didSet {
            session.sessionBpm = sessionBpm
            updateSession()
            if currentlyPlaying != nil {
                audioManager.updateCurrentlyPlaying(session)
            }
        }
    }
    
    var isSessionPlaying: Bool {
        if let currentlyPlaying, currentlyPlaying == session {
            return true
        } else {
            return false
        }
    }
            
    init(recordingManager: RecordingManager, audioManager: AudioManager, session: Session) {
        self.session = session
        self.recordingManager = recordingManager
        self.audioManager = audioManager
        self.isUsingGlobalBpm = session.isUsingGlobalBpm
        self.sessionBpm = session.sessionBpm
        self.loopReferenceTrack = session.loopReferenceTrack
        recordingManager.sessions
            .compactMap { $0.first { $0.id == session.id }}
            .assign(to: &$session)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
        audioManager.playerProgress
            .assign(to: &$trackTimer)
        audioManager.lastPlayheadPosition
            .assign(to: &$lastPlayheadPosition)
        trackVolumeSubject
            .debounce(for: 0.25, scheduler: RunLoop.main)
            .sink { track in
                self.session.tracks[track.id]?.volume = track.volume
                if self.currentlyPlaying != nil {
                    self.audioManager.updateCurrentlyPlaying(self.session)
                }
                self.updateSession()
                
            }
            .store(in: &cancellables)
        
        trackPanSubject
            .debounce(for: 0.25, scheduler: RunLoop.main)
            .sink { track in
                self.session.tracks[track.id]?.pan = track.pan
                if self.currentlyPlaying != nil {
                    self.audioManager.updateCurrentlyPlaying(self.session)
                }
                self.updateSession()
                
            }
            .store(in: &cancellables)
    }
    
    func masterCellRestartButtonTapped() {
        if currentlyPlaying != nil {
            do {
                try audioManager.stopPlayback(stopTimer: true)
            } catch {
                errorMessage = "ERROR: Could not stop playback for restart."
            }
            do {
                try audioManager.startPlayback(for: session, at: 0.0)
            } catch {
                errorMessage = "ERROR: Could not play session."
            }
        }
        playheadPositionDidChange(position: 0.0)
        setLastPlayheadPosition(position: 0.0)
    }
    
    func trackCellMuteButtonTapped(for track: Track) {
        session.tracks[track.id]?.isMuted.toggle()
        session.tracks[track.id]?.soloOverride = false
                
        if currentlyPlaying != nil, session.isGlobalSoloActive, track.isSolo {
            if !track.soloOverride {
                audioManager.toggleMute(for: Array(arrayLiteral: track))
            }
            audioManager.updateCurrentlyPlaying(session)
        } else if currentlyPlaying != nil, !session.isGlobalSoloActive {
            if !track.soloOverride {
                audioManager.toggleMute(for: Array(arrayLiteral: track))
            }
            audioManager.updateCurrentlyPlaying(session)
        } else if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(session)
        }
        updateSession()
        
    }
    
    func trackCellSoloButtonTapped(for track: Track) {
        if !session.isGlobalSoloActive {
            session.isGlobalSoloActive = true
            session.tracks[track.id]?.isSolo = true
            let otherTracks = session.tracks.filter { $0.key != track.id }
            for track in otherTracks.values {
                session.tracks[track.id]?.isSolo = false
            }
            if track.isMuted {
                session.tracks[track.id]?.soloOverride = true
            }
                        
            if currentlyPlaying != nil {
                var tracksToToggle = session.tracks.values.filter { $0.id != track.id && !$0.isMuted }
                if track.isMuted {
                    tracksToToggle.append(track)
                }
                audioManager.toggleMute(for: tracksToToggle)
                audioManager.updateCurrentlyPlaying(session)
            }
        } else {
            session.tracks[track.id]?.isSolo.toggle()
            let allSoloTracks = session.tracks.filter { $0.value.isSolo }
            if allSoloTracks.isEmpty {
                session.isGlobalSoloActive = false
                session.tracks[track.id]?.soloOverride = false
            } else if allSoloTracks.contains(where: { $0.key == track.id } ), track.isMuted {
                session.tracks[track.id]?.soloOverride = true
            } else {
                session.tracks[track.id]?.soloOverride = false
            }
                        
            if currentlyPlaying != nil {
                if allSoloTracks.isEmpty {
                    var tracksToToggle = session.tracks.values.filter { $0.id != track.id && !$0.isMuted}
                    if track.isMuted, track.soloOverride {
                        tracksToToggle.append(track)
                    }
                    audioManager.toggleMute(for: tracksToToggle)
                    audioManager.updateCurrentlyPlaying(session)
                } else {
                    let tracksToToggle = [track]
                    audioManager.toggleMute(for: tracksToToggle)
                    audioManager.updateCurrentlyPlaying(session)
                }
            }
        }
        updateSession()
    }
    
    func masterCellPlayButtonTapped(for session: Session) {
        if session.isLoopActive {
            playheadPositionDidChange(position: session.leftIndicatorTime)
        }
        do {
            try audioManager.startPlayback(for: session, at: session.isLoopActive ? session.leftIndicatorTime : 0.0)
        } catch {
            errorMessage = "ERROR: Could not play session."
        }
    }
    
    func masterCellSoloButtonTapped() {
        session.isGlobalSoloActive.toggle()
        for track in session.tracks.values {
            if track.soloOverride {
                session.tracks[track.id]?.soloOverride.toggle()
            } else if track.isMuted, track.isSolo, session.isGlobalSoloActive {
                session.tracks[track.id]?.soloOverride.toggle()
            }
        }
                
        if currentlyPlaying != nil {
            var tracksToToggle: [Track] = []
            tracksToToggle.append(contentsOf: session.tracks.values.filter( { $0.isSolo == false && $0.isMuted == false  } ))
            tracksToToggle.append(contentsOf: session.tracks.values.filter( { $0.isSolo == true && $0.isMuted == true } ))
            audioManager.toggleMute(for: tracksToToggle)
            audioManager.updateCurrentlyPlaying(session)
        }
        updateSession()
    }
    
    func masterCellStopButtonTapped() {
        setLastPlayheadPosition(position: 0.0)
        do {
            try audioManager.stopPlayback(stopTimer: true)
        } catch {
            errorMessage = "ERROR: Could not stop playback."
        }
    }
    
    func masterCellPauseButtonTapped() {
        audioManager.stopTimer(willReset: false)
        do {
            try audioManager.stopPlayback(stopTimer: false)
        } catch {
            errorMessage = "ERROR: Could not stop playback."
        }
    }
    
    func trackCellTrashButtonTapped(for track: Track) {
        
        if currentlyPlaying != nil {
            audioManager.removeTrack(track: track)
        }
        
        do {
            try recordingManager.removeTrack(session, track)
        } catch {
            errorMessage = "ERROR: Could not remove track."
        }
    }
    
    func sessionTrashButtonTapped() {
        playheadPositionDidChange(position: 0.0)
        setLastPlayheadPosition(position: 0.0)
        do {
            try recordingManager.removeSession(session)
        } catch {
            errorMessage = "ERROR: Could not remove session."
        }
    }
    
    func saveSession() {
        do {
            try recordingManager.saveSession(session)
        } catch {
            errorMessage = "ERROR: Could not save session."
        }
    }
    
    func trackVolumeDidChange(for track: Track, volume: Float) {
        var updatedTrack = track
        updatedTrack.volume = volume
        trackVolumeSubject.send(updatedTrack)
        if currentlyPlaying != nil, !track.isMuted, session.isGlobalSoloActive, track.isSolo {
            audioManager.setTrackVolume(for: updatedTrack)
        } else if currentlyPlaying != nil, session.isGlobalSoloActive, track.soloOverride {
            audioManager.setTrackVolume(for: updatedTrack)
        } else if currentlyPlaying != nil, !track.isMuted, !session.isGlobalSoloActive {
            audioManager.setTrackVolume(for: updatedTrack)
        }
        updateSession()
    }
    
    func trackPanDidChange(for track: Track, pan: Float) {
        var updatedTrack = track
        updatedTrack.pan = pan
        trackPanSubject.send(updatedTrack)
        if currentlyPlaying != nil, !track.isMuted, session.isGlobalSoloActive, track.isSolo {
            audioManager.setTrackPan(for: updatedTrack)
        } else if currentlyPlaying != nil, session.isGlobalSoloActive, track.soloOverride {
            audioManager.setTrackPan(for: updatedTrack)
        } else if currentlyPlaying != nil, !track.isMuted, !session.isGlobalSoloActive {
            audioManager.setTrackPan(for: updatedTrack)
        }
        updateSession()
    }
    
    func trackCellPlayPauseAction() {
        if isSessionPlaying {
            masterCellPauseButtonTapped()
        } else {
            masterCellPlayButtonTapped(for: session)
        }
    }
    
    func setSessionBpm(newBpm: Int) {
        session.sessionBpm = newBpm
    }
    
    func playheadPositionDidChange(position: Double) {
        audioManager.updatePlayheadPosition(position: position)
    }
    
    func setLastPlayheadPosition(position: Double) {
        audioManager.setLastPlayheadPosition(position)
    }
    
    func restartPlaybackFromPosition(position: Double) {
        do {
            try audioManager.restartPlayback(from: position)
        } catch {
            errorMessage = "ERROR: Could not stop playback for restart."
        }
    }
    
    func stopTimer() {
        audioManager.stopTimer(willReset: false)
    }
    
    func leftIndicatorPositionDidChange(position: Double) {

        session.leftIndicatorFraction = position
        updateSession()
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(session)
            do {
                try audioManager.loopIndicatorChangedPosition()
            } catch {}
        }
        leftIndicatorDragOffset = 0.0
    }
    
    func rightIndicatorPositionDidChange(position: Double) {
                
        session.rightIndicatorFraction = position
        updateSession()
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(session)
            do {
                try audioManager.loopIndicatorChangedPosition()
            } catch {}
        }
        rightIndicatorDragOffset = 0.0
    }
    
    func toggleIsLoopActive() {
        session.isLoopActive.toggle()
        updateSession()
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(session)
        }
    }
    
    func getExpandedWaveform(track: Track, colorScheme: ColorScheme) -> Image {
        var uiImage: UIImage
        do {
            uiImage = try audioManager.getImage(for: track.fileName, colorScheme: colorScheme)
        } catch {
            return Image(systemName: "waveform")
        }
        
        return Image(uiImage: uiImage)
    }
    
    // MARK: - Variables
    
    private var trackVolumeSubject = PassthroughSubject<Track, Never>()
    private var trackPanSubject = PassthroughSubject<Track, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var recordingManager: RecordingManager
    private let audioManager: AudioManager
    
    // MARK: - Functions

    private func updateSession() {
        do {
            try recordingManager.updateSession(session)
        } catch {
            errorMessage = "ERROR: Could not save session."
        }
    }
}
