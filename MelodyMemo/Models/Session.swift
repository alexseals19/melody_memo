//
//  Session.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import Foundation
import SwiftUI
import Combine

struct Session: Identifiable, Codable, Hashable, Equatable {
    
    var name: String
    let date: Date
    var length: Double
    var groups: [UUID: SessionGroup]
    var absoluteGroupCount: Int
    var sessionBpm: Int
    var isUsingGlobalBpm: Bool
    var armedGroup: SessionGroup
    
    let id: UUID
    
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
        groups: [UUID: SessionGroup],
        absoluteGroupCount: Int,
        sessionBpm: Int,
        isUsingGlobalBpm: Bool,
        armedGroup: SessionGroup,
        id: UUID
    ) {
        self.name = name
        self.date = date
        self.length = length
        self.groups = groups
        self.absoluteGroupCount = absoluteGroupCount
        self.sessionBpm = sessionBpm
        self.isUsingGlobalBpm = isUsingGlobalBpm
        self.armedGroup = armedGroup
        self.id = id
    }
}

struct SessionModelFive: Identifiable, Codable, Hashable, Equatable {
    
    let name: String
    let date: Date
    var length: Double
    var groups: [UUID: SessionGroup]
    var absoluteGroupCount: Int
    var sessionBpm: Int
    var isUsingGlobalBpm: Bool
    var armedGroup: SessionGroup
    
    let id: UUID
    
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
        groups: [UUID: SessionGroup],
        absoluteGroupCount: Int,
        sessionBpm: Int,
        isUsingGlobalBpm: Bool,
        armedGroup: SessionGroup,
        id: UUID
    ) {
        self.name = name
        self.date = date
        self.length = length
        self.groups = groups
        self.absoluteGroupCount = absoluteGroupCount
        self.sessionBpm = sessionBpm
        self.isUsingGlobalBpm = isUsingGlobalBpm
        self.armedGroup = armedGroup
        self.id = id
    }
}

