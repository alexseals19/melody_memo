//
//  ContentView.swift
//  SongLab
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

struct HomeView: View {
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
    }
    
    private let audioManager: AudioManager
    
    var body: some View {
        VStack {
            RecordingsListView(audioManager: audioManager)
            Divider()
            Divider()
            TrackingToolbarView(audioManager: audioManager)
                .ignoresSafeArea()
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    HomeView(
        audioManager: DefaultAudioManager.shared
    )
}
