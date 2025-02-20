//
//  MockRecordingManager.swift
//  SongLab
//
//  Created by Shawn Seals on 6/11/24.
//

import Combine
import Foundation

class MockRecordingManager: RecordingManager {
    var sessions: CurrentValueSubject<[Session], Never>
    var isUpdatingSessionModels: CurrentValueSubject<Bool?, Never>
    func removeSession(_ session: Session) throws {}
    func removeTrack(_ session: Session, _ group: SessionGroup, _ track: Track) throws {}
    func saveSession(_ recording: Session) throws {}
    func updateSession(_ session: Session) throws {}
    func addGroup(for session: Session) throws {}
    func deleteGroup(_ group: SessionGroup) throws {}

    init() {
        sessions = CurrentValueSubject(Session.sessionsFixture)
        isUpdatingSessionModels = CurrentValueSubject(nil)
    }
}
