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
        isGlobalSoloActive: Bool,
        isSessionPlaying: Bool,
        trackTimer: Double,
        muteButtonAction: @escaping (_: Track) -> Void,
        soloButtonAction: @escaping (_: Track) -> Void,
        onTrackVolumeChange: @escaping (_: Track, _: Float) -> Void,
        onTrackPanChange: @escaping (_: Track, _: Float) -> Void,
        getWaveformImage: @escaping (_: String, _: ColorScheme) -> Image,
        trashButtonAction: @escaping (_: Track) -> Void
    ) {
        self.track = track
        self.isGlobalSoloActive = isGlobalSoloActive
        self.isSessionPlaying = isSessionPlaying
        self.trackTimer = trackTimer
        self.muteButtonAction = muteButtonAction
        self.soloButtonAction = soloButtonAction
        self.onTrackVolumeChange = onTrackVolumeChange
        self.onTrackPanChange = onTrackPanChange
        self.getWaveformImage = getWaveformImage
        self.trashButtonAction = trashButtonAction
        self.volumeSliderValue = Double(track.volume)
        self.panSliderValue = Double(track.pan)
    }
    
    //MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @State private var volumeSliderValue: Double
    @State private var panSliderValue: CGFloat
    @State private var lastPanValue: CGFloat = 0.0
    @State private var waveformWidth: CGFloat = UIScreen.main.bounds.width - 215
    @State private var waveform: Image = Image(systemName: "waveform")
    @State private var muteButtonOpacity: Double = 0.75
    @State private var panSliderWidth: Double = 0.0
    
    private var track: Track
    private var isGlobalSoloActive: Bool
    private var trackTimer: Double
    
    
    private let isSessionPlaying: Bool
    
    private var progressPercentage: Double {
        isSessionPlaying ? min(trackTimer / track.length, 1.0) : 0.0
    }
    
    private var offset: Double {
        return (waveformWidth / -2.0) + (waveformWidth * progressPercentage)
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
    private let onTrackVolumeChange: (_: Track, _ : Float) -> Void
    private let onTrackPanChange: (_: Track, _ : Float) -> Void
    private let getWaveformImage: (_: String, _: ColorScheme) -> Image
    private let trashButtonAction: (_: Track) -> Void
    
    //MARK: - Body
        
    var body: some View {
        
        let drag = DragGesture()
            .onChanged() { gesture in
                if panSliderValue <= 1.0, panSliderValue >= -1.0 {
                    panSliderValue = (gesture.translation.width / panSliderWidth) + lastPanValue
                    onTrackPanChange(track, Float(panSliderValue))
                }
                
            }
            .onEnded { _ in
                if panSliderValue < -1.0 {
                    panSliderValue = -1.0
                    onTrackPanChange(track, Float(panSliderValue))
                } else if panSliderValue > 1.0 {
                    panSliderValue = 1.0
                    onTrackPanChange(track, Float(panSliderValue))
                }
                lastPanValue = panSliderValue
            }
        
        ZStack {
            VStack {
                HStack(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(track.name)
                                .font(.title3)
                                .lineLimit(1)
                            Text(track.lengthDisplayString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button {
                                trashButtonAction(track)
                            } label: {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(.primary)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 80.0)
                    Spacer()
                    waveform
                        .resizable()
                        .opacity(trackOpacity)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 215, height: 70)
                        .animation(.linear(duration: 0.25), value: trackOpacity)
                        
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            soloButtonAction(track)
                        } label: {
                            if track.isSolo, isGlobalSoloActive {
                                TrackCellButtonImage("s.square.fill")
                                    .foregroundStyle(.purple)
                            } else {
                                TrackCellButtonImage("s.square")
                            }
                        }
                        
                        Button {
                            muteButtonAction(track)
                        } label: {
                            if track.isMuted, track.soloOverride {
                                TrackCellButtonImage("m.square.fill")
                                    .foregroundStyle(.pink)
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
                                TrackCellButtonImage("m.square.fill")
                                    .foregroundStyle(.pink)
                            } else {
                                TrackCellButtonImage("m.square")
                            }
                        }
                    }
                    .frame(width: 80.0)
                }
                Divider()
                HStack {
                    TrackCellButtonImage("speaker.wave.2")
                        .foregroundStyle(.secondary)
                    Slider(value: $volumeSliderValue)
                        .tint(appTheme.accentColor)
                        .padding(.trailing, 10)
                        .onChange(of: volumeSliderValue) {
                            onTrackVolumeChange(track, Float(volumeSliderValue))
                        }
                }
                .padding(.bottom, 7)
                HStack {
                    TrackCellButtonImage("l.circle")
                        .foregroundStyle(.secondary)
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
                        }
                    }
                    .gesture(drag)
                    .onTapGesture(count: 2) {
                        lastPanValue = 0.0
                        panSliderValue = 0.0
                        onTrackPanChange(track, 0.0)
                    }
                    TrackCellButtonImage("r.circle")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground).opacity(0.3))
            
            Rectangle()
                .frame(maxWidth: 1, maxHeight: 87)
                .foregroundStyle(.red)
                .offset(x: offset, y: -45)
                .animation(
                    isSessionPlaying ? .none : .linear(duration: 0.5).delay(0.25),
                    value: offset
                )
                .opacity(trackOpacity)
                .animation(.linear(duration: 0.25), value: trackOpacity)
        }
        .onAppear {
            waveform = getWaveformImage(track.fileName, colorScheme)
        }
    }
}

struct TrackCellButtonImage: View {
    let imageName: String
    
    init(_ imageName: String) {
        self.imageName = imageName
    }
    
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
}

#Preview {
    TrackCellView(
        track: Session.trackFixture,
        isGlobalSoloActive: false,
        isSessionPlaying: false,
        trackTimer: 0.0,
        muteButtonAction: { _ in },
        soloButtonAction: { _ in },
        onTrackVolumeChange: { _, _ in },
        onTrackPanChange: {_, _ in },
        getWaveformImage: { _,_ in return Image("") },
        trashButtonAction: { _ in })
}
