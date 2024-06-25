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
    
    @EnvironmentObject var appTheme: AppTheme
    
    @Environment(\.dismiss) var dismiss
    @State private var opacity: Double = 0.0
    @StateObject private var viewModel: SessionDetailViewModel
    
    //MARK: - Body
    
    var body: some View {
        
        VStack(spacing: 1.0) {
            HStack {
                backButton
                Spacer()
                Text(viewModel.session.name)
                    .font(.largeTitle)
                Spacer()
                backButton.opacity(0.0)
            }
            .background(appTheme.cellColor)
            MasterCell(
                session: viewModel.session,
                currentlyPlaying: viewModel.currentlyPlaying,
                playButtonAction: viewModel.trackCellPlayButtonTapped,
                stopButtonAction: viewModel.trackCellStopButtonTapped,
                globalSoloButtonAction: viewModel.masterCellSoloButtonTapped
            )
            GeometryReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1.0) {
                        ForEach(
                            Array(viewModel.session.tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
                            return lhs.date > rhs.date
                        })) { track in
                            TrackCell(
                                track: track,
                                isGlobalSoloActive: viewModel.session.isGlobalSoloActive,
                                muteButtonAction: viewModel.trackCellMuteButtonTapped,
                                soloButtonAction: viewModel.trackCellSoloButtonTapped,
                                onTrackVolumeChange: viewModel.setTrackVolume
                            )
                        }
                        CellSpacer(screenHeight: proxy.size.height, numberOfSessions: viewModel.session.tracks.count)
                    }
                }
                .animation(.spring, value: viewModel.session.tracks)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.75), value: opacity)
        .onAppear {
            self.opacity = 1.0
        }
        .ignoresSafeArea()
        .padding(.top, 15)
        .background(
            appTheme.backgroundShade
                .opacity(appTheme.backgroundLayerOpacity)
                .background(
                    appTheme.backgroundImage
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .opacity(appTheme.backgroundImageOpacity)
                )
            
        )
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

#Preview {
    SessionDetailView(
        recordingManager: MockRecordingManager(),
        audioManager: MockAudioManager(),
        session: Session.recordingFixture
    )
}
