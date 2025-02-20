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
            
    @Published var session: Session
    @Published var trackTimer: Double = 0.0
    @Published var errorMessage: String?
    @Published var playbackPosition: Double = 0.0
    @Published var currentPlayheadPosition: Double = 0.0
    @Published var leftIndicatorDragOffset: CGFloat = 0.0
    @Published var rightIndicatorDragOffset: CGFloat = 0.0
    @Published var waveformWidth: Double = 130.0
    @Published var inputSamples: [SampleModel]?
    @Published var isAdjustingGroupIndicators: SessionGroup?
    @Published var isGroupPlaybackPaused: SessionGroup?
    @Published var loopReferenceTrack: Track = Session.trackFixture
    @Published var currentlyPlaying: SessionGroup?
    @Published var isAdjustingGroupPlayhead: SessionGroup?
    
    @Published var isUsingGlobalBpm: Bool {
        didSet {
            session.isUsingGlobalBpm = isUsingGlobalBpm
            updateSession()
        }
    }
    
    @Published var armedGroup: SessionGroup {
        didSet {
            session.armedGroup = armedGroup
            updateSession()
        }
    }
    
    @Published var sessionBpm: Int {
        didSet {
            session.sessionBpm = sessionBpm
            updateSession()
        }
    }
    
    var sortedGroups: [SessionGroup] {
        session.groups.values.sorted { (lhs: SessionGroup, rhs: SessionGroup) -> Bool in
            return lhs.groupNumber > rhs.groupNumber
        }
    }
        
    func saveSession() {
        do {
            try recordingManager.saveSession(session)
        } catch {
            errorMessage = "ERROR: Could not save session."
        }
    }
    
    func updateSession() {
        do {
            try recordingManager.updateSession(session)
        } catch {
            errorMessage = "ERROR: Could not save session."
        }
    }
    
    func addGroup() {
        do {
            try recordingManager.addGroup(for: session)
        } catch {
            errorMessage = "ERROR: Could not add group."
        }
    }
    
    func deleteGroupAction(_ group: SessionGroup) {
        do {
            try recordingManager.deleteGroup(group)
        } catch {
            errorMessage = "ERROR: Could not remove group."
        }
    }
    
    func updateGroup(_ groupToUpdate: SessionGroup) {
        session.groups[groupToUpdate.id] = groupToUpdate
        if session.armedGroup.id == groupToUpdate.id {
            session.armedGroup = groupToUpdate
        }
        if let currentlyPlaying, currentlyPlaying.id == groupToUpdate.id {
            audioManager.updateCurrentlyPlaying(groupToUpdate)
        }
        updateSession()
    }
    
    func playheadPositionDidChange(position: Double) {
        audioManager.updatePlayheadPosition(position: position)
    }
    
    func setLastPlayheadPosition(position: Double, group: SessionGroup?) {
        guard let group else {
            return
        }
        var updatedGroup = group
        updatedGroup.lastPlayheadPosition = position
        updateGroup(updatedGroup)
    }
    
    func leftIndicatorPositionDidChange(position: Double, group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.leftIndicatorFraction = position
        updateGroup(updatedGroup)
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(updatedGroup)
            do {
                try audioManager.loopIndicatorChangedPosition()
            } catch {}
        }
        leftIndicatorDragOffset = 0.0
    }
    
    func rightIndicatorPositionDidChange(position: Double, group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.rightIndicatorFraction = position
        updateGroup(updatedGroup)
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(updatedGroup)
            do {
                try audioManager.loopIndicatorChangedPosition()
            } catch {}
        }
        rightIndicatorDragOffset = 0.0
    }
    
    func playButtonTapped(group: SessionGroup) {
        
        if let isGroupPlaybackPaused, isGroupPlaybackPaused != group {
            stopButtonTapped(group: isGroupPlaybackPaused)
        }
        
        if let currentlyPlaying, currentlyPlaying != group {
            stopButtonTapped(group: currentlyPlaying)
        }
        
        isGroupPlaybackPaused = nil
        
        if group.isLoopActive {
            playheadPositionDidChange(position: group.leftIndicatorTime)
        }
        do {
            try audioManager.startPlayback(
                for: group,
                at: group.isLoopActive ? group.leftIndicatorTime : 0.0
            )
        } catch {
            errorMessage = "ERROR: Could not play group."
        }
    }
    
    func soloButtonTapped(group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.isGroupSoloActive.toggle()
        for track in updatedGroup.tracks.values {
            if track.soloOverride {
                updatedGroup.tracks[track.id]?.soloOverride.toggle()
            } else if track.isMuted, track.isSolo, updatedGroup.isGroupSoloActive {
                updatedGroup.tracks[track.id]?.soloOverride.toggle()
            }
        }
                
        if currentlyPlaying != nil {
            var tracksToToggle: [Track] = []
            tracksToToggle.append(
                contentsOf: updatedGroup.tracks.values.filter( { $0.isSolo == false && $0.isMuted == false  } )
            )
            tracksToToggle.append(
                contentsOf: updatedGroup.tracks.values.filter( { $0.isSolo == true && $0.isMuted == true } )
            )
            audioManager.toggleMute(for: tracksToToggle)
            audioManager.updateCurrentlyPlaying(updatedGroup)
        }
        updateGroup(updatedGroup)
    }
    
    func stopButtonTapped(group: SessionGroup) {
        isGroupPlaybackPaused = nil
        if currentlyPlaying == nil {
            setLastPlayheadPosition(position: 0.0, group: group)
        }
        do {
            try audioManager.stopPlayback(stopTimer: true)
        } catch {
            errorMessage = "ERROR: Could not stop playback."
        }
    }
    
    func pauseButtonTapped() {
        if let currentlyPlaying {
            setLastPlayheadPosition(position: trackTimer, group: currentlyPlaying)
        }
        
        isGroupPlaybackPaused = currentlyPlaying
        
        audioManager.stopTimer(willReset: false)
        do {
            try audioManager.stopPlayback(stopTimer: false)
        } catch {
            errorMessage = "ERROR: Could not stop playback."
        }
    }
    
    func stopTimer() {
        audioManager.stopTimer(willReset: false)
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
    
    // Group
    
    func isPlayheadOutOfPosition(group: SessionGroup) -> Bool {
        if currentlyPlaying == nil, group.lastPlayheadPosition != 0.0 {
            return true
        } else {
            return false
        }
    }
    
    func loopReferenceTrackDidChange(track: Track, group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.loopReferenceTrack = track
        updateGroup(updatedGroup)
    }
    
    func toggleIsLoopActive(group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.isLoopActive.toggle()
        updateGroup(updatedGroup)
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(updatedGroup)
        }
    }
    
    func toggleIsGroupExpanded(group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.isGroupExpanded.toggle()
        updateGroup(updatedGroup)
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(updatedGroup)
        }
    }
    
    func groupLabelDidChange(label: GroupLabel, group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.label = label
        updateGroup(updatedGroup)
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(updatedGroup)
        }
    }
    
    //Track
    
    func trackCellPlayPauseAction(group: SessionGroup) {
        if isGroupPlaybackPaused == group {
            playButtonTapped(group: group)
        } else {
            pauseButtonTapped()
        }
    }
    
    func restartPlaybackFromPosition(position: Double) {
        do {
            try audioManager.restartPlayback(from: position)
        } catch {
            errorMessage = "ERROR: Could not stop playback for restart."
        }
    }
    
    func trackCellMuteButtonTapped(for track: Track, group: SessionGroup) {
        
        var updatedGroup = group
        
        updatedGroup.tracks[track.id]?.isMuted.toggle()
        updatedGroup.tracks[track.id]?.soloOverride = false
                
        if currentlyPlaying == group, group.isGroupSoloActive, track.isSolo {
            if !track.soloOverride {
                audioManager.toggleMute(for: Array(arrayLiteral: track))
            }
            audioManager.updateCurrentlyPlaying(updatedGroup)
        } else if currentlyPlaying == group, !group.isGroupSoloActive {
            if !track.soloOverride {
                audioManager.toggleMute(for: Array(arrayLiteral: track))
            }
            audioManager.updateCurrentlyPlaying(updatedGroup)
        } else if currentlyPlaying == group {
            audioManager.updateCurrentlyPlaying(updatedGroup)
        }
        updateGroup(updatedGroup)
        
    }
    
    func trackCellSoloButtonTapped(for track: Track, group: SessionGroup) {
        
        var updatedGroup = group
        
        if !updatedGroup.isGroupSoloActive {
            updatedGroup.isGroupSoloActive = true
            updatedGroup.tracks[track.id]?.isSolo = true
            let otherTracks = updatedGroup.tracks.filter { $0.key != track.id }
            for track in otherTracks.values {
                updatedGroup.tracks[track.id]?.isSolo = false
            }
            if track.isMuted {
                updatedGroup.tracks[track.id]?.soloOverride = true
            }
                        
            if currentlyPlaying == group {
                var tracksToToggle = updatedGroup.tracks.values.filter { $0.id != track.id && !$0.isMuted }
                if track.isMuted {
                    tracksToToggle.append(track)
                }
                audioManager.toggleMute(for: tracksToToggle)
                audioManager.updateCurrentlyPlaying(updatedGroup)
            }
        } else {
            updatedGroup.tracks[track.id]?.isSolo.toggle()
            let allSoloTracks = updatedGroup.tracks.filter { $0.value.isSolo }
            if allSoloTracks.isEmpty {
                updatedGroup.isGroupSoloActive = false
                updatedGroup.tracks[track.id]?.soloOverride = false
            } else if allSoloTracks.contains(where: { $0.key == track.id } ), track.isMuted {
                updatedGroup.tracks[track.id]?.soloOverride = true
            } else {
                updatedGroup.tracks[track.id]?.soloOverride = false
            }
                        
            if currentlyPlaying == group {
                if allSoloTracks.isEmpty {
                    var tracksToToggle = updatedGroup.tracks.values.filter { $0.id != track.id && !$0.isMuted}
                    if track.isMuted, track.soloOverride {
                        tracksToToggle.append(track)
                    }
                    audioManager.toggleMute(for: tracksToToggle)
                    audioManager.updateCurrentlyPlaying(updatedGroup)
                } else {
                    let tracksToToggle = [track]
                    audioManager.toggleMute(for: tracksToToggle)
                    audioManager.updateCurrentlyPlaying(updatedGroup)
                }
            }
        }
        updateGroup(updatedGroup)
    }
    
    func trackCellTrashButtonTapped(for track: Track, group: SessionGroup) {
        
        if currentlyPlaying == group {
            audioManager.removeTrack(track: track)
        }
        
        do {
            try recordingManager.removeTrack(session, group, track)
        } catch {
            errorMessage = "ERROR: Could not remove track."
        }
    }
    
    func trackVolumeDidChange(for track: Track, group: SessionGroup, volume: Float) {
        var updatedTrack = track
        updatedTrack.volume = volume
        trackVolumeSubject.send((updatedTrack, group))
        if currentlyPlaying != nil, !track.isMuted, group.isGroupSoloActive, track.isSolo {
            audioManager.setTrackVolume(for: updatedTrack)
        } else if currentlyPlaying != nil, group.isGroupSoloActive, track.soloOverride {
            audioManager.setTrackVolume(for: updatedTrack)
        } else if currentlyPlaying != nil, !track.isMuted, !group.isGroupSoloActive {
            audioManager.setTrackVolume(for: updatedTrack)
        }
    }
    
    func trackPanDidChange(for track: Track, group: SessionGroup, pan: Float) {
        var updatedTrack = track
        updatedTrack.pan = pan
        trackPanSubject.send((updatedTrack, group))
        if currentlyPlaying != nil, !track.isMuted, group.isGroupSoloActive, track.isSolo {
            audioManager.setTrackPan(for: updatedTrack)
        } else if currentlyPlaying != nil, group.isGroupSoloActive, track.soloOverride {
            audioManager.setTrackPan(for: updatedTrack)
        } else if currentlyPlaying != nil, !track.isMuted, !group.isGroupSoloActive {
            audioManager.setTrackPan(for: updatedTrack)
        }
    }
            
    init(recordingManager: RecordingManager, audioManager: AudioManager, session: Session) {
        self.session = session
        self.recordingManager = recordingManager
        self.audioManager = audioManager
        self.sessionBpm = session.sessionBpm
        self.armedGroup = session.armedGroup
        self.isUsingGlobalBpm = session.isUsingGlobalBpm
        
        self.trackTimer = 0.0
        self.inputSamples = []
        self.currentlyPlaying = nil
        self.isRecording = false
                
        audioManager.playerProgress
            .assign(to: &$trackTimer)
       
        audioManager.inputSamples
            .assign(to: &$inputSamples)
        recordingManager.sessions
            .compactMap { $0.first { $0.id == session.id }}
            .assign(to: &$session)
        audioManager.currentlyPlaying
            .assign(to: &$currentlyPlaying)
        audioManager.isRecording
            .assign(to: &$isRecording)
        
        trackPanSubject
            .debounce(for: 0.25, scheduler: RunLoop.main)
            .sink { [weak self] track, group in
                self?.updateTrack(for: track, group)
            }
            .store(in: &cancellables)
        
        trackVolumeSubject
            .debounce(for: 0.25, scheduler: RunLoop.main)
            .sink { [weak self] track, group in
                self?.updateTrack(for: track, group)
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Variables
    
    @Published private var isRecording: Bool = false
    private var trackVolumeSubject = PassthroughSubject<(Track, SessionGroup), Never>()
    private var trackPanSubject = PassthroughSubject<(Track, SessionGroup), Never>()
    private var cancellables = Set<AnyCancellable>()
    let recordingManager: RecordingManager
    let audioManager: AudioManager

    // MARK: - Functions

    private func updateTrack(for track: Track, _ group: SessionGroup) {
        var updatedGroup = group
        updatedGroup.tracks[track.id] = track
        if currentlyPlaying != nil {
            audioManager.updateCurrentlyPlaying(updatedGroup)
        }
        updateGroup(updatedGroup)
    }
    
}
