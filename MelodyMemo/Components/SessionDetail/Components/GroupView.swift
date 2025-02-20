//
//  GroupView.swift
//  MelodyMemo
//
//  Created by Alex Seals on 11/20/24.
//

import SwiftUI
import Combine

struct GroupView: View {
    
    //MARK: - API
    
    @Binding var armedGroup: SessionGroup
    @Binding var leftIndicatorDragOffset: CGFloat
    @Binding var rightIndicatorDragOffset: CGFloat
    @Binding var isAdjustingGroupIndicators: SessionGroup?
    
    init(
        group: SessionGroup,
        session: Session,
        armedGroup: Binding<SessionGroup>,
        currentlyPlaying: SessionGroup?,
        playheadPosition: Double,
        isAdjustingGroupIndicators: Binding<SessionGroup?>,
        isGroupPlaybackPaused: SessionGroup?,
        leftIndicatorDragOffset: Binding<CGFloat>,
        rightIndicatorDragOffset: Binding<CGFloat>,
        playButtonTapped: @escaping (_: SessionGroup) -> Void,
        stopButtonTapped: @escaping (_: SessionGroup) -> Void,
        pauseButtonTapped: @escaping () -> Void,
        soloButtonTapped: @escaping (_: SessionGroup) -> Void,
        leftIndicatorPositionDidChange: @escaping (_: Double, _: SessionGroup) -> Void,
        rightIndicatorPositionDidChange: @escaping (_: Double, _: SessionGroup) -> Void,
        deleteGroupAction: @escaping (_: SessionGroup) -> Void,
        toggleIsLoopActive: @escaping (_: SessionGroup) -> Void,
        toggleIsGroupExpanded: @escaping (_: SessionGroup) -> Void,
        groupLabelDidChange: @escaping (_: GroupLabel, _: SessionGroup) -> Void,
        loopReferenceTrackDidChange: @escaping (_: Track, _: SessionGroup) -> Void,
        isPlayheadOutOfPosition: @escaping (_: SessionGroup) -> Bool
    ) {
        _armedGroup = armedGroup
        self.group = group
        self.currentlyPlaying = currentlyPlaying
        self.playheadPosition = playheadPosition
        self.isGroupPlaybackPaused = isGroupPlaybackPaused
        self.playButtonTapped = playButtonTapped
        self.stopButtonTapped = stopButtonTapped
        self.pauseButtonTapped = pauseButtonTapped
        self.soloButtonTapped = soloButtonTapped
        self.leftIndicatorPositionDidChange = leftIndicatorPositionDidChange
        self.rightIndicatorPositionDidChange = rightIndicatorPositionDidChange
        self.deleteGroupAction = deleteGroupAction
        self.toggleIsLoopActive = toggleIsLoopActive
        self.toggleIsGroupExpanded = toggleIsGroupExpanded
        self.groupLabelDidChange = groupLabelDidChange
        self.loopReferenceTrackDidChange = loopReferenceTrackDidChange
        self.isPlayheadOutOfPosition = isPlayheadOutOfPosition
        
        _leftIndicatorDragOffset = leftIndicatorDragOffset
        _rightIndicatorDragOffset = rightIndicatorDragOffset
        _isAdjustingGroupIndicators = isAdjustingGroupIndicators
    }
    
    //MARK: - Properties
    
    @State private var isAlertShown: Bool = false
    
    private let group: SessionGroup
    private let currentlyPlaying: SessionGroup?
    private let playheadPosition: Double
    private let isGroupPlaybackPaused: SessionGroup?
    
    private let playButtonTapped: (_: SessionGroup) -> Void
    private let stopButtonTapped: (_: SessionGroup) -> Void
    private let pauseButtonTapped: () -> Void
    private let soloButtonTapped: (_: SessionGroup) -> Void
    private let leftIndicatorPositionDidChange: (_: Double, _: SessionGroup) -> Void
    private let rightIndicatorPositionDidChange: (_: Double, _: SessionGroup) -> Void
    private let deleteGroupAction: (_: SessionGroup) -> Void
    private let toggleIsLoopActive: (_: SessionGroup) -> Void
    private let toggleIsGroupExpanded: (_: SessionGroup) -> Void
    private let groupLabelDidChange: (_: GroupLabel, _: SessionGroup) -> Void
    private let loopReferenceTrackDidChange: (_: Track, _: SessionGroup) -> Void
    private let isPlayheadOutOfPosition: (_: SessionGroup) -> Bool
    
