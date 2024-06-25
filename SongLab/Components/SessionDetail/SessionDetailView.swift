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
    
    @Environment(\.dismiss) var dismiss
    @State private var opacity: Double = 0.0
    @StateObject private var viewModel: SessionDetailViewModel
    
    //MARK: - Body
    
    var body: some View {
        
        VStack {
            HStack {
                backButton
                Spacer()
                Text(viewModel.session.name)
                    .font(.largeTitle)
                Spacer()
                backButton.opacity(0.0)
            }
            Spacer()
            MasterCell(
                session: viewModel.session,
                currentlyPlaying: viewModel.currentlyPlaying,
                playButtonAction: viewModel.trackCellPlayButtonTapped,
                stopButtonAction: viewModel.trackCellStopButtonTapped,
                globalSoloButtonAction: viewModel.masterCellSoloButtonTapped
            )
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(viewModel.session.tracks.values)) { track in
                        TrackCell(
                            track: track,
                            isGlobalSoloActive: viewModel.session.isGlobalSoloActive,
                            muteButtonAction: viewModel.trackCellMuteButtonTapped,
                            soloButtonAction: viewModel.trackCellSoloButtonTapped,
                            onTrackVolumeChange: viewModel.setTrackVolume
                        )
                    }
                }
            }
            .animation(.spring, value: viewModel.session.tracks)
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.75), value: opacity)
        .onAppear {
            self.opacity = 1.0
        }
        .padding(.top, 15)
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
