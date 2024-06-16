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
    @Binding var appTheme: String

    init(
        audioManager: AudioManager,
        recordingManager: RecordingManager,
        selectedSession: Binding<Session?>,
        appTheme: Binding<String>
    ) {
        _viewModel = StateObject(
            wrappedValue: RecordingsListViewModel(
                audioManager: audioManager,
                recordingManager: recordingManager
            )
        )
        _selectedSession = selectedSession
        _appTheme = appTheme
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: RecordingsListViewModel
    
    private var isScrollDisabled: Bool {
        viewModel.sessions.isEmpty
    }
        
    private var backgroundOpacity: Double {
        switch appTheme {
        case "glass":
            return 0.0
        case "superglass":
            return 0.0
        case "opaque":
            return 0.7
        case "light":
            return 0.0
        default:
            return 0.7
        }
    }
    
    private var materialOpacity: Double {
        switch appTheme {
        case "glass":
            return 0.0
        case "superglass":
            return 0.0
        case "opaque":
            return 0.8
        case "light":
            return 0.0
        default:
            return 0.5
        }
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
                                    appTheme: $appTheme,
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
                    .background(.ultraThinMaterial.opacity(materialOpacity))
                    .background(backgroundImage)
                    .ignoresSafeArea()
                }
            }
        }
        .animation(.spring, value: viewModel.sessions)
    }
    
    var backgroundImage: some View {
        Color.black
            .opacity(backgroundOpacity)
            .background(
                Image("calathea_wallpaperpsd")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .opacity(0.75)
            )
    }
}

#Preview {
    RecordingsListView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager(),
        selectedSession: .constant(nil),
        appTheme: .constant("glass")
    )
}
