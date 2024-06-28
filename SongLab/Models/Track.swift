//
//  Track.swift
//  SongLab
//
//  Created by Alex Seals on 6/11/24.
//

import Foundation
import SwiftUI

struct Track: Identifiable, Codable, Hashable, Equatable {
    let name: String
    let fileName: String
    let date: Date
    let length: Double
    let waveformDark: Data
    let waveformLight: Data
    let id: UUID
    
    var volume: Float
    var isMuted: Bool
    var isSolo: Bool
    
    var lengthDisplayString: String {
        let lengthInSeconds = Int(length)
        let minutes: Int = lengthInSeconds / 60
        let seconds: Int = lengthInSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(
        name: String,
        fileName: String,
        date: Date,
        length: Double,
        waveformDark: Data,
        waveformLight: Data,
        id: UUID,
        volume: Float,
        isMuted: Bool,
        isSolo: Bool
    ) {
        self.name = name
        self.fileName = fileName
        self.date = date
        self.length = length
        self.waveformDark = waveformDark
        self.waveformLight = waveformLight
        self.id = id
        self.volume = volume
        self.isMuted = isMuted
        self.isSolo = isSolo
    }
}


