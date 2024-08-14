//
//  PlaybackControlButtonView.swift
//  SongLab
//
//  Created by Alex Seals on 6/20/24.
//

import SwiftUI

struct PlaybackControlButtonView: View {
    
    //MARK: - API
    
    @EnvironmentObject var appTheme: AppTheme
    
    init(session: Session, 
         currentlyPlaying: Session?,
         playButtonAction: @escaping (_: Session) -> Void,
         pauseButtonAction: @escaping () -> Void
    ) {
        self.session = session
        self.currentlyPlaying = currentlyPlaying
        self.playButtonAction = playButtonAction
        self.pauseButtonAction = pauseButtonAction
    }
    
    //MARK: - Variables
    
    private var session: Session
    private var currentlyPlaying: Session?
    
    private let playButtonAction: (_ session: Session) -> Void
    private let pauseButtonAction: () -> Void
    
    //MARK: - Body
    
    var body: some View {
        Button {
            if let currentlyPlaying, currentlyPlaying == session {
                pauseButtonAction()
            } else {
                playButtonAction(session)
            }
        } label: {
            Group {
                if let currentlyPlaying, currentlyPlaying == session {
                    Image(systemName: "pause")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 24, height: 24)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 20))
            
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    PlaybackControlButtonView(
        session: Session.sessionFixture,
        currentlyPlaying: nil,
        playButtonAction: { _ in },
        pauseButtonAction: {}
    )
}
