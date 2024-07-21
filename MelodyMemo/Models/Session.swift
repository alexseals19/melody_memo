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
    var length: Double
    var tracks: [UUID: Track]
    var absoluteTrackCount: Int
    var sessionBpm: Int
    var isUsingGlobalBpm: Bool
    let id: UUID
    
    var isGlobalSoloActive: Bool
    
    var lengthDisplayString: String {
        let lengthInSeconds = Int(length)
        let minutes: Int = lengthInSeconds / 60
        let seconds: Int = lengthInSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var dateDisplayString: String {
        date.formatted(date: .numeric, time: .omitted)
    }
    
    init(
        name: String,
        date: Date,
        length: Double,
        tracks: [UUID: Track],
        absoluteTrackCount: Int,
        sessionBpm: Int,
        isUsingGlobalBpm: Bool,
        id: UUID,
        isGlobalSoloActive: Bool
    ) {
        self.name = name
        self.date = date
        self.length = length
        self.tracks = tracks
        self.absoluteTrackCount = absoluteTrackCount
        self.sessionBpm = sessionBpm
        self.isUsingGlobalBpm = isUsingGlobalBpm
        self.id = id
        self.isGlobalSoloActive = isGlobalSoloActive
    }
}

struct SessionModelOne: Identifiable, Codable, Hashable, Equatable {
    
    let name: String
    let date: Date
    var length: Double
    var tracks: [UUID: Track]
    var absoluteTrackCount: Int
    let id: UUID
    
    var isGlobalSoloActive: Bool
    
    var lengthDisplayString: String {
        let lengthInSeconds = Int(length)
        let minutes: Int = lengthInSeconds / 60
        let seconds: Int = lengthInSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var dateDisplayString: String {
        date.formatted(date: .numeric, time: .omitted)
    }
    
    init(
        name: String,
        date: Date,
        length: Double,
        tracks: [UUID: Track],
        absoluteTrackCount: Int,
        id: UUID,
        isGlobalSoloActive: Bool
    ) {
        self.name = name
        self.date = date
        self.length = length
        self.tracks = tracks
        self.absoluteTrackCount = absoluteTrackCount
        self.id = id
        self.isGlobalSoloActive = isGlobalSoloActive
    }
}
