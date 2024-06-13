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
    let length: Duration
    var tracks: [Track]
    let id: UUID
    
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
