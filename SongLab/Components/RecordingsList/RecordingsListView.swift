//
//  RecordingsListView.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import SwiftUI

struct RecordingsListView: View {
    
    // MARK: - API
        
    @Binding var selectedSession: Session?
    
    @EnvironmentObject var appTheme: AppTheme

    init(
        audioManager: AudioManager,
        recordingManager: RecordingManager,
        selectedSession: Binding<Session?>
    ) {
        _viewModel = StateObject(
            wrappedValue: RecordingsListViewModel(
                audioManager: audioManager,
                recordingManager: recordingManager
            )
        )
        _selectedSession = selectedSession
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: RecordingsListViewModel
    
    private var isScrollDisabled: Bool {
        viewModel.sessions.isEmpty
    }
        
    // MARK: - Body
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ZStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0.0) {
                            ForEach(viewModel.sessions) { session in
                                VStack(spacing: 0.0) {
                                    Rectangle()
                                        .frame(maxWidth: .infinity, maxHeight: 1.0)
                                        .foregroundStyle(appTheme.cellDividerColor)
                                    RecordingCell(
                                        currentlyPlaying: viewModel.currentlyPlaying,
                                        session: session,
                                        playerProgress: viewModel.playerProgress,
                                        playButtonAction: viewModel.recordingCellPlayButtonTapped,
                                        stopButtonAction: viewModel.recordingCellStopButtonTapped,
                                        trashButtonAction: viewModel.recordingCellTrashButtonTapped
                                    )
                                }
                            }
                            CellSpacer(screenHeight: proxy.size.height, numberOfSessions: viewModel.sessions.count)
                        }
                        .animation(.spring, value: viewModel.sessions)
                        .offset(y: 75.0)
                        .navigationDestination(
                            for: Session.self,
                            destination: { session in
                                SessionDetailView(
                                    recordingManager: viewModel.recordingManager,
                                    audioManager: viewModel.audioManager,
                                    session: session
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
                    .background(appTheme.backgroundImage)
                    .ignoresSafeArea()
                }
            }
        }
    }
}

#Preview {
    RecordingsListView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager(),
        selectedSession: .constant(nil)
    )
}
