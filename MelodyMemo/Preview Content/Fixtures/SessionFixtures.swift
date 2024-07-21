//
//  SessionFixtures.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Foundation

extension Session {
    
    static let trackFixture: Track = Track(
                                        name: "TrackFixture",
                                        fileName: "",
                                        date: Date(),
                                        length: 4,
                                        id: UUID(),
                                        volume: 1.0,
                                        pan: 0.0,
                                        isMuted: false,
                                        isSolo: false,
                                        soloOverride: false)
    
    static let sessionFixture: Session = Session(
                                            name: "SessionFixture",
                                            date: Date(),
                                            length: 4,
                                            tracks: [:],
                                            absoluteTrackCount: 0,
                                            sessionBpm: 120,
                                            isUsingGlobalBpm: false,
                                            id: UUID(),
                                            isGlobalSoloActive: true)
    
    static let sessionsFixture: [Session] = {
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
                    sessionBpm: 120,
                    isUsingGlobalBpm: false,
                    id: UUID(),
                    isGlobalSoloActive: false
                )
            )
        }
        return recs
    }()
}

