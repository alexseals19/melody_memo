//
//  RecordingCard.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordingCell: View {
        
    // MARK: - API
    
    @Binding var currentlyPlaying: Session?
    var audioIsPlaying: Bool
    
    init(
        currentlyPlaying: Binding<Session?>,
        audioIsPlaying: Bool,
        session: Session,
        trashButtonAction: @escaping (_: Session) -> Void
    ) {
        _currentlyPlaying = currentlyPlaying
        self.audioIsPlaying = audioIsPlaying
        self.session = session
        self.trashButtonAction = trashButtonAction
    }
    
    // MARK: - Variables
        
    var session: Session
        
    let trashButtonAction: (_ session: Session) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    HStack() {
                        Text(session.name + " |")
                        Text(session.length.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2))))
                            .font(.caption)
                    }
                    Text(session.date.formatted(date: .numeric, time: .omitted))
                        .font(.caption)
                }
                
                Spacer()
                
                Button {
                    trashButtonAction(session)
                } label: {
                    Image(systemName: "trash")
                }
                
                Button {
                    if audioIsPlaying, let currentlyPlaying, currentlyPlaying == session {
                        self.currentlyPlaying = nil
                    } else {
                        currentlyPlaying = session
                    }
                } label: {
                    if audioIsPlaying, let currentlyPlaying, currentlyPlaying == session {
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
        audioIsPlaying: false,
        session: Session(
            name: "RecordingFixture",
            date: Date(),
            length: .seconds(4),
            tracks: [],
            id: UUID()
        ),
        trashButtonAction: { _ in }
    )
        .padding(.horizontal)
}
