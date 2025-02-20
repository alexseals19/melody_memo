//
//  SessionGroup.swift
//  MelodyMemo
//
//  Created by Alex Seals on 11/20/24.
//

import Foundation

struct SessionGroup: Identifiable, Codable, Hashable, Equatable {
    
    var label: GroupLabel
    var tracks: [UUID: Track]
    var absoluteTrackCount: Int
    let id: UUID
    var groupNumber: Int
    var isGroupExpanded: Bool
    let sessionId: UUID
    
    var isGroupSoloActive: Bool
    var isLoopActive: Bool
    var leftIndicatorFraction: Double
    var rightIndicatorFraction: Double
    var loopReferenceTrack: Track?
    
    var lastPlayheadPosition: Double = 0.0
    
    var rightIndicatorTime: Double {
        if let loopReferenceTrack {
            return rightIndicatorFraction * loopReferenceTrack.length
        }
        return 0.0
    }
    
    var leftIndicatorTime: Double {
        if let loopReferenceTrack {
            return leftIndicatorFraction * loopReferenceTrack.length
        }
        return 0.0
    }
    
    var sortedTracks: [Track] {
        tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
            lhs.date < rhs.date
        }
    }
    
    var displayLabel: String {
        switch label {
        case .basic:
            return "Group \(groupNumber)"
        default:
            return label.rawValue
        }
    }
    
    init(
        label: GroupLabel,
        tracks: [UUID : Track],
        absoluteTrackCount: Int,
        id: UUID,
        sessionId: UUID,
        groupNumber: Int,
        isGroupExpanded: Bool,
        isGroupSoloActive: Bool,
        isLoopActive: Bool,
        leftIndicatorFraction: Double,
        rightIndicatorFraction: Double,
        loopReferenceTrack: Track?
    ) {
        self.label = label
        self.tracks = tracks
        self.absoluteTrackCount = absoluteTrackCount
        self.id = id
        self.sessionId = sessionId
        self.groupNumber = groupNumber
        self.isGroupExpanded = isGroupExpanded
        self.isGroupSoloActive = isGroupSoloActive
        self.isLoopActive = isLoopActive
        self.leftIndicatorFraction = leftIndicatorFraction
        self.rightIndicatorFraction = rightIndicatorFraction
        self.loopReferenceTrack = loopReferenceTrack
    }
    
}

enum GroupLabel: String, Codable, CaseIterable, Identifiable {
    case verse = "Verse"
    case chorus = "Chorus"
    case preChorus = "Pre Chorus"
    case bridge = "Bridge"
    case basic = "Group"
    
    var id: Self { self }
}
