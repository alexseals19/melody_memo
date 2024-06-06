//
//  RecordingCard.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordingCell: View {
        
    @Binding var currentlyPlaying: Recording?
    
    var recording: String
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text(recording)
//                    Text(recording.date)
//                        .font(.caption)
                }
                
                Spacer()
                
                Button {
//                    if let currentlyPlaying, currentlyPlaying == recording {
//                        self.currentlyPlaying = nil
//                    } else {
//                        currentlyPlaying = recording
//                    }
                } label: {
//                    if let currentlyPlaying, currentlyPlaying == recording {
//                        Image(systemName: "pause")
//                    } else {
//                        Image(systemName: "play")
//                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    RecordingCell(
        currentlyPlaying: .constant(nil),
        recording: "Recording.recordingFixture"
    )
        .padding(.horizontal)
}
