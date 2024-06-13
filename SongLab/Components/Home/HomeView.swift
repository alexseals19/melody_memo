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
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                audioManager: audioManager,
                recordingManager: recordingManager
            )
        )
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: HomeViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            RecordingsListView(
                audioManager: viewModel.audioManager,
                recordingManager: viewModel.recordingManager,
                selectedSession: $viewModel.selectedSession
            )
            VStack {
                Spacer()
                TrackingToolbarView(
                    audioManager: viewModel.audioManager,
                    isRecording: $viewModel.isRecording
                )
                .ignoresSafeArea()
                .background(
                    .ultraThinMaterial
                )
                .background(Color.black.opacity(0.4))
            }
        }
    }
}

#Preview {
    HomeView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager()
    )
}
