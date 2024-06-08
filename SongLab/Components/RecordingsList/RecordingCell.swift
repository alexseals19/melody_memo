//
//  RecordingCard.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordingCell: View {
        
    // MARK: - API
    
    @Binding var currentlyPlaying: Recording?
    @Binding var removeRecording: Recording?
    
    // MARK: - Variables
        
    var recording: Recording
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    HStack() {
                        Text(recording.name + " |")
                        Text(recording.length.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2))))
                            .font(.caption)
                    }
                    Text(recording.date.formatted(date: .numeric, time: .omitted))
                        .font(.caption)
                }
                
                Spacer()
                
                Button {
                    removeRecording = recording
                } label: {
                    Image(systemName: "trash")
                }
                
                Button {
                    if let currentlyPlaying, currentlyPlaying == recording {
                        self.currentlyPlaying = nil
                    } else {
                        currentlyPlaying = recording
                    }
                } label: {
                    if let currentlyPlaying, currentlyPlaying == recording {
                        Image(systemName: "pause")
                            .resizable()
                            .frame(width: 12, height: 16)
                            .padding(.trailing, 25)
                    } else {
                        Image(systemName: "play")
                            .resizable()
                            .frame(width: 16, height: 20)
                            .padding(.trailing, 25)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    
    RecordingCell(
        currentlyPlaying: .constant(nil),
        removeRecording: .constant(nil),
        recording: Recording(
            name: "RecordingFixture",
            date: Date(),
            length: .seconds(4),
            id: UUID()
            
        )
    )
        .padding(.horizontal)
}
