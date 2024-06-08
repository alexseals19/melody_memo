//
//  Recordings.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import Foundation

struct Recording: Identifiable, Equatable, Codable {
    let name: String
    let date: Date
    let url: URL
    let length: Duration
    let id: UUID
    
    init(name: String, date: Date, url: URL, length: Duration, id: UUID) {
        self.name = name
        self.date = date
        self.url = url
        self.length = length
        self.id = id
    }
}

