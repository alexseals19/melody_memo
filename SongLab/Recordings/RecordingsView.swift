//
//  RecordingsView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct Recording: Identifiable, Equatable {
    let name: String
    let date: String
    let id = UUID()
    
    static let mockRecordings: [Recording] = {
        var recs: [Recording] = []
        let date = Date()
        for i in 0...50 {
            recs.insert(Recording(name: "my recording \(i)", date: date.formatted(date: .numeric, time: .omitted)), at: 0)
        }
        return recs
    }()
}

struct RecordingsView: View {
    
    @State var currentlyPlaying: Recording?
    
    @State var recordings: [Recording] = {
        var recs: [Recording] = []
        let date = Date()
        for i in 0...50 {
            recs.insert(Recording(name: "my recording \(i)", date: date.formatted(date: .numeric, time: .omitted)), at: 0)
        }
        return recs
    }()
    
    var body: some View {
        
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(recordings) { recording in
                    Divider()
                    RecordingCell(currentlyPlaying: $currentlyPlaying, recording: recording)
                        .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    RecordingsView()
}
