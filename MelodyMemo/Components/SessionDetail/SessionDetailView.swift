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
        
    @Environment(\.dismiss) private var dismiss

    @State private var opacity: Double = 0.0
    @StateObject private var viewModel: SessionDetailViewModel
    
    private var bpmSectionOpacity: Double {
        viewModel.session.isUsingGlobalBpm ? 0.3 : 1.0
    }
    
    private var isRecording: Bool

    //MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Text(viewModel.session.name)
                            .font(.largeTitle)
                            .frame(width: 200)
                    }
                    HStack {
                        Spacer()
                        backButton
                            .padding(.trailing, 10)
                            .padding(.bottom, 5)
                    }
                }
                .padding(.top, 5)
                Divider()
                
                controlPanelView
                
                GeometryReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(viewModel.sortedGroups) { group in
                                let isCurrentlyPlaying = viewModel.currentlyPlaying == group
                                let isAdjustingPlayhead = viewModel.isAdjustingGroupPlayhead == group
                                let isGroupSoloActive = group.isGroupSoloActive
                                let isGroupExpanded = group.isGroupExpanded
                                let sortedTracks = group.sortedTracks
                                let isPlaybackPaused = viewModel.isGroupPlaybackPaused == group
                                Section {
                                    if isGroupExpanded {
                                        ForEach(sortedTracks) { track in
                                            TrackCellView(
                                                track: track,
                                                group: group,
                                                isGlobalSoloActive: isGroupSoloActive,
                                                isCurrentlyPlaying: isCurrentlyPlaying,
                                                isAdjustingGroupIndicators: $viewModel.isAdjustingGroupIndicators,
                                                isAdjustingGroupPlayhead: $viewModel.isAdjustingGroupPlayhead,
                                                isAdjustingPlayhead: isAdjustingPlayhead,
                                                trackTimer: viewModel.trackTimer,
                                                leftIndicatorDragOffset: $viewModel.leftIndicatorDragOffset,
                                                rightIndicatorDragOffset: $viewModel.rightIndicatorDragOffset,
                                                waveformWidth: $viewModel.waveformWidth,
                                                isPlaybackPaused: isPlaybackPaused,
                                                muteButtonAction: viewModel.trackCellMuteButtonTapped,
                                                soloButtonAction: viewModel.trackCellSoloButtonTapped,
                                                trackVolumeDidChange: viewModel.trackVolumeDidChange,
                                                trackPanDidChange: viewModel.trackPanDidChange,
                                                playheadPositionDidChange: viewModel.playheadPositionDidChange,
                                                setLastPlayheadPosition: viewModel.setLastPlayheadPosition,
                                                restartPlaybackFromPosition: viewModel.restartPlaybackFromPosition,
                                                trackCellPlayPauseAction: viewModel.trackCellPlayPauseAction,
                                                stopTimer: viewModel.stopTimer,
                                                trashButtonAction: viewModel.trackCellTrashButtonTapped,
                                                getExpandedWaveform: viewModel.getExpandedWaveform,
                                                leftIndicatorPositionDidChange: viewModel.leftIndicatorPositionDidChange,
                                                rightIndicatorPositionDidChange: viewModel.rightIndicatorPositionDidChange
                                            )
                                        }
                                    }
                                } header: {
                                    GroupView(
                                        group: group,
                                        session: viewModel.session,
                                        armedGroup: $viewModel.armedGroup,
                                        currentlyPlaying: viewModel.currentlyPlaying,
                                        playheadPosition: viewModel.trackTimer,
                                        isAdjustingGroupIndicators: $viewModel.isAdjustingGroupIndicators,
                                        isGroupPlaybackPaused: viewModel.isGroupPlaybackPaused,
                                        leftIndicatorDragOffset: $viewModel.leftIndicatorDragOffset,
                                        rightIndicatorDragOffset: $viewModel.rightIndicatorDragOffset,
                                        playButtonTapped: viewModel.playButtonTapped,
                                        stopButtonTapped: viewModel.stopButtonTapped,
                                        pauseButtonTapped: viewModel.pauseButtonTapped,
                                        soloButtonTapped: viewModel.soloButtonTapped,
                                        leftIndicatorPositionDidChange: viewModel.leftIndicatorPositionDidChange,
                                        rightIndicatorPositionDidChange: viewModel.rightIndicatorPositionDidChange,
                                        deleteGroupAction: viewModel.deleteGroupAction,
                                        toggleIsLoopActive: viewModel.toggleIsLoopActive,
                                        toggleIsGroupExpanded: viewModel.toggleIsGroupExpanded,
                                        groupLabelDidChange: viewModel.groupLabelDidChange,
                                        loopReferenceTrackDidChange: viewModel.loopReferenceTrackDidChange,
                                        isPlayheadOutOfPosition: viewModel.isPlayheadOutOfPosition
                                    )
                                }
                            }
                            CellSpacerView(
                                screenHeight: proxy.size.height,
                                numberOfSessions: viewModel.session.armedGroup.tracks.count,
                                showMessage: false
                            )
                        }
                        .animation(.spring, value: viewModel.session.groups)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.opacity = 1.0
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
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                viewModel.saveSession()
        }
    }
    
    var controlPanelView: some View {
        HStack {
            VStack {
                HStack {
                    Button {
                        if viewModel.sessionBpm > 0 {
                            viewModel.sessionBpm -= 1
                        }
                    } label: {
                        AppButtonLabelView(name: "minus", color: .primary)
                    }
                    .buttonRepeatBehavior(.enabled)
                    Text("BPM")
                        .frame(width: 40)
                    Text("\(viewModel.sessionBpm == 0 ? "--" : "\(viewModel.sessionBpm)")")
                        .frame(width: 33)
                        .foregroundStyle(.secondary)
                    Button {
                        if viewModel.sessionBpm < 300 {
                            viewModel.sessionBpm += 1
                        }
                    } label: {
                        AppButtonLabelView(name: "plus", color: .primary)
                    }
                    .buttonRepeatBehavior(.enabled)
                }
                .opacity(bpmSectionOpacity)
                useGlobalBpmButtonView
            }
            Divider()
                .frame(height: 30)
            Spacer()
            
            Button {
                viewModel.addGroup()
            } label: {
                VStack {
                    AppButtonLabelView(name: "plus", color: .primary)
                    Text("Add Group")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(5)
    }
    
    var backButton: some View {
        Button {
            if !isRecording {
                if viewModel.currentlyPlaying == nil {
                    viewModel.playheadPositionDidChange(position: 0.0)
                }
                viewModel.saveSession()
                viewModel.isAdjustingGroupPlayhead = nil
                dismiss()
            }
            
        } label: {
            AppButtonLabelView(name: "xmark", color: .primary, size: 20)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
        }
        .foregroundColor(.primary)
    }
    
    var useGlobalBpmButtonView: some View {
        
        Button {
            viewModel.isUsingGlobalBpm.toggle()
        } label: {
            ZStack {
                if viewModel.isUsingGlobalBpm {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 75, height: 15)
                        .foregroundStyle(appTheme.accentColor)
                    Text("Use Global")
                        .font(.caption)
                        .foregroundStyle(.black)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1.0)
                        .frame(width: 75, height: 15)
                        .foregroundStyle(appTheme.accentColor)
                    Text("Use Global")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
        }
        .foregroundStyle(.primary)
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
