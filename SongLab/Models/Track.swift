//
//  Track.swift
//  SongLab
//
//  Created by Alex Seals on 6/11/24.
//

import Foundation

struct Track: Identifiable, Codable, Hashable, Equatable {
    let name: String
    let fileName: String
    let date: Date
    let length: Duration
    let id: UUID
    
    var volume: Float
    var isMuted: Bool
    var isSolo: Bool
    
    var lengthDisplayString: String {
        length.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
    
    init(
        name: String,
        fileName: String,
        date: Date,
        length: Duration,
        id: UUID,
        volume: Float,
        isMuted: Bool,
        isSolo: Bool
    ) {
        self.name = name
        self.fileName = fileName
        self.date = date
        self.length = length
        self.id = id
        self.volume = volume
        self.isMuted = isMuted
        self.isSolo = isSolo
    }
}


