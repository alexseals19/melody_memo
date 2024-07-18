//
//  RecordingManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

protocol RecordingManager {
    var sessions: CurrentValueSubject<[Session], Never> { get }
    func removeSession(_ recording: Session) throws
    func removeTrack(_ session: Session, _ track: Track) throws
    func saveSession(_ recording: Session) throws
    func updateSession(_ session: Session) throws
}

final class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager()
    
    var sessions: CurrentValueSubject<[Session], Never>
    
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
        do {
            sessions = CurrentValueSubject(try DataPersistenceManager.retrieve([Session].self, from: "sessions"))
            sessions.send(sessions.value.sorted { (lhs: Session, rhs: Session) -> Bool in
                return lhs.date > rhs.date
            }
            )
            
            absoluteSessionCount = try DataPersistenceManager.retrieve(Int.self, from: "session_count")
            
        } catch {
            sessions = CurrentValueSubject([])
            absoluteSessionCount = 0
        }
    }
    
    // MARK: - Variables
    
    
        
}