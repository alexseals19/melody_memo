//
//  Session.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import Foundation

struct Session: Identifiable, Equatable, Codable, Hashable {
    let name: String
    let date: Date
    var length: Duration
    var tracks: [Track]
    let id: UUID
    
    var lengthDisplayString: String {
        length.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
    
    var dateDisplayString: String {
        date.formatted(date: .numeric, time: .omitted)
    }
    
    init(name: String, date: Date, length: Duration, tracks: [Track], id: UUID) {
        self.name = name
        self.date = date
        self.length = length
        self.tracks = tracks
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
