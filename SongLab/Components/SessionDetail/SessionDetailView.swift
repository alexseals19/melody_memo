//
//  SessionDetailView.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI

struct SessionDetailView: View {
    
    //MARK: - API
        
    init(recordingManager: RecordingManager, audioManager: AudioManager, session: Session) {
        _viewModel = StateObject(
            wrappedValue: SessionDetailViewModel(
                recordingManager: recordingManager,
                audioManager: audioManager,
                session: session
            )
        )
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @Environment(\.dismiss) var dismiss
    
    @State private var opacity: Double = 0.0
    @StateObject private var viewModel: SessionDetailViewModel
    
    private var tracks: [Track] {
        viewModel.session.tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
            return lhs.date > rhs.date
        }
    }
    
    //MARK: - Body
    
    var body: some View {
        
        VStack(spacing: 0.0) {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1.0)
                .foregroundStyle(appTheme.cellDividerColor)
            HStack {
                backButton
                Spacer()
                Text(viewModel.session.name)
                    .font(.largeTitle)
                Spacer()
                Button {
                    viewModel.sessionTrashButtonTapped()
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                .foregroundStyle(.primary)
                .padding(15)
            }
            .background(appTheme.cellBackground)
            
            MasterCell(
                session: viewModel.session,
                currentlyPlaying: viewModel.currentlyPlaying,
                playButtonAction: viewModel.trackCellPlayButtonTapped,
                stopButtonAction: viewModel.trackCellStopButtonTapped,
                globalSoloButtonAction: viewModel.masterCellSoloButtonTapped
            )
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0.0) {
                        ForEach(tracks) { track in
                            VStack(spacing: 0.0) {
                                Rectangle()
                                    .frame(maxWidth: .infinity, maxHeight: 1.0)
                                    .foregroundStyle(appTheme.cellDividerColor)
                                TrackCell(
                                    track: track,
                                    isGlobalSoloActive: viewModel.session.isGlobalSoloActive,
                                    isSessionPlaying: viewModel.isSessionPlaying,
                                    trackTimer: viewModel.trackTimer,
                                    muteButtonAction: viewModel.trackCellMuteButtonTapped,
                                    soloButtonAction: viewModel.trackCellSoloButtonTapped,
                                    onTrackVolumeChange: viewModel.setTrackVolume,
                                    getWaveformImage: viewModel.getWaveformImage,
                                    trashButtonAction: viewModel.trackCellTrashButtonTapped
                                )
                            }
                        }
                        CellSpacer(
                            screenHeight: proxy.size.height,
                            numberOfSessions: viewModel.session.tracks.count
                        )
                    }
                    .animation(.spring, value: viewModel.session.tracks)
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .offset(y: 75.0)
        .background(appTheme.backgroundImage)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.opacity = 1.0
            }
        }
        .ignoresSafeArea()
    }
    
    var backButton: some View {
        Button {
            viewModel.saveSession()
            dismiss()
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
