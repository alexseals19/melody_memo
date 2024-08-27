//
//  RecordingManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation
import SwiftUI

protocol RecordingManager {
    var sessions: CurrentValueSubject<[Session], Never> { get }
    var isUpdatingSessionModels: CurrentValueSubject<Bool?, Never> { get }
    func removeSession(_ recording: Session) throws
    func removeTrack(_ session: Session, _ track: Track) throws
    func saveSession(_ recording: Session) throws
    func updateSession(_ session: Session) throws
}

final class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager()
    
    var sessions: CurrentValueSubject<[Session], Never>
    var isUpdatingSessionModels: CurrentValueSubject<Bool?, Never>
    
    var absoluteSessionCount: Int
    
    func removeSession(_ session: Session) throws {
        Task { @MainActor in
            var updatedSessions = sessions.value
            updatedSessions.removeAll { $0.id == session.id }
            if updatedSessions.isEmpty {
                zeroAbsoluteSessionCount()
            }
            for track in session.tracks.values {
                try DataPersistenceManager.delete(track.fileName, fileType: .m4a)
            }
            try DataPersistenceManager.save(updatedSessions, to: "sessions")
            sessions.send(updatedSessions)
        }
    }
    
    func removeTrack(_ session: Session, _ track: Track) throws {
        Task { @MainActor in
            
            var updatedSession = session
            updatedSession.tracks.removeValue(forKey: track.id)
            
            if !updatedSession.tracks.isEmpty {
                guard let longestTrack = updatedSession.tracks.values.sorted(by: { (lhs: Track, rhs: Track) -> Bool in
                    return lhs.date > rhs.date
                }).last else {
                    return
                }
                
                updatedSession.length = longestTrack.length
            } else {
                updatedSession.absoluteTrackCount = 0
            }
            
            var updatedSessions = sessions.value
            updatedSessions.removeAll { $0.id == session.id }
            updatedSessions.append(updatedSession)
            
            try DataPersistenceManager.delete(track.fileName, fileType: .m4a)
            
            try DataPersistenceManager.save(updatedSessions, to: "sessions")
            sessions.send(updatedSessions)
            if DefaultAudioManager.shared.currentlyPlaying.value != nil {
                DefaultAudioManager.shared.currentlyPlaying.send(updatedSession)
            }
        }
    }
    
    func saveSession(_ session: Session) throws {
        Task { @MainActor in
            var updatedSessions = sessions.value
            updatedSessions.removeAll { $0.id == session.id }
            updatedSessions.append(session)
            try DataPersistenceManager.save(updatedSessions, to: "sessions")
            sessions.send(
                updatedSessions.sorted { (lhs: Session, rhs: Session) -> Bool in
                    return lhs.date > rhs.date
                }
            )
        }
    }
    
    func updateSession(_ session: Session) throws {
        Task { @MainActor in
            var updatedSessions = sessions.value
            updatedSessions.removeAll { $0.id == session.id }
            updatedSessions.append(session)
            sessions.send(
                updatedSessions.sorted { (lhs: Session, rhs: Session) -> Bool in
                    return lhs.date > rhs.date
                }
            )
        }
    }
    
    func saveTrack(_ session: Session) throws {
        Task { @MainActor in
            let updatedSessions = sessions.value
            try DataPersistenceManager.save(updatedSessions, to: "sessions")
            sessions.send(updatedSessions)
        }
    }
    
    func incrementAbsoluteSessionCount() {
        absoluteSessionCount += 1
        do {
            try DataPersistenceManager.save(absoluteSessionCount, to: "session_count")
        } catch {
            assertionFailure("Could not set absoluteSessionCount.")
        }
    }
    
    func zeroAbsoluteSessionCount() {
        absoluteSessionCount = 0
        do {
            try DataPersistenceManager.save(absoluteSessionCount, to: "session_count")
        } catch {
            assertionFailure("Could not set absoluteSessionCount.")
        }
    }
    
    // MARK: - Functions
    
    private init() {
        isUpdatingSessionModels = CurrentValueSubject(nil)
        do {
            absoluteSessionCount = try DataPersistenceManager.retrieve(Int.self, from: "session_count")
        } catch {
            absoluteSessionCount = 0
        }
        
        do {
            sessions = CurrentValueSubject(try DataPersistenceManager.retrieve([Session].self, from: "sessions"))
            sessions.send(sessions.value.sorted { (lhs: Session, rhs: Session) -> Bool in
                return lhs.date > rhs.date
            }
            )
        } catch {
            sessions = CurrentValueSubject([])
            Task {
                isUpdatingSessionModels.send(true)
                await updateSessionModel()
            }
        }
    }
    
    // MARK: - Variables
    
    // MARK: - Functions
    
    @MainActor
    private func updateSessionModel() {
        
        enum SessionModel {
            case none
            case one
            case two
            case three
        }
        
        var updateFromSessionModel: SessionModel = .none
        
        var modelOneSessions: [SessionModelOne] = []
        var modelTwoSessions: [SessionModelTwo] = []
        var modelThreeSessions: [SessionModelThree] = []
        var newSessions: [Session] = []
        
        do {
            modelThreeSessions = try DataPersistenceManager.retrieve([SessionModelThree].self, from: "sessions")
            updateFromSessionModel = .three
        } catch {
            print("No sessions to update for model three.")
            do {
                modelTwoSessions = try DataPersistenceManager.retrieve([SessionModelTwo].self, from: "sessions")
                updateFromSessionModel = .two
            } catch {
                print("No sessions to update for model two.")
                do {
                    modelOneSessions = try DataPersistenceManager.retrieve([SessionModelOne].self, from: "sessions")
                    updateFromSessionModel = .one
                } catch {
                    print("No sessions to update for model one.")
                }
            }
        }
        
        switch updateFromSessionModel {
        case .one:
            for session in modelOneSessions {
                var newTracks: [UUID: Track] = [:]
                for track in session.tracks.values {
                    do {
                        guard let lightImage = try DefaultAudioManager.shared.getImage(for: track.fileName, colorScheme: .light).pngData() else {
                            assertionFailure("Could not get png data for light image.")
                            return
                        }
                        guard let darkImage = try DefaultAudioManager.shared.getImage(for: track.fileName, colorScheme: .dark).pngData() else {
                            assertionFailure("Could not get png data for dark image.")
                            return
                        }
                        
                        newTracks[track.id] = Track(
                            name: track.name,
                            fileName: track.fileName,
                            date: track.date,
                            length: track.length,
                            id: track.id,
                            volume: track.volume,
                            pan: track.pan,
                            isMuted: track.isMuted,
                            isSolo: track.isSolo,
                            soloOverride: track.soloOverride,
                            darkWaveformImage: lightImage,
                            lightWaveformImage: darkImage)
                    } catch {
                        print("Cannot get images.")
                    }
                }
                let sortedTracks = Array(newTracks.values).sorted { (lhs: Track, rhs: Track) -> Bool in
                    return rhs.name > lhs.name
                }
                newSessions.append(Session(
                        name: session.name,
                        date: session.date,
                        length: session.length,
                        tracks: newTracks,
                        absoluteTrackCount: session.absoluteTrackCount,
                        sessionBpm: 0,
                        isUsingGlobalBpm: false,
                        id: session.id,
                        isGlobalSoloActive: session.isGlobalSoloActive,
                        isLoopActive: false,
                        leftIndicatorFraction: 0.0,
                        rightIndicatorFraction: 1.0,
                        loopReferenceTrack: sortedTracks[0]
                    )
                )
            }
            
        case .two:
            for session in modelTwoSessions {
                var newTracks: [UUID: Track] = [:]
                for track in session.tracks.values {
                    do {
                        guard let lightImage = try DefaultAudioManager.shared.getImage(for: track.fileName, colorScheme: .light).pngData() else {
                            assertionFailure("Could not get png data for light image.")
                            return
                        }
                        guard let darkImage = try DefaultAudioManager.shared.getImage(for: track.fileName, colorScheme: .dark).pngData() else {
                            assertionFailure("Could not get png data for dark image.")
                            return
                        }
                        
                        newTracks[track.id] = Track(
                            name: track.name,
                            fileName: track.fileName,
                            date: track.date,
                            length: track.length,
                            id: track.id,
                            volume: track.volume,
                            pan: track.pan,
                            isMuted: track.isMuted,
                            isSolo: track.isSolo,
                            soloOverride: track.soloOverride,
                            darkWaveformImage: lightImage,
                            lightWaveformImage: darkImage)
                    } catch {
                        print("Cannot get images.")
                    }
                }
                
                let sortedTracks = Array(newTracks.values).sorted { (lhs: Track, rhs: Track) -> Bool in
                    return rhs.name > lhs.name
                }
                
                newSessions.append(Session(
                        name: session.name,
                        date: session.date,
                        length: session.length,
                        tracks: newTracks,
                        absoluteTrackCount: session.absoluteTrackCount,
                        sessionBpm: session.sessionBpm,
                        isUsingGlobalBpm: session.isUsingGlobalBpm,
                        id: session.id,
                        isGlobalSoloActive: session.isGlobalSoloActive,
                        isLoopActive: false,
                        leftIndicatorFraction: 0.0,
                        rightIndicatorFraction: 1.0,
                        loopReferenceTrack: sortedTracks[0]
                    )
                )
            }
            
        case .three:
            for session in modelThreeSessions {
                
                var newTracks: [UUID: Track] = [:]
                for track in session.tracks.values {
                    do {
                        guard let lightImage = try DefaultAudioManager.shared.getImage(for: track.fileName, colorScheme: .light).pngData() else {
                            assertionFailure("Could not get png data for light image.")
                            return
                        }
                        guard let darkImage = try DefaultAudioManager.shared.getImage(for: track.fileName, colorScheme: .dark).pngData() else {
                            assertionFailure("Could not get png data for dark image.")
                            return
                        }
                        
                        newTracks[track.id] = Track(
                            name: track.name,
                            fileName: track.fileName,
                            date: track.date,
                            length: track.length,
                            id: track.id,
                            volume: track.volume,
                            pan: track.pan,
                            isMuted: track.isMuted,
                            isSolo: track.isSolo,
                            soloOverride: track.soloOverride,
                            darkWaveformImage: lightImage,
                            lightWaveformImage: darkImage)
                    } catch {
                        print("Cannot get images.")
                    }
                }
                
                let sortedTracks = Array(session.tracks.values).sorted { (lhs: Track, rhs: Track) -> Bool in
                    return rhs.name > lhs.name
                }
                newSessions.append(Session(
                        name: session.name,
                        date: session.date,
                        length: session.length,
                        tracks: newTracks,
                        absoluteTrackCount: session.absoluteTrackCount,
                        sessionBpm: session.sessionBpm,
                        isUsingGlobalBpm: session.isUsingGlobalBpm,
                        id: session.id,
                        isGlobalSoloActive: session.isGlobalSoloActive,
                        isLoopActive: false,
                        leftIndicatorFraction: 0.0,
                        rightIndicatorFraction: 1.0,
                        loopReferenceTrack: sortedTracks[0]
                    )
                )
            }
            
        case .none:
            print("No sessions to update. Returning.")
            isUpdatingSessionModels.send(nil)
            return
        }
        
        do {
            try DataPersistenceManager.save(newSessions, to: "sessions")
        } catch {
            print("Session model could not be updated.")
        }
        
        sessions.send(
            newSessions.sorted { (lhs: Session, rhs: Session) -> Bool in
                return lhs.date > rhs.date
            }
        )
        
        isUpdatingSessionModels.send(nil)
    }
}
