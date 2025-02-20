//
//  SessionFixtures.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Foundation

extension Session {
    
    static let groupFixture: SessionGroup = SessionGroup(
        label: .basic,
        tracks: [:],
        absoluteTrackCount: 1,
        id: UUID(),
        sessionId: UUID(),
        groupNumber: 1,
        isGroupExpanded: false,
        isGroupSoloActive: false,
        isLoopActive: false,
        leftIndicatorFraction: 0.0,
        rightIndicatorFraction: 0.0,
        loopReferenceTrack: trackFixture)
    
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
                                        soloOverride: false,
                                        darkWaveformImage: Data(),
                                        lightWaveformImage: Data()
    )
    
    static let sessionFixture: Session = Session(
                                            name: "SessionFixture",
                                            date: Date(),
                                            length: 4,
                                            groups: [:],
                                            absoluteGroupCount: 0,
                                            sessionBpm: 120,
                                            isUsingGlobalBpm: false,
                                            armedGroup: groupFixture,
                                            id: UUID()
                                        )
    
    static let sessionsFixture: [Session] = {
        var recs: [Session] = []
        let date = Date()
        for i in 0...50 {
            recs.append(
                Session(
                    name: "Session \(i)",
                    date: date,
                    length: 4,
                    groups: [:],
                    absoluteGroupCount: 0,
                    sessionBpm: 120,
                    isUsingGlobalBpm: false,
                    armedGroup: groupFixture,
                    id: UUID()
                )
            )
        }
        return recs
    }()
}

