//
//  RecordingFixtures.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Foundation

extension Session {
    
    static let recordingFixture: Session = Session(
                                            name: "RecordingFixture",
                                            date: Date(),
                                            length: 4,
                                            tracks: [:],
                                            absoluteTrackCount: 0,
                                            id: UUID(),
                                            isGlobalSoloActive: true)
    
    static let recordingsFixture: [Session] = {
        var recs: [Session] = []
        let date = Date()
        for i in 0...50 {
            recs.append(
                Session(
                    name: "Session \(i)",
                    date: date,
                    length: 4,
                    tracks: [:],
                    absoluteTrackCount: 0,
                    id: UUID(),
                    isGlobalSoloActive: false
                )
            )
        }
        return recs
    }()
}

