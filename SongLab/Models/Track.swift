//
//  Track.swift
//  SongLab
//
//  Created by Alex Seals on 6/11/24.
//

import Foundation

struct Track: Identifiable, Equatable, Codable {
    let name: String
    let fileName: String
    let date: Date
    let length: Duration
    let id: UUID
    
    init(name: String, fileName: String, date: Date, length: Duration, id: UUID) {
        self.name = name
        self.fileName = fileName
        self.date = date
        self.length = length
        self.id = id
    }
}