    private var arrowRotation: CGFloat {
        group.isGroupExpanded ? 90.0 : 0.0
    }
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundStyle(.ultraThinMaterial)
            HStack {
                VStack {
                    HStack {
                        Button {
                            withAnimation(.linear(duration: 0.3)) {
                                toggleIsGroupExpanded(group)
                            }
                        } label: {
                            AppButtonLabelView(name: "chevron.compact.right", color: .primary, size: 24)
                                .rotationEffect(.degrees(arrowRotation))
                        }
                        
                        Text(group.displayLabel)
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .padding(.vertical, 5)
                        
                        Menu {
                            Menu {
                                ForEach(GroupLabel.allCases) { groupLabel in
                                    Button {
                                        groupLabelDidChange(groupLabel, group)
                                    } label: {
                                        Text(groupLabel.rawValue)
                                    }
                                }
                            } label: {
                                Text("Change Label")
                                    .foregroundStyle(.primary)
                            }
                            Button(role: .destructive) {
                                isAlertShown = true
                            } label: {
                                Text("Delete")
                            }
                        } label: {
                            AppButtonLabelView(name: "ellipsis", color: .primary)
                                .rotationEffect(.degrees(90.0))
                        }
                        .alert("Delete Group?", isPresented: $isAlertShown) {
                            Button("Delete", role: .destructive) { deleteGroupAction(group) }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    armedGroup = group
                } label: {
                    if group.id == armedGroup.id {
                        Circle()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.red)
                    } else {
                        Circle()
                            .stroke(lineWidth: 1)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(spacing: 0.0) {
                    VStack {
                        HStack() {
                            HStack(spacing: 20) {
                                Button {
                                    soloButtonTapped(group)
                                } label: {
                                    if group.isGroupSoloActive {
                                        Image(systemName: "s.square.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundStyle(.purple)
                                    } else {
                                        Image(systemName: "s.square")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                Button {
                                    stopButtonTapped(group)
                                } label: {
                                    if isPlayheadOutOfPosition(group) {
                                        AppButtonLabelView(name: "backward.end", color: .primary)
                                    } else {
                                        AppButtonLabelView(name: "stop", color: currentlyPlaying == group ? .red : .primary)
                                    }
                                }
                                PlaybackControlButtonView(
                                    group: group,
                                    currentlyPlaying: currentlyPlaying,
                                    playButtonTapped: playButtonTapped,
                                    pauseButtonTapped: pauseButtonTapped
                                )
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .foregroundColor(.primary)
                }
                
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 15)
            if group.isGroupExpanded {
                VStack(spacing: 0) {
                    LoopBarView(
                        group: group,
                        leftIndicatorFraction: group.leftIndicatorFraction,
                        rightIndicatorFraction: group.rightIndicatorFraction,
                        leftIndicatorDragOffset: $leftIndicatorDragOffset,
                        rightIndicatorDragOffset: $rightIndicatorDragOffset,
                        isAdjustingGroupIndicators: $isAdjustingGroupIndicators,
                        isLoopActive: group.isLoopActive,
                        sessionTracks: group.tracks,
                        loopReferenceTrack: group.loopReferenceTrack,
                        leftIndicatorPositionDidChange: leftIndicatorPositionDidChange,
                        rightIndicatorPositionDidChange: rightIndicatorPositionDidChange,
                        loopToggleButtonAction: toggleIsLoopActive,
                        loopReferenceTrackDidChange: loopReferenceTrackDidChange
                    )
                    .frame(height: 28)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .foregroundStyle(.ultraThinMaterial)
                    
                }
            }
        }
        .background(
            Color(UIColor.secondarySystemBackground).opacity(0.5)
                .background(.black)
        )
        
    }
}

#Preview {
    GroupView(
        group: Session.groupFixture,
        session: Session.sessionFixture,
        armedGroup: .constant(Session.groupFixture),
        currentlyPlaying: nil,
        playheadPosition: 0.0,
        isAdjustingGroupIndicators: .constant(nil),
        isGroupPlaybackPaused: nil,
        leftIndicatorDragOffset: .constant(0.0),
        rightIndicatorDragOffset: .constant(0.0),
        playButtonTapped: { _ in },
        stopButtonTapped: { _ in },
        pauseButtonTapped: {},
        soloButtonTapped: { _ in },
        leftIndicatorPositionDidChange: { _, _ in },
        rightIndicatorPositionDidChange: { _, _ in },
        deleteGroupAction: { _ in },
        toggleIsLoopActive: { _ in },
        toggleIsGroupExpanded: { _ in },
        groupLabelDidChange: { _, _ in },
        loopReferenceTrackDidChange: { _, _ in },
        isPlayheadOutOfPosition:  { _ in return false}
    )
}
