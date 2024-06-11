//
//  ContentView.swift
//  SongLab
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: API
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            RecordingsListView(audioManager: audioManager, recordingManager: recordingManager)
            Divider()
            Divider()
            TrackingToolbarView(audioManager: audioManager)
                .ignoresSafeArea()
                .padding(.top)
        }
        .padding()
    }
    
    private let audioManager: AudioManager
    private let recordingManager: RecordingManager
}

#Preview {
    HomeView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager()
    )
}
