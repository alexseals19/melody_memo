//
//  RecordingFixtures.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Foundation

extension Recording {
    
    static let recordingFixture: Self = Recording(
                                            name: "RecordingFixture",
                                            date: Date(),
                                            url: URL(fileURLWithPath: "url"),
                                            length: .seconds(4), 
                                            id: UUID())
    
    static let recordingsFixture: [Self] = {
        var recs: [Recording] = []
        let date = Date()
        for i in 0...50 {
            recs.append(Recording(name: "my recording \(i)", date: date, url: URL(fileURLWithPath: "url"), length: .seconds(4), id: UUID()))
        }
        return recs
    }()
}

