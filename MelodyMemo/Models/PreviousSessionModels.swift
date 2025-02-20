//
//  PreviousSessionModels.swift
//  MelodyMemo
//
//  Created by Alex Seals on 11/20/24.
//

import Foundation
import SwiftUI
import Combine

struct SessionModelFour: Identifiable, Codable, Hashable, Equatable {
    
    let name: String
    let date: Date
    var length: Double
    var tracks: [UUID: Track]
    var absoluteTrackCount: Int
    var sessionBpm: Int
    var isUsingGlobalBpm: Bool
    let id: UUID
    
    var isGlobalSoloActive: Bool
    var isLoopActive: Bool
    var leftIndicatorFraction: Double
    var rightIndicatorFraction: Double
    
    var loopReferenceTrack: Track
    
    var lengthDisplayString: String {
        let lengthInSeconds = Int(length)
        let minutes: Int = lengthInSeconds / 60
        let seconds: Int = lengthInSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var dateDisplayString: String {
        date.formatted(date: .numeric, time: .omitted)
    }
    
    var rightIndicatorTime: Double {
        rightIndicatorFraction * loopReferenceTrack.length
    }
    
    var leftIndicatorTime: Double {
        leftIndicatorFraction * loopReferenceTrack.length
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
        isGlobalSoloActive: Bool,
        isLoopActive: Bool,
        leftIndicatorFraction: Double,
        rightIndicatorFraction: Double,
        loopReferenceTrack: Track
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
        self.isLoopActive = isLoopActive
        self.leftIndicatorFraction = leftIndicatorFraction
        self.rightIndicatorFraction = rightIndicatorFraction
        self.loopReferenceTrack = loopReferenceTrack
    }
}

struct SessionModelOne: Identifiable, Codable, Hashable, Equatable {
    
    let name: String
    let date: Date
    var length: Double
    var tracks: [UUID: TrackModelOne]
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
        tracks: [UUID: TrackModelOne],
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

struct SessionModelTwo: Identifiable, Codable, Hashable, Equatable {
    
    let name: String
    let date: Date
    var length: Double
    var tracks: [UUID: TrackModelOne]
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
        tracks: [UUID: TrackModelOne],
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

struct SessionModelThree: Identifiable, Codable, Hashable, Equatable {
    
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

