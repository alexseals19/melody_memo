//
//  TrackCellView.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI
import Foundation
import AVFoundation

struct TrackCellView: View {
    
    //MARK: - API
        
    init(
        track: Track,
        group: SessionGroup,
        isGlobalSoloActive: Bool,
        isCurrentlyPlaying: Bool,
        isAdjustingGroupIndicators: Binding<SessionGroup?>,
        isAdjustingGroupPlayhead: Binding<SessionGroup?>,
        isAdjustingPlayhead: Bool,
        trackTimer: Double,
        leftIndicatorDragOffset: Binding<CGFloat>,
        rightIndicatorDragOffset: Binding<CGFloat>,
        waveformWidth: Binding<Double>,
        isPlaybackPaused: Bool,
        muteButtonAction: @escaping (_: Track, _: SessionGroup) -> Void,
        soloButtonAction: @escaping (_: Track, _: SessionGroup) -> Void,
        trackVolumeDidChange: @escaping (_: Track, _: SessionGroup, _: Float) -> Void,
        trackPanDidChange: @escaping (_: Track, _: SessionGroup, _: Float) -> Void,
        playheadPositionDidChange: @escaping( _: Double) -> Void,
        setLastPlayheadPosition: @escaping( _: Double, _: SessionGroup?) -> Void,
        restartPlaybackFromPosition: @escaping( _: Double) -> Void,
        trackCellPlayPauseAction: @escaping(_: SessionGroup) -> Void,
        stopTimer: @escaping() -> Void,
        trashButtonAction: @escaping (_: Track, _: SessionGroup) -> Void,
        getExpandedWaveform: @escaping (_: Track, _: ColorScheme) -> Image,
        leftIndicatorPositionDidChange: @escaping (_: Double, _: SessionGroup) -> Void,
        rightIndicatorPositionDidChange: @escaping (_: Double, _: SessionGroup) -> Void
    ) {
        self.track = track
        self.group = group
        self.isGlobalSoloActive = isGlobalSoloActive
        self.isCurrentlyPlaying = isCurrentlyPlaying
        self.isAdjustingPlayhead = isAdjustingPlayhead
        self.trackTimer = trackTimer
        self.isPlaybackPaused = isPlaybackPaused
        _leftIndicatorDragOffset = leftIndicatorDragOffset
        _rightIndicatorDragOffset = rightIndicatorDragOffset
        _waveformWidth = waveformWidth
        _isAdjustingGroupPlayhead = isAdjustingGroupPlayhead
        _isAdjustingGroupIndicators = isAdjustingGroupIndicators
        
        self.muteButtonAction = muteButtonAction
        self.soloButtonAction = soloButtonAction
        self.trackVolumeDidChange = trackVolumeDidChange
        self.trackPanDidChange = trackPanDidChange
        self.playheadPositionDidChange = playheadPositionDidChange
        self.setLastPlayheadPosition = setLastPlayheadPosition
        self.restartPlaybackFromPosition = restartPlaybackFromPosition
        self.trackCellPlayPauseAction = trackCellPlayPauseAction
        self.stopTimer = stopTimer
        self.trashButtonAction = trashButtonAction
        self.getExpandedWaveform = getExpandedWaveform
        self.leftIndicatorPositionDidChange = leftIndicatorPositionDidChange
        self.rightIndicatorPositionDidChange = rightIndicatorPositionDidChange
        
        _volumeSliderValue = State(initialValue: Double(track.volume))
        _panSliderValue = State(initialValue: Double(track.pan))
        
    }
    
    @Binding var waveformWidth: Double
    @Binding var leftIndicatorDragOffset: CGFloat
    @Binding var rightIndicatorDragOffset: CGFloat
    @Binding var isAdjustingGroupPlayhead: SessionGroup?
    @Binding var isAdjustingGroupIndicators: SessionGroup?
    
    //MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @State private var isAlertShown: Bool = false
    
    @State private var volumeSliderValue: Double
    @State private var panSliderValue: CGFloat
    
    @State private var lastPanValue: CGFloat = 0.0
    @State private var waveform: Image = Image(systemName: "waveform")
    @State private var muteButtonOpacity: Double = 0.75
    @State private var panSliderWidth: Double = 0.0
    @State private var isTimerStopped: Bool = false
    @State private var isTrackZoomed: Bool = false
    @State private var expandedWaveform: Image?
    
