//
//  SessionDetailView.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI

struct SessionDetailView: View {
    
    //MARK: - API
    
    init(
        recordingManager: RecordingManager,
        audioManager: AudioManager,
        session: Session,
        isRecording: Bool
    ) {
        _viewModel = StateObject(
            wrappedValue: SessionDetailViewModel(
                recordingManager: recordingManager,
                audioManager: audioManager,
                session: session
            )
        )
        self.isRecording = isRecording
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
        
    @Environment(\.dismiss) var dismiss

    @State private var opacity: Double = 0.0
    @StateObject private var viewModel: SessionDetailViewModel
    
    private var isRecording: Bool
    
    private var tracks: [Track] {
        viewModel.session.tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
            return lhs.date > rhs.date
        }
    }
    
    //MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 3.0) {
                HStack {
                    backButton
                    Capsule()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .foregroundStyle(appTheme.accentColor)
                    Text(viewModel.session.name)
                        .font(.largeTitle)
                        .frame(width: 200)
                    Capsule()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .foregroundStyle(appTheme.accentColor)
                    Button {
                        viewModel.sessionTrashButtonTapped()
                        dismiss()
                    } label: {
                        AppButtonLabelView(name: "trash", color: .secondary)
                    }
                    .padding(15)
                }
                .background(Color(UIColor.systemBackground).opacity(0.3))
                .padding(.top, 78)
                
                MasterCellView(
                    session: viewModel.session,
                    currentlyPlaying: viewModel.currentlyPlaying,
                    useGlobalBpm: $viewModel.isUsingGlobalBpm,
                    sessionBpm: $viewModel.sessionBpm,
                    playButtonAction: viewModel.masterCellPlayButtonTapped,
                    pauseButtonAction: viewModel.masterCellPauseButtonTapped,
                    stopButtonAction: viewModel.masterCellStopButtonTapped,
                    globalSoloButtonAction: viewModel.masterCellSoloButtonTapped,
                    restartButtonAction: viewModel.masterCellRestartButtonTapped,
                    setBpmButtonAction: viewModel.setSessionBpm
                )
                GeometryReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 3.0) {
                            ForEach(tracks) { track in
                                TrackCellView(
                                    track: track,
                                    isGlobalSoloActive: viewModel.session.isGlobalSoloActive,
                                    isSessionPlaying: viewModel.isSessionPlaying,
                                    trackTimer: viewModel.trackTimer,
                                    lastPlayheadPosition: viewModel.lastPlayheadPosition,
                                    muteButtonAction: viewModel.trackCellMuteButtonTapped,
                                    soloButtonAction: viewModel.trackCellSoloButtonTapped,
                                    trackVolumeDidChange: viewModel.trackVolumeDidChange,
                                    trackPanDidChange: viewModel.trackPanDidChange,
                                    playheadPositionDidChange: viewModel.playheadPositionDidChange,
                                    setLastPlayheadPosition: viewModel.setLastPlayheadPosition,
                                    restartPlaybackFromPosition: viewModel.restartPlaybackFromPosition,
                                    trackCellPlayPauseAction: viewModel.trackCellPlayPauseAction,
                                    stopTimer: viewModel.stopTimer,
                                    trashButtonAction: viewModel.trackCellTrashButtonTapped
                                )
                            }
                            CellSpacerView(
                                screenHeight: proxy.size.height,
                                numberOfSessions: viewModel.session.tracks.count,
                                showMessage: false
                            )
                        }
                        .animation(.spring, value: viewModel.session.tracks)
                    }
                }
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .background(
                Image("swirl")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 15)
                    .ignoresSafeArea()
                    .opacity(0.7)
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.opacity = 1.0
                }
            }
            .ignoresSafeArea()
            
            VStack {
                if viewModel.errorMessage != nil {
                    ErrorMessageView(message: $viewModel.errorMessage)
                        .offset(y: 25)
                }
                Spacer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                viewModel.saveSession()
        }
    }
    
    var backButton: some View {
        Button {
            if !isRecording {
                if viewModel.currentlyPlaying == nil {
                    viewModel.playheadPositionDidChange(position: 0.0)
                    viewModel.setLastPlayheadPosition(position: 0.0)
                }
                viewModel.saveSession()
                dismiss()
            }
            
        } label: {
            ZStack {
                Image(systemName: "chevron.left.circle.fill")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .opacity(0.1)
                    
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: 8, height: 14)
                    .padding(.trailing, 2)
            }
            .padding(15)
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    SessionDetailView(
        recordingManager: MockRecordingManager(),
        audioManager: MockAudioManager(),
        session: Session.sessionFixture,
        isRecording: false
    )
}
