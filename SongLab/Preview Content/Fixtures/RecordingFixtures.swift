//
//  RecordingFixtures.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Foundation

extension Session {
    
    static let recordingFixture: Self = Session(
                                            name: "RecordingFixture",
                                            date: Date(),
                                            length: .seconds(4),
                                            tracks: [],
                                            id: UUID())
    
    static let recordingsFixture: [Self] = {
        var recs: [Session] = []
        let date = Date()
        for i in 0...50 {
            recs.append(Session(name: "Session \(i)", date: date, length: .seconds(4), tracks: [], id: UUID()))
        }
        return recs
    }()
}

