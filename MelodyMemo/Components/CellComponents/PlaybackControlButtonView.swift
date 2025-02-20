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
    
    init(
         group: SessionGroup,
         currentlyPlaying: SessionGroup?,
         playButtonTapped: @escaping (_: SessionGroup) -> Void,
         pauseButtonTapped: @escaping () -> Void
    ) {
        self.group = group
        self.currentlyPlaying = currentlyPlaying
        self.playButtonTapped = playButtonTapped
        self.pauseButtonTapped = pauseButtonTapped
    }
    
    //MARK: - Variables
    
    private var group: SessionGroup
    private var currentlyPlaying: SessionGroup?
    
    private let playButtonTapped: (_ group: SessionGroup) -> Void
    private let pauseButtonTapped: () -> Void
    
    //MARK: - Body
    
    var body: some View {
        Button {
            if let currentlyPlaying, currentlyPlaying == group {
                pauseButtonTapped()
            } else {
                playButtonTapped(group)
            }
        } label: {
            ZStack {
                if let currentlyPlaying, currentlyPlaying == group {
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
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    PlaybackControlButtonView(
        group: Session.groupFixture,
        currentlyPlaying: nil,
        playButtonTapped: { _ in },
        pauseButtonTapped: {}
    )
}
