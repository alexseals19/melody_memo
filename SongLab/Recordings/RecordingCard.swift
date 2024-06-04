//
//  RecordingCard.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordingCard: View {
        
    @Binding var currentlyPlaying: Recording?
    
    var recording: Recording
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recording.name)
                Text(recording.date)
                    .font(.caption)
            }
            
            Spacer()
            
            Button {
                if let currentlyPlaying, currentlyPlaying == recording {
                    self.currentlyPlaying = nil
                } else {
                    currentlyPlaying = recording
                }
            } label: {
                if let currentlyPlaying, currentlyPlaying == recording {
                    Image(systemName: "pause")
                } else {
                    Image(systemName: "play")
                }
            }
            .foregroundColor(.black)
        }
    }
}

//#Preview {
//    let date = Date()
//    return RecordingCard(currentlyPlaying: .constant(UUID()),recording: Recording(name: "my recording 1", date: Date().formatted(date: .numeric, time: .omitted)))
//}
