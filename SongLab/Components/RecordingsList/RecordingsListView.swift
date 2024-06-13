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

    init(audioManager: AudioManager, recordingManager: RecordingManager, selectedSession: Binding<Session?>) {
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
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if viewModel.sessions.isEmpty {
                Spacer()
                Text("Create your first recording!")
                Spacer()
            } else {
                NavigationStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            ForEach(viewModel.sessions) { session in
                                NavigationLink(value: session) {
                                    RecordingCell(
                                        currentlyPlaying: viewModel.currentlyPlaying,
                                        session: session,
                                        playButtonAction: viewModel.recordingCellPlayButtonTapped,
                                        stopButtonAction: viewModel.recordingCellStopButtonTapped,
                                        trashButtonAction: viewModel.recordingCellTrashButtonTapped
                                    )
                                }
                            }
                        }
                        .edgesIgnoringSafeArea(.bottom)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 100)
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
                    .clipped()
                    .opacity(0.8)
                    .background(
                        .thickMaterial.opacity(0.9)
                    )
                    .background(
                        Image("calathea_wallpaperpsd")
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .opacity(0.3)
                    )
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
