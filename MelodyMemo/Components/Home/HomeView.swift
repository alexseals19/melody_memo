//
//  HomeView.swift
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
            SessionsListView(
                audioManager: viewModel.audioManager,
                recordingManager: viewModel.recordingManager,
                selectedSession: $viewModel.selectedSession,
                isRecording: viewModel.isRecording
            )
            VStack {
                HomeViewNavBarView()
                if viewModel.errorMessage != nil {
                    ErrorMessageView(message: $viewModel.errorMessage)
                }
                Spacer()
                TrackingToolbarView(
                    isRecording: $viewModel.isRecording,
                    isSettingsPresented: $viewModel.isSettingsPresented,
                    inputSamples: viewModel.inputSamples,
                    trackTimer: viewModel.trackTimer,
                    isMetronomeArmed: $viewModel.isMetronomeArmed,
                    metronomeBpm: viewModel.sessionBpm
                )
            }
        }
        .sheet(isPresented: $viewModel.isSettingsPresented) {
            AppSettingsView(
                metronome: viewModel.metronome,
                audioManager: viewModel.audioManager,
                metronomeVolume: $viewModel.metronomeVolume,
                isCountInActive: $viewModel.isCountInActive
            )
            .onDisappear {
                viewModel.saveSettings()
                viewModel.resetTapIn()
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
