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
    var isRecording: Bool
    
    @EnvironmentObject var appTheme: AppTheme
    
    init(
        audioManager: AudioManager,
        recordingManager: RecordingManager,
        selectedSession: Binding<Session?>,
        isRecording: Bool
    ) {
        _viewModel = StateObject(
            wrappedValue: SessionsListViewModel(
                audioManager: audioManager,
                recordingManager: recordingManager
            )
        )
        _selectedSession = selectedSession
        self.isRecording = isRecording
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: SessionsListViewModel
    
    private var isScrollDisabled: Bool {
        viewModel.sessions.isEmpty
    }
        
    // MARK: - Body
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                NavigationStack {
                    ZStack {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 3.0) {
                                ForEach(viewModel.sessions) { session in
                                    SessionCellView(
                                        currentlyPlaying: viewModel.currentlyPlaying,
                                        session: session,
                                        playerProgress: viewModel.playerProgress,
                                        playButtonAction: viewModel.sessionCellPlayButtonTapped,
                                        stopButtonAction: viewModel.sessionCellStopButtonTapped,
                                        trashButtonAction: viewModel.sessionCellTrashButtonTapped
                                    )
                                }
                                CellSpacerView(
                                    screenHeight: proxy.size.height,
                                    numberOfSessions: viewModel.sessions.count, 
                                    showMessage: true
                                )
                            }
                            .padding(.top, 78)
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
                        .scrollDisabled(isScrollDisabled)
                        .background(
                            Image("swirl")
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .blur(radius: 15)
                                .ignoresSafeArea()
                                .opacity(0.7)
                        )
                        .ignoresSafeArea()
                    }
                    
                }
            }
            VStack {
                if viewModel.errorMessage != nil {
                    ErrorMessageView(message: $viewModel.errorMessage)
                        .offset(y: 25)
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
        isRecording: false
    )
}
