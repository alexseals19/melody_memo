//
//  TrackCell.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI
import Foundation
import AVFoundation

struct TrackCell: View {
    
    //MARK: - API
        
    init(
        track: Track,
        isGlobalSoloActive: Bool,
        isSessionPlaying: Bool,
        trackTimer: Double,
        muteButtonAction: @escaping (_: Track) -> Void,
        soloButtonAction: @escaping (_: Track) -> Void,
        onTrackVolumeChange: @escaping (_: Track, _ : Float) -> Void,
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
        self.getWaveformImage = getWaveformImage
        self.trashButtonAction = trashButtonAction
        self.sliderValue = Double(track.volume)
    }
    
    //MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @State private var sliderValue: Double
    @State private var waveformWidth: CGFloat = UIScreen.main.bounds.width - 205
    @State private var waveform: Image = Image(systemName: "waveform")
    @State private var muteButtonOpacity: Double = 0.75
    
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
    private let getWaveformImage: (_: String, _: ColorScheme) -> Image
    private let trashButtonAction: (_: Track) -> Void
    
    //MARK: - Body
        
    var body: some View {
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
                        }
                        Spacer()
                    }
                    .frame(width: 75.0)
                    Spacer()
                    waveform
                        .resizable()
                        .opacity(trackOpacity)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 205, height: 70)
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
                    .frame(width: 75.0)
                }
                Divider()
                HStack {
                    TrackCellButtonImage("speaker.wave.2")
                    Slider(value: $sliderValue)
                        .tint(.primary)
                        .padding(.trailing, 10)
                        .onChange(of: sliderValue) {
                            onTrackVolumeChange(track, Float(sliderValue))
                        }
                    Button {
                        trashButtonAction(track)
                    } label: {
                        TrackCellButtonImage("trash")
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(.primary)
            .background(appTheme.cellBackground)
            
            Rectangle()
                .frame(maxWidth: 1, maxHeight: 87)
                .foregroundStyle(.red)
                .offset(x: offset, y: -25)
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
