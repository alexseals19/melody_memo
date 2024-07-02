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
                HomeViewNavBarView()
                
                Spacer()
                TrackingToolbarView(
                    audioManager: viewModel.audioManager,
                    isRecording: $viewModel.isRecording,
                    isSettingsPresented: $viewModel.isSettingsPresented,
                    inputSamples: viewModel.inputSamples,
                    trackTimer: viewModel.trackTimer
                )
            }
        }
        .sheet(isPresented: $viewModel.isSettingsPresented) {
            AppSettingsView(metronome: viewModel.metronome)
        }
    }
}

#Preview {
    HomeView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager()
    )
}