    private var track: Track
    private var group: SessionGroup
    private var isGlobalSoloActive: Bool
    private var trackTimer: Double
    private var isAdjustingPlayhead: Bool
    private var isPlaybackPaused: Bool
    
    private let isCurrentlyPlaying: Bool
    
    private var loopOffset: Double {
        loopWidth / 2.0 + leftIndicatorPosition
    }
    
    private var expandedLoopOffset: Double {
        let width = loopWidth * expandedWaveformRatio
        return width / 2.0 + leftIndicatorPositionZoomed
    }
    
    private var loopWidth: Double {
        rightIndicatorPosition - leftIndicatorPosition
    }
    
    private var expandedWaveformWidth: Double {
        max(500, waveformWidth)
    }
    
    private var expandedWaveformRatio: Double {
        expandedWaveformWidth / waveformWidth
    }
    
    private var leftIndicatorBound: Double {
        expandedWaveformWidth / -2.0
    }
    
    private var rightIndicatorBound: Double {
        expandedWaveformWidth / 2.0
    }
    
    private var leftIndicatorPosition: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: (isAdjustingGroupIndicators == group ? leftIndicatorDragOffset : 0),
            width: waveformWidth
        )
        
        let timePercentage = group.leftIndicatorTime / track.length
        let relativePosition = timePercentage * waveformWidth
        
        var position = relativePosition + dragOffset + (waveformWidth / -2.0)
        position = max(position, (waveformWidth / -2.0))
        position = min(position, (waveformWidth / 2.0))
        
        return position
    }
    
    private var rightIndicatorPosition: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: (isAdjustingGroupIndicators == group ? rightIndicatorDragOffset : 0),
            width: waveformWidth
        )
        
        let timePercentage = group.rightIndicatorTime / track.length
        let relativePosition = timePercentage * waveformWidth
        
        let position = relativePosition + dragOffset + (waveformWidth / -2.0)
        
        return min(position, (waveformWidth / 2.0))
    }
    
    private var leftIndicatorPositionZoomed: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: (isAdjustingGroupIndicators == group ? leftIndicatorDragOffset : 0),
            width: expandedWaveformWidth
        )
        
        let timePercentage = group.leftIndicatorTime / track.length
        let relativePosition = timePercentage * expandedWaveformWidth
        
        let position = relativePosition + dragOffset + (expandedWaveformWidth / -2.0)
        
        return position
    }
    
    private var rightIndicatorPositionZoomed: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: (isAdjustingGroupIndicators == group ? rightIndicatorDragOffset : 0),
            width: expandedWaveformWidth
        )
        
        let timePercentage = group.rightIndicatorTime / track.length
        let relativePosition = timePercentage * expandedWaveformWidth
        
        let position = relativePosition + dragOffset + (expandedWaveformWidth / -2.0)
        
        return position
    }
    
    private var progressPercentage: Double {
        if isCurrentlyPlaying || isAdjustingPlayhead || isPlaybackPaused {
            min(trackTimer / track.length, 1.0)
        } else {
            group.lastPlayheadPosition / track.length
        }
    }
    
    private var playheadPosition: Double {
        return (waveformWidth / -2.0) + (waveformWidth * progressPercentage) + 5
    }
    
    private var playheadPositionZoomed: Double {
        return (expandedWaveformWidth * progressPercentage) - (expandedWaveformWidth / 2.0)
    }
    
    private var trackOpacity: Double {
        if isGlobalSoloActive, !track.isSolo {
            return 0.45
        } else {
            return 1.0
        }
    }
    
    @State private var scrubActive: Bool = false
    
    private let muteButtonAction: (_: Track, _: SessionGroup) -> Void
    private let soloButtonAction: (_: Track, _: SessionGroup) -> Void
    private let trackVolumeDidChange: (_: Track, _: SessionGroup, _ : Float) -> Void
    private let trackPanDidChange: (_: Track, _: SessionGroup, _ : Float) -> Void
    private let playheadPositionDidChange: ( _: Double) -> Void
    private let setLastPlayheadPosition: ( _: Double, _: SessionGroup?) -> Void
    private let restartPlaybackFromPosition: ( _: Double) -> Void
    private let trackCellPlayPauseAction: (_: SessionGroup) -> Void
    private let stopTimer: () -> Void
    private let trashButtonAction: (_: Track, _: SessionGroup) -> Void
    private let getExpandedWaveform: (_: Track, _: ColorScheme) -> Image
    private let leftIndicatorPositionDidChange: (_: Double, _: SessionGroup) -> Void
    private let rightIndicatorPositionDidChange: (_: Double, _: SessionGroup) -> Void
    
    //MARK: - Body
        
    var body: some View {
        
        let drag = DragGesture()
            .onChanged() { gesture in
                var newPosition = (gesture.translation.width / panSliderWidth) + lastPanValue
                
                if newPosition > 1.0 {
                    newPosition = 1.0
                } else if newPosition < -1.0 {
                    newPosition = -1.0
                }
                
                panSliderValue = newPosition
                trackPanDidChange(track, group, Float(newPosition))
            }
            .onEnded { _ in
                lastPanValue = panSliderValue
            }
        
        let scrub = DragGesture()
            .onChanged() { gesture in
                
                var lastPlayheadPosition = group.lastPlayheadPosition
                
                if !isTimerStopped {
                    stopTimer()
                    isTimerStopped = true
                    isAdjustingGroupPlayhead = group
                    setLastPlayheadPosition(trackTimer, group)
                    lastPlayheadPosition = trackTimer
                }

                let localTimeRatio = lastPlayheadPosition / track.length
                let distance = localTimeRatio * waveformWidth
                let newDistanceRatio = (gesture.translation.width + distance) / waveformWidth
                
                let newPosition = newDistanceRatio * track.length
                if newPosition > track.length {
                    playheadPositionDidChange(track.length)
                    setLastPlayheadPosition(track.length, group)
                } else if newPosition < 0.0 {
                    playheadPositionDidChange(0.0)
                } else {
                    playheadPositionDidChange(newPosition)
                }
                
            }
            .onEnded { _ in
                scrubActive = false
                if trackTimer < 0.0 {
                    playheadPositionDidChange(0.0)
                    setLastPlayheadPosition(0.0, group)
                } else if trackTimer > track.length {
                    playheadPositionDidChange(track.length)
                    setLastPlayheadPosition(track.length, group)
                } else {
                    setLastPlayheadPosition(trackTimer, group)
                }
                if isCurrentlyPlaying {
                    restartPlaybackFromPosition(trackTimer)
                }
                isAdjustingGroupPlayhead = nil
                isTimerStopped = false
            }
        
        let leftIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                
                isAdjustingGroupIndicators = group
                
                let delta = gesture.translation.width
                
                leftIndicatorDragOffset = getDistanceForRefernceTrack(delta)
                
                if leftIndicatorPositionZoomed < leftIndicatorBound {
                    let spaceToZero = leftIndicatorBound - leftIndicatorPositionZoomed
                    
                    leftIndicatorDragOffset += getDistanceForRefernceTrack(spaceToZero)
                } else if leftIndicatorPositionZoomed > rightIndicatorPositionZoomed - 3 * expandedWaveformRatio {
                    let distance = (rightIndicatorPositionZoomed - 3 * expandedWaveformRatio) - leftIndicatorPositionZoomed
                    leftIndicatorDragOffset += getDistanceForRefernceTrack(distance)
                }
            }
            .onEnded { _ in
                leftIndicatorPositionDidChange(
                    (leftIndicatorPositionZoomed - leftIndicatorBound) / expandedWaveformWidth,
                    group
                )
                
                isAdjustingGroupIndicators = nil
                
            }
        
        let rightIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                
                isAdjustingGroupIndicators = group
                
                let delta = gesture.translation.width
                
                rightIndicatorDragOffset = getDistanceForRefernceTrack(delta)
                
                if rightIndicatorPositionZoomed > rightIndicatorBound {
                    let distance = rightIndicatorPositionZoomed - rightIndicatorBound
                    
                    rightIndicatorDragOffset -= getDistanceForRefernceTrack(distance)
                } else if rightIndicatorPositionZoomed < (leftIndicatorPositionZoomed + 3 * expandedWaveformRatio) {
                    let distance = (leftIndicatorPositionZoomed + 3 * expandedWaveformRatio) - rightIndicatorPositionZoomed
                    
                    rightIndicatorDragOffset += getDistanceForRefernceTrack(distance)
                }
            }
            .onEnded { _ in
                rightIndicatorPositionDidChange(
                    (rightIndicatorPositionZoomed - leftIndicatorBound) / expandedWaveformWidth,
                    group
                )
                
                isAdjustingGroupIndicators = nil
                
            }
        
        ZStack {
            VStack {
                HStack(alignment: .center, spacing: 0.0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(track.name)
                                .font(.title3)
                                .lineLimit(1)
                            Text(track.lengthDisplayString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button {
                                    isAlertShown = true
                                } label: {
                                    AppButtonLabelView(name: "trash", color: .primary, size: 18)
                                }
                                .alert("Delete Track?", isPresented: $isAlertShown) {
                                    Button("Delete", role: .destructive) { trashButtonAction(track, group) }
                                    Button("Cancel", role: .cancel) {}
                                }
                                .padding(.trailing, 10)
                                Button {
                                    isTrackZoomed.toggle()
                                } label: {
                                    AppButtonLabelView(
                                        name: isTrackZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass",
                                        color: .primary, size: 18
                                    )
                                }
                            }
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .frame(width: 110.0)
                    GeometryReader { proxy in
                        Group {
                            if isTrackZoomed {
                                ScrollView(.horizontal) {
                                    ZStack {
                                        if group.isLoopActive {
                                            waveform
                                                .resizable()
                                                .opacity(0.4)
                                                .frame(width: expandedWaveformWidth, height: 70)
                                            
                                            HStack {
                                                waveform
                                                    .resizable()
                                                    .opacity(trackOpacity)
                                                    .frame(width: expandedWaveformWidth, height: 70)
                                                    .offset(x: 0 - expandedLoopOffset)
                                                    .animation(.linear(duration: 0.25), value: trackOpacity)
                                            }
                                            .frame(width: loopWidth * expandedWaveformRatio)
                                            .clipped()
                                            .offset(x: expandedLoopOffset)
                                            
                                            Rectangle()
                                                .frame(maxWidth: 1, maxHeight: 70)
                                                .foregroundStyle(appTheme.accentColor)
                                                .offset(x: leftIndicatorPositionZoomed)
                                                .opacity(trackOpacity)
                                                .animation(.linear(duration: 0.25), value: trackOpacity)
                                            
                                            Rectangle()
                                                .frame(maxWidth: 1, maxHeight: 70)
                                                .foregroundStyle(appTheme.accentColor)
                                                .offset(x: rightIndicatorPositionZoomed)
                                                .opacity(trackOpacity)
                                                .animation(.linear(duration: 0.25), value: trackOpacity)
                                            
                                            Rectangle()
                                                .frame(maxWidth: 100, maxHeight: 70)
                                                .foregroundStyle(.white.opacity(0.001))
                                                .offset(x: leftIndicatorPositionZoomed)
                                                .animation(
                                                    isCurrentlyPlaying ? .none : .linear(duration: 0.3),
                                                    value: group.lastPlayheadPosition
                                                )
                                                .gesture(leftIndicatorDrag)
                                            
                                            Rectangle()
                                                .frame(maxWidth: 100, maxHeight: 70)
                                                .foregroundStyle(.white.opacity(0.001))
                                                .offset(x: rightIndicatorPositionZoomed)
                                                .animation(
                                                    isCurrentlyPlaying ? .none : .linear(duration: 0.3),
                                                    value: group.lastPlayheadPosition
                                                )
                                                .gesture(rightIndicatorDrag)
                                        } else {
                                            waveform
                                                .resizable()
                                                .opacity(trackOpacity)
                                                .frame(width: expandedWaveformWidth, height: 70)
                                                .animation(.linear(duration: 0.25), value: trackOpacity)
                                        }
                                        
                                        Rectangle()
                                            .frame(maxWidth: 1, maxHeight: 70)
                                            .foregroundStyle(.red)
                                            .offset(x: playheadPositionZoomed)
                                            .opacity(trackOpacity)
                                            .animation(.linear(duration: 0.25), value: trackOpacity)
                                            .animation(
                                                isCurrentlyPlaying ? .none : .linear(duration: 0.3),
                                                value: group.lastPlayheadPosition
                                            )
                                    }
                                }
                            } else {
                                ZStack {
                                    if group.isLoopActive {
                                        waveform
                                            .resizable()
                                            .opacity(0.4)
                                            .frame(width: waveformWidth, height: 70)
                                        
                                        HStack {
                                            waveform
                                                .resizable()
                                                .opacity(trackOpacity)
                                                .frame(width: waveformWidth, height: 70)
                                                .offset(x: 0 - loopOffset)
                                                .animation(.linear(duration: 0.25), value: trackOpacity)
                                                .onTapGesture(count: 2) {
                                                    setLastPlayheadPosition(0.0, group)
                                                    playheadPositionDidChange(0.0)
                                                    if isCurrentlyPlaying {
                                                        restartPlaybackFromPosition(0.0)
                                                    }
                                                }
                                                .onTapGesture {
                                                    trackCellPlayPauseAction(group)
                                                }
                                        }
                                        .frame(width: loopWidth)
                                        .clipped()
                                        .offset(x: loopOffset)
                                        
                                        Rectangle()
                                            .frame(maxWidth: 1, maxHeight: 70)
                                            .foregroundStyle(appTheme.accentColor)
                                            .offset(x: leftIndicatorPosition)
                                            .opacity(trackOpacity)
                                            .animation(.linear(duration: 0.25), value: trackOpacity)
                                        
                                        Rectangle()
                                            .frame(maxWidth: 1, maxHeight: 70)
                                            .foregroundStyle(appTheme.accentColor)
                                            .offset(x: rightIndicatorPosition)
                                            .opacity(trackOpacity)
                                            .animation(.linear(duration: 0.25), value: trackOpacity)
                                    } else {
                                        waveform
                                            .resizable()
                                            .opacity(trackOpacity)
                                            .frame(width: waveformWidth, height: 70)
                                            .animation(.linear(duration: 0.25), value: trackOpacity)
                                            .onTapGesture(count: 2) {
                                                setLastPlayheadPosition(0.0, group)
                                                playheadPositionDidChange(0.0)
                                                if isCurrentlyPlaying {
                                                    restartPlaybackFromPosition(0.0)
                                                }
                                            }
                                            .onTapGesture {
                                                trackCellPlayPauseAction(group)
                                            }
                                    }
                                }
                            }
                        }
                        .onAppear {
                            waveformWidth = proxy.size.width
                        }
                    }
                    .frame(height: 70)
                    HStack {
                        Spacer()
                        Button {
                            soloButtonAction(track, group)
                        } label: {
                            if track.isSolo, isGlobalSoloActive {
                                AppButtonLabelView(name: "s.square.fill", color: .purple)
                            } else {
                                AppButtonLabelView(name: "s.square", color: .primary)
                            }
                        }
                        
                        Button {
                            muteButtonAction(track, group)
                        } label: {
                            if track.isMuted, track.soloOverride {
                                AppButtonLabelView(name: "m.square.fill", color: .pink)
                                    .opacity(muteButtonOpacity)
                                    .onAppear {
                                        withAnimation(
                                            .easeInOut(duration: 0.75)
                                            .repeatForever(autoreverses: true)) {
                                                muteButtonOpacity = 0.25
                                            }
                                    }
                                    .onDisappear {
                                        muteButtonOpacity = 0.75
                                    }
                            } else if track.isMuted {
                                AppButtonLabelView(name: "m.square.fill", color: .pink)
                            } else {
                                AppButtonLabelView(name: "m.square", color: .primary)
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    .frame(width: 100.0)
                }
                Divider()
                HStack {
                    AppButtonLabelView(name: "speaker.wave.2", color: .secondary)
                    Slider(value: $volumeSliderValue)
                        .tint(appTheme.accentColor)
                        .padding(.trailing, 10)
                        .onChange(of: volumeSliderValue) {
                            trackVolumeDidChange(track, group, Float(volumeSliderValue))
                        }
                }
                
                .padding(.bottom, 7)
                .padding(.horizontal, 20)
                HStack {
                    AppButtonLabelView(name: "l.circle", color: .secondary)
                    ZStack {
                        Capsule()
                            .frame(maxWidth: .infinity, maxHeight: 5)
                            .foregroundStyle(.ultraThinMaterial)
                        GeometryReader { proxy in
                            Rectangle()
                                .frame(width: 2, height: 25)
                                .foregroundStyle(.primary)
                                .shadow(color: .black, radius: 3)
                                .onAppear {
                                    panSliderWidth = proxy.size.width / 2
                                    lastPanValue = panSliderValue
                                }
                                .offset(x: panSliderWidth)
                                .offset(x: (panSliderValue * panSliderWidth))
                            
                            Rectangle()
                                .frame(width: 50, height: 25)
                                .foregroundStyle(.white.opacity(0.001))
                                .offset(x: panSliderWidth)
                                .offset(x: (panSliderValue * panSliderWidth))
                                .gesture(drag)
                        }
                    }
                    .onTapGesture(count: 2) {
                        lastPanValue = 0.0
                        panSliderValue = 0.0
                        trackPanDidChange(track, group, 0.0)
                    }
                    AppButtonLabelView(name: "r.circle", color: .secondary)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            .foregroundColor(.primary)
            
            if !isTrackZoomed {
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: 87)
                    .foregroundStyle(.red)
                    .offset(x: playheadPosition, y: -45)
                    .opacity(trackOpacity)
                    .animation(.linear(duration: 0.25), value: trackOpacity)
                    .animation(isCurrentlyPlaying ? .none : .linear(duration: 0.3), value: group.lastPlayheadPosition)
                
                Rectangle()
                    .frame(maxWidth: 50, maxHeight: 87)
                    .foregroundStyle(.white.opacity(0.001))
                    .offset(x: playheadPosition, y: -45)
                    .animation(isCurrentlyPlaying ? .none : .linear(duration: 0.3), value: group.lastPlayheadPosition)
                    .gesture(scrub)
            }
            
        }
        .onAppear {
            guard let lightImage = UIImage(data: track.lightWaveformImage) else {
                assertionFailure("Could not get lightImage")
                return
            }
            guard let darkImage = UIImage(data: track.darkWaveformImage) else {
                assertionFailure("Could not get darkImage")
                return
            }
            waveform = colorScheme == .dark ? Image(uiImage: lightImage) : Image(uiImage: darkImage)
        }
    }
    
    func getDistanceForRefernceTrack(_ distance: Double) -> Double {
        guard let loopReferenceTrack = group.loopReferenceTrack else {
            return 0.0
        }
        let localRatio = distance / expandedWaveformWidth
        let distanceInTime = localRatio * track.length
        let referenceTrackRatio = distanceInTime / loopReferenceTrack.length
        
        return referenceTrackRatio * waveformWidth
    }
    
    func getDistanceForCurrentTrack(for distance: Double, width: Double) -> Double {
        guard let loopReferenceTrack = group.loopReferenceTrack else {
            return 0.0
        }
        let referenceTrackRatio = distance / waveformWidth
        let distanceInTime = referenceTrackRatio * loopReferenceTrack.length
        let localRatio = distanceInTime / track.length
        
        return localRatio * width
    }
    
}

#Preview {
    TrackCellView(
        track: Session.trackFixture,
        group: Session.groupFixture,
        isGlobalSoloActive: false,
        isCurrentlyPlaying: false,
        isAdjustingGroupIndicators: .constant(nil),
        isAdjustingGroupPlayhead: .constant(nil),
        isAdjustingPlayhead: false,
        trackTimer: 0.0,
        leftIndicatorDragOffset: .constant(0.0),
        rightIndicatorDragOffset: .constant(0.0),
        waveformWidth: .constant(200),
        isPlaybackPaused: false,
        muteButtonAction: { _, _ in },
        soloButtonAction: { _, _ in },
        trackVolumeDidChange: {  _, _, _ in },
        trackPanDidChange: { _, _, _ in },
        playheadPositionDidChange: { _ in },
        setLastPlayheadPosition: { _, _ in },
        restartPlaybackFromPosition: { _ in },
        trackCellPlayPauseAction: { _ in },
        stopTimer: {},
        trashButtonAction: { _, _ in },
        getExpandedWaveform: { _, _ in return Image(systemName: "waveform")},
        leftIndicatorPositionDidChange: { _, _ in },
        rightIndicatorPositionDidChange: { _, _ in }
    )
}
