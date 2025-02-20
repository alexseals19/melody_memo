//
//  SessionsListView.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import SwiftUI

struct SessionsListView: View {
    
    // MARK: - API
        
    @Binding var selectedSession: Session?
    @Binding var isSettingsPresented: Bool
    @Binding var isRecording: Bool
    var didFinishRecording: Bool
    var inputSamples: [SampleModel]?
    
    @EnvironmentObject var appTheme: AppTheme
    
    init(
        audioManager: AudioManager,
        recordingManager: RecordingManager,
        selectedSession: Binding<Session?>,
        isRecording: Binding<Bool>,
        isSettingsPresented: Binding<Bool>,
        didFinishRecording: Bool,
        inputSamples: [SampleModel]?
    ) {
        _viewModel = StateObject(
            wrappedValue: SessionsListViewModel(
                audioManager: audioManager,
                recordingManager: recordingManager
            )
        )
        _selectedSession = selectedSession
        _isRecording = isRecording
        self.didFinishRecording = didFinishRecording
        _isSettingsPresented = isSettingsPresented
        self.inputSamples = inputSamples
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: SessionsListViewModel
    
    private var isScrollDisabled: Bool {
        false
    }
        
    // MARK: - Body
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                NavigationStack {
                    ScrollView() {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundStyle(Color(UIColor.secondarySystemBackground).opacity(0.3))
                            ForEach(viewModel.sessions) { session in
                                SessionCellView(
                                    currentlyPlaying: viewModel.currentlyPlaying,
                                    session: session,
                                    playerProgress: viewModel.playerProgress,
                                    nameChangeText: $viewModel.nameChangeText,
                                    isEditingSession: $viewModel.isEditingSession,
                                    playButtonAction: viewModel.sessionCellPlayButtonTapped,
                                    stopButtonAction: viewModel.sessionCellStopButtonTapped,
                                    trashButtonAction: viewModel.sessionCellTrashButtonTapped,
                                    sessionNameDidChange: viewModel.sessionNameDidChange
                                )
                                Rectangle()
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                    .foregroundStyle(.clear)
                                    .shadow(color: appTheme.accentColor ,radius: 5)
                            }
                            CellSpacerView(
                                screenHeight: proxy.size.height,
                                numberOfSessions: viewModel.sessions.count,
                                showMessage: true,
                                isUpdatingSessionModels: viewModel.isUpdatingSessionModels
                            )
                        }
                        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                        .animation(.spring, value: viewModel.sessions)
                        .navigationDestination(
                            for: Session.self,
                            destination: { session in
                                SessionDetailView(
                                    recordingManager: viewModel.recordingManager,
                                    audioManager: viewModel.audioManager,
                                    session: session,
                                    isRecording: isRecording
                                )
                                    .onAppear {
                                        selectedSession = session
                                    }
                                    .onDisappear {
                                        selectedSession = nil
                                    }
                            }
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.top, 1)
                }
            }
            VStack {
                if viewModel.errorMessage != nil {
                    ErrorMessageView(message: $viewModel.errorMessage)
                        .offset(y: 50)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    SessionsListView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager(),
        selectedSession: .constant(nil),
        isRecording: .constant(false),
        isSettingsPresented: .constant(false),
        didFinishRecording: false,
        inputSamples: nil
    )
}
