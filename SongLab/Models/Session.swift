//
//  Session.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import Foundation

struct Session: Identifiable, Codable, Hashable, Equatable {
    
    let name: String
    let date: Date
    var length: Duration
    var tracks: [UUID: Track]
    let id: UUID
    
    var isGlobalSoloActive: Bool
    
    var lengthDisplayString: String {
        length.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
    
    var dateDisplayString: String {
        date.formatted(date: .numeric, time: .omitted)
    }
    
    init(
        name: String,
        date: Date,
        length: Duration,
        tracks: [UUID: Track],
        id: UUID,
        isGlobalSoloActive: Bool
    ) {
        self.name = name
        self.date = date
        self.length = length
        self.tracks = tracks
        self.id = id
        self.isGlobalSoloActive = isGlobalSoloActive
    }
}
