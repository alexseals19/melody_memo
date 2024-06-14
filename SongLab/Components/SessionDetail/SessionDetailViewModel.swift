//
//  SessionDetailViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/13/24.
//

import Foundation

@MainActor
class SessionDetailViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var session: Session
            
    init(recordingManager: RecordingManager, session: Session) {
        self.session = session
        self.recordingManager = recordingManager
        recordingManager.sessions
            .compactMap { $0.first { $0.id == session.id }}
            .assign(to: &$session)
    }
    
    // MARK: - Variables
    
    private var recordingManager: RecordingManager
}
