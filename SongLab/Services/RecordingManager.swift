//
//  RecordingManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

protocol RecordingManager {
    var recordings: CurrentValueSubject<[Recording], Never> { get }
    func removeRecording(_ recording: Recording) throws
    func saveRecording(_ recording: Recording) throws
}

final class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager()
    
    var recordings: CurrentValueSubject<[Recording], Never>
    
    func removeRecording(_ recording: Recording) throws {
        var updatedRecordings = recordings.value
        updatedRecordings.removeAll { $0.id == recording.id }
        try DataPersistenceManager.delete(recording.name, fileType: .caf)
        try DataPersistenceManager.save(updatedRecordings, to: "recordings")
        recordings.send(updatedRecordings)
    }
    
    func saveRecording(_ recording: Recording) throws {
        var updatedRecordings = recordings.value
        updatedRecordings.append(recording)
        try DataPersistenceManager.save(updatedRecordings, to: "recordings")
        recordings.send(updatedRecordings)
    }
    
    // MARK: - Functions
    
    private init() {
        do {
            recordings = CurrentValueSubject(try DataPersistenceManager.retrieve([Recording].self, from: "recordings"))
        } catch {
            recordings = CurrentValueSubject([])
        }
    }
}
