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
    func removeTrack(_ track: Track) throws
    func saveRecording(_ recording: Session) throws
}

final class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager()
    
    var sessions: CurrentValueSubject<[Session], Never>
    
    func removeSession(_ session: Session) throws {
        Task { @MainActor in
            var updatedRecordings = sessions.value
            updatedRecordings.removeAll { $0.id == session.id }
            try DataPersistenceManager.delete(session.name, fileType: .caf)
            try DataPersistenceManager.save(updatedRecordings, to: "sessions")
            sessions.send(updatedRecordings)
        }
    }
    
    func removeTrack(_ track: Track) throws {
        Task { @MainActor in
            var updatedRecordings = sessions.value
            updatedRecordings.removeAll { $0.id == track.id }
            try DataPersistenceManager.delete(track.name, fileType: .caf)
            try DataPersistenceManager.save(updatedRecordings, to: "sessions")
            sessions.send(updatedRecordings)
        }
    }
    
    func saveRecording(_ recording: Session) throws {
        Task { @MainActor in
            var updatedRecordings = sessions.value
            updatedRecordings.append(recording)
            try DataPersistenceManager.save(updatedRecordings, to: "sessions")
            sessions.send(updatedRecordings)
        }
    }
    
    // MARK: - Functions
    
    private init() {
        do {
            sessions = CurrentValueSubject(try DataPersistenceManager.retrieve([Session].self, from: "sessions"))
        } catch {
            sessions = CurrentValueSubject([])
        }
    }
}
