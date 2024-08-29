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
        session: Session,
        isGlobalSoloActive: Bool,
        isSessionPlaying: Bool,
        trackTimer: Double,
        lastPlayheadPosition: Double,
        leftIndicatorDragOffset: Binding<CGFloat>,
        rightIndicatorDragOffset: Binding<CGFloat>,
        waveformWidth: Binding<Double>,
        muteButtonAction: @escaping (_: Track) -> Void,
        soloButtonAction: @escaping (_: Track) -> Void,
        trackVolumeDidChange: @escaping (_: Track, _: Float) -> Void,
        trackPanDidChange: @escaping (_: Track, _: Float) -> Void,
        playheadPositionDidChange: @escaping( _: Double) -> Void,
        setLastPlayheadPosition: @escaping( _: Double) -> Void,
        restartPlaybackFromPosition: @escaping( _: Double) -> Void,
        trackCellPlayPauseAction: @escaping() -> Void,
        stopTimer: @escaping() -> Void,
        trashButtonAction: @escaping (_: Track) -> Void,
        getExpandedWaveform: @escaping (_: Track, _: ColorScheme) -> Image,
        leftIndicatorPositionDidChange: @escaping (_: Double) -> Void,
        rightIndicatorPositionDidChange: @escaping (_: Double) -> Void
    ) {
        self.track = track
        self.session = session
        self.isGlobalSoloActive = isGlobalSoloActive
        self.isSessionPlaying = isSessionPlaying
        self.trackTimer = trackTimer
        self.lastPlayheadPosition = lastPlayheadPosition
        _leftIndicatorDragOffset = leftIndicatorDragOffset
        _rightIndicatorDragOffset = rightIndicatorDragOffset
        _waveformWidth = waveformWidth
        
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
    
    //MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var appTheme: AppTheme
    
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
    private var session: Session
    private var isGlobalSoloActive: Bool
    private var trackTimer: Double
    private var lastPlayheadPosition: Double
    
    
    private let isSessionPlaying: Bool
    
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
            for: leftIndicatorDragOffset,
            width: waveformWidth
        )
        
        let timePercentage = session.leftIndicatorTime / track.length
        let relativePosition = timePercentage * waveformWidth
        
        var position = relativePosition + dragOffset + (waveformWidth / -2.0)
        position = max(position, (waveformWidth / -2.0))
        position = min(position, (waveformWidth / 2.0))
        
        return position
    }
    
    private var rightIndicatorPosition: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: rightIndicatorDragOffset,
            width: waveformWidth
        )
        
        let timePercentage = session.rightIndicatorTime / track.length
        let relativePosition = timePercentage * waveformWidth
        
        let position = relativePosition + dragOffset + (waveformWidth / -2.0)
        
        return min(position, (waveformWidth / 2.0))
    }
    
    private var leftIndicatorPositionZoomed: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: leftIndicatorDragOffset,
            width: expandedWaveformWidth
        )
        
        let timePercentage = session.leftIndicatorTime / track.length
        let relativePosition = timePercentage * expandedWaveformWidth
        
        let position = relativePosition + dragOffset + (expandedWaveformWidth / -2.0)
        
        return position
    }
    
    private var rightIndicatorPositionZoomed: CGFloat {
        
        let dragOffset = getDistanceForCurrentTrack(
            for: rightIndicatorDragOffset,
            width: expandedWaveformWidth
        )
        
        let timePercentage = session.rightIndicatorTime / track.length
        let relativePosition = timePercentage * expandedWaveformWidth
        
        let position = relativePosition + dragOffset + (expandedWaveformWidth / -2.0)
        
        return position
    }
    
    private var progressPercentage: Double {
        min(trackTimer / track.length, 1.0)
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
    
    private let muteButtonAction: (_: Track) -> Void
    private let soloButtonAction: (_: Track) -> Void
    private let trackVolumeDidChange: (_: Track, _ : Float) -> Void
    private let trackPanDidChange: (_: Track, _ : Float) -> Void
    private let playheadPositionDidChange: ( _: Double) -> Void
    private let setLastPlayheadPosition: ( _: Double) -> Void
    private let restartPlaybackFromPosition: ( _: Double) -> Void
    private let trackCellPlayPauseAction: () -> Void
    private let stopTimer: () -> Void
    private let trashButtonAction: (_: Track) -> Void
    private let getExpandedWaveform: (_: Track, _: ColorScheme) -> Image
    private let leftIndicatorPositionDidChange: (_: Double) -> Void
    private let rightIndicatorPositionDidChange: (_: Double) -> Void
    
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
                trackPanDidChange(track, Float(newPosition))
            }
            .onEnded { _ in
                lastPanValue = panSliderValue
            }
        
        let scrub = DragGesture()
            .onChanged() { gesture in
                if !isTimerStopped {
                    stopTimer()
                    isTimerStopped = true
                }
                
                let localTimeRatio = lastPlayheadPosition / track.length
                let distance = localTimeRatio * waveformWidth
                let newDistanceRatio = (gesture.translation.width + distance) / waveformWidth
                
                let newPosition = newDistanceRatio * track.length
                if newPosition > track.length {
                    playheadPositionDidChange(track.length)
                    setLastPlayheadPosition(track.length)
                } else if newPosition < 0.0 {
                    playheadPositionDidChange(0.0)
                } else {
                    playheadPositionDidChange(newPosition)
                }
                
            }
            .onEnded { _ in
                if trackTimer < 0.0 {
                    playheadPositionDidChange(0.0)
                    setLastPlayheadPosition(0.0)
                } else if trackTimer > track.length {
                    playheadPositionDidChange(track.length)
                    setLastPlayheadPosition(track.length)
                } else {
                    setLastPlayheadPosition(trackTimer)
                }
                if isSessionPlaying {
                    restartPlaybackFromPosition(trackTimer)
                }
                isTimerStopped = false
            }
        
        let leftIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
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
                    (leftIndicatorPositionZoomed - leftIndicatorBound) / expandedWaveformWidth
                )
            }
        
        let rightIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                
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
                    (rightIndicatorPositionZoomed - leftIndicatorBound) / expandedWaveformWidth
                )
                
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
                                    trashButtonAction(track)
                                } label: {
                                    AppButtonLabelView(name: "trash", color: .primary, size: 18)
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
                                        if session.isLoopActive {
                                            
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
                                                    isSessionPlaying ? .none : .linear(duration: 0.3), 
                                                    value: lastPlayheadPosition
                                                )
                                                .gesture(leftIndicatorDrag)
                                            
                                            Rectangle()
                                                .frame(maxWidth: 100, maxHeight: 70)
                                                .foregroundStyle(.white.opacity(0.001))
                                                .offset(x: rightIndicatorPositionZoomed)
                                                .animation(
                                                    isSessionPlaying ? .none : .linear(duration: 0.3),
                                                    value: lastPlayheadPosition
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
                                                isSessionPlaying ? .none : .linear(duration: 0.3),
                                                value: lastPlayheadPosition
                                            )
                                    }
                                }
                            } else {
                                ZStack {
                                    if session.isLoopActive {
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
                                                    setLastPlayheadPosition(0.0)
                                                    playheadPositionDidChange(0.0)
                                                    if isSessionPlaying {
                                                        restartPlaybackFromPosition(0.0)
                                                    }
                                                }
                                                .onTapGesture {
                                                    trackCellPlayPauseAction()
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
                                                setLastPlayheadPosition(0.0)
                                                playheadPositionDidChange(0.0)
                                                if isSessionPlaying {
                                                    restartPlaybackFromPosition(0.0)
                                                }
                                            }
                                            .onTapGesture {
                                                trackCellPlayPauseAction()
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
                            soloButtonAction(track)
                        } label: {
                            if track.isSolo, isGlobalSoloActive {
                                AppButtonLabelView(name: "s.square.fill", color: .purple)
                            } else {
                                AppButtonLabelView(name: "s.square", color: .primary)
                            }
                        }
                        
                        Button {
                            muteButtonAction(track)
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
                            trackVolumeDidChange(track, Float(volumeSliderValue))
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
                        trackPanDidChange(track, 0.0)
                    }
                    AppButtonLabelView(name: "r.circle", color: .secondary)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground).opacity(0.3))
            
            if !isTrackZoomed {
                Rectangle()
                    .frame(maxWidth: 1, maxHeight: 87)
                    .foregroundStyle(.red)
                    .offset(x: playheadPosition, y: -45)
                    .opacity(trackOpacity)
                    .animation(.linear(duration: 0.25), value: trackOpacity)
                    .animation(isSessionPlaying ? .none : .linear(duration: 0.3), value: lastPlayheadPosition)
                
                Rectangle()
                    .frame(maxWidth: 50, maxHeight: 87)
                    .foregroundStyle(.white.opacity(0.001))
                    .offset(x: playheadPosition, y: -45)
                    .animation(isSessionPlaying ? .none : .linear(duration: 0.3), value: lastPlayheadPosition)
                    .gesture(scrub)
            }
            
        }
        .onAppear {
            guard let lightImage = UIImage(data: track.lightWaveformImage) else {
                return
            }
            guard let darkImage = UIImage(data: track.darkWaveformImage) else {
                return
            }
            waveform = colorScheme == .dark ? Image(uiImage: lightImage) : Image(uiImage: darkImage)
        }
    }
    
    func getDistanceForRefernceTrack(_ distance: Double) -> Double {
        let localRatio = distance / expandedWaveformWidth
        let distanceInTime = localRatio * track.length
        let referenceTrackRatio = distanceInTime / session.loopReferenceTrack.length
        
        return referenceTrackRatio * waveformWidth
    }
    
    func getDistanceForCurrentTrack(for distance: Double, width: Double) -> Double {
        let referenceTrackRatio = distance / waveformWidth
        let distanceInTime = referenceTrackRatio * session.loopReferenceTrack.length
        let localRatio = distanceInTime / track.length
        
        return localRatio * width
    }
    
}

#Preview {
    TrackCellView(
        track: Session.trackFixture,
        session: Session.sessionFixture,
        isGlobalSoloActive: false,
        isSessionPlaying: false,
        trackTimer: 0.0,
        lastPlayheadPosition: 0.0,
        leftIndicatorDragOffset: .constant(0.0),
        rightIndicatorDragOffset: .constant(0.0),
        waveformWidth: .constant(200),
        muteButtonAction: { _ in },
        soloButtonAction: { _ in },
        trackVolumeDidChange: {  _, _ in },
        trackPanDidChange: { _, _ in },
        playheadPositionDidChange: { _ in },
        setLastPlayheadPosition: { _ in },
        restartPlaybackFromPosition: { _ in },
        trackCellPlayPauseAction: {},
        stopTimer: {},
        trashButtonAction: { _ in },
        getExpandedWaveform: { _, _ in return Image(systemName: "waveform")},
        leftIndicatorPositionDidChange: { _ in },
        rightIndicatorPositionDidChange: { _ in }
    )
}
