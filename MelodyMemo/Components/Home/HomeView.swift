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
                isRecording: $viewModel.isRecording,
                isSettingsPresented: $viewModel.isSettingsPresented,
                didFinishRecording: viewModel.didFinishRecording,
                inputSamples: viewModel.inputSamples
            )
            VStack(spacing: 0) {
                HStack {
                    appSettingsButton
                    MetronomeButtonView(
                        isMetronomeArmed: $viewModel.isMetronomeArmed,
                        metronomeBpm: viewModel.sessionBpm,
                        isRecording: viewModel.isRecording
                    )
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                
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
    var appSettingsButton: some View {
        Button {
            if !viewModel.isRecording {
                viewModel.isSettingsPresented.toggle()
            }
        } label: {
            AppButtonLabelView(name: "slider.horizontal.3", color: .primary, size: 22)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
        }
    }
}

#Preview {
    HomeView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager()
    )
}
