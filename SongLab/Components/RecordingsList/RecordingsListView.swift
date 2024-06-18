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
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(viewModel.sessions) { session in
                                RecordingCell(
                                    currentlyPlaying: viewModel.currentlyPlaying,
                                    session: session,
                                    playButtonAction: viewModel.recordingCellPlayButtonTapped,
                                    stopButtonAction: viewModel.recordingCellStopButtonTapped,
                                    trashButtonAction: viewModel.recordingCellTrashButtonTapped
                                )
                            }
                            CellSpacer(screenHeight: proxy.size.height, numberOfSessions: viewModel.sessions.count)
                        }
                        .animation(.spring, value: viewModel.sessions)
                        .padding(.top, 74)
                        .navigationDestination(
                            for: Session.self,
                            destination: { session in
                                SessionDetailView(recordingManager: viewModel.recordingManager, session: session)
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
                    .background(.ultraThinMaterial.opacity(appTheme.theme.backgroundLayerOpacity))
                    .background(backgroundImage)
                    .ignoresSafeArea()
                }
            }
        }
        .animation(.spring, value: viewModel.sessions)
    }
    
    var backgroundImage: some View {
        Color.black
            .opacity(appTheme.theme.backgroundLayerOpacity)
            .background(
                appTheme.theme.backgroundImage
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .opacity(appTheme.theme.backgroundImageOpacity)
            )
    }
}

#Preview {
    RecordingsListView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager(),
        selectedSession: .constant(nil)
    )
}
