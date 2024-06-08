//
//  ContentView.swift
//  SongLab
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

struct HomeView: View {
    
    init(recordingManager: RecordingManager, playbackManager: PlaybackManager) {
        self.recordingManager = recordingManager
        self.playbackManager = playbackManager
    }
    
    private let recordingManager: RecordingManager
    private let playbackManager: PlaybackManager
    
    var body: some View {
        VStack {
            RecordingsListView(recordingManager: recordingManager, playbackManager: playbackManager)
            Divider()
            Divider()
            TrackingToolbarView(recordingManager: recordingManager)
                .ignoresSafeArea()
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    HomeView(
        recordingManager: DefaultRecordingManager.shared,
        playbackManager: DefaultPlaybackManager.shared
    )
}
