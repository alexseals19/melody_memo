//
//  Track.swift
//  SongLab
//
//  Created by Alex Seals on 6/11/24.
//

import Foundation

struct Track: Identifiable, Equatable, Codable {
    let name: String
    let date: Date
    let length: Duration
    let id: UUID
    
    init(name: String, date: Date, length: Duration, id: UUID) {
        self.name = name
        self.date = date
        self.length = length
        self.id = id
    }
}
