//
//  SessionDetailViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/13/24.
//

import Foundation
import Combine

@MainActor
class SessionDetailViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var currentlyPlaying: Session?
    @Published var session: Session
    
    let audioManager: AudioManager
            
    init(recordingManager: RecordingManager, audioManager: AudioManager, session: Session) {
        self.session = session
        self.recordingManager = recordingManager
        self.audioManager = audioManager
        recordingManager.sessions
            .compactMap { $0.first { $0.id == session.id }}
            .assign(to: &$session)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
    }
        
    func masterCellSoloButtonTapped() {
        session.isGlobalSoloActive.toggle()
        if session.isGlobalSoloActive {
            let tracksToMute = session.tracks.values.filter( { $0.isSolo == false } )
            audioManager.toggleMute(for: tracksToMute)
        } else {
            let tracksToUnmute = session.tracks.values.filter( { $0.isSolo == false } )
            audioManager.toggleMute(for: tracksToUnmute)
        }
        if currentlyPlaying != nil {
            currentlyPlaying = session
        }
    }
    
    func trackCellPlayButtonTapped(for session: Session) {
        do {
            try audioManager.startPlayback(for: session)
        } catch {
            //TODO
        }
    }
    
    func trackCellMuteButtonTapped(for track: Track) {
        session.tracks[track.id]?.isMuted.toggle()
        if currentlyPlaying != nil {
            if !session.isGlobalSoloActive {
                audioManager.toggleMute(for: Array(arrayLiteral: track))
            }
            currentlyPlaying = session
        }
        
    }
    
    func trackCellSoloButtonTapped(for track: Track) {
        if !session.isGlobalSoloActive {
            for track in session.tracks.values {
                session.tracks[track.id]?.isSolo = false
            }
        }
        session.tracks[track.id]?.isSolo.toggle()
        
        guard let isSolo = session.tracks[track.id]?.isSolo else {
            assertionFailure("Unable to locate track with id: \(track.id).")
            return
        }
                
        if isSolo {
            if track.isMuted {
                trackCellMuteButtonTapped(for: track)
            }
            session.isGlobalSoloActive = true
        } else {
            let otherSoloTracks = session.tracks.filter { $0.key != track.id && $0.value.isSolo }
            if otherSoloTracks.isEmpty {
                session.isGlobalSoloActive = false
            }
        }
        
        if currentlyPlaying != nil {
            let tracksToMute = session.tracks.values.filter( { $0.isSolo == false } )
            audioManager.toggleMute(for: tracksToMute)
            currentlyPlaying = session
        }
    }
    
    func trackCellStopButtonTapped() {
        audioManager.stopPlayback()
    }
    
    func trackCellTrashButtonTapped(for session: Session) {
        do {
            try recordingManager.removeSession(session)
        } catch {
            // TODO: Handle Error
        }
    }
    
    func saveSession() {
        do {
            try recordingManager.saveSession(session)
        } catch {
            //TODO
        }
    }
    
    func setTrackVolume(for track: Track, volume: Double) {
        session.tracks[track.id]?.volume = Float(volume)
        if let trackToAdjust = session.tracks[track.id], currentlyPlaying != nil {
            audioManager.setTrackVolume(for: trackToAdjust)
            currentlyPlaying = session
        }
        
    }
    
    // MARK: - Variables
    
    private var recordingManager: RecordingManager
    
    // MARK: - Functions
}
