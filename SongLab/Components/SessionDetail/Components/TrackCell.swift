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
        session: Session,
        currentlyPlaying: Session?,
        progress: Double,
        muteButtonAction: @escaping (_: Track) -> Void,
        soloButtonAction: @escaping (_: Track) -> Void,
        onTrackVolumeChange: @escaping (_: Track, _ : Double) -> Void
    ) {
        self.track = track
        self.isGlobalSoloActive = isGlobalSoloActive
        self.session = session
        self.currentlyPlaying = currentlyPlaying
        self.progress = progress
        self.muteButtonAction = muteButtonAction
        self.soloButtonAction = soloButtonAction
        self.onTrackVolumeChange = onTrackVolumeChange
        self.sliderValue = Double(track.volume)
    }
    
    //MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @State private var sliderValue: Double
    @State private var waveformWidth: CGFloat = UIScreen.main.bounds.width - 205
    
    private var track: Track
    private var isGlobalSoloActive: Bool
    private var progress: Double
    
    private let session: Session
    private let currentlyPlaying: Session?
    
    private var waveform: Image {
        if let image = UIImage(
            data: colorScheme == .dark ? track.waveformLight : track.waveformDark
        ) {
            return Image(uiImage: image)
        }
        return Image("")
    }
    
    private var progressPercentage: Double {
        if let currentlyPlaying, currentlyPlaying == session {
            return min(progress / track.length, 1.0)
        }
        return 0.0
    }
    
    private var offset: Double {
        return (waveformWidth / -2.0) + (waveformWidth * progressPercentage)
    }
    
    private let muteButtonAction: (_: Track) -> Void
    private let soloButtonAction: (_: Track) -> Void
    private let onTrackVolumeChange: (_: Track, _ : Double) -> Void
    
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
                        }
                        Spacer()
                    }
                    .frame(width: 75.0)
                    Spacer()
                    waveform
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 205, height: 70)
                        
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
                            if track.isMuted {
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
                    Image(systemName: "dial.medium")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                    Slider(value: $sliderValue)
                        .tint(.primary)
                        .padding(.trailing, 10)
                        .onChange(of: sliderValue) {
                            onTrackVolumeChange(track, sliderValue)
                        }
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
                    self.currentlyPlaying != nil ? .none : .linear(duration: 0.5).delay(0.25),
                    value: offset
                )
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
            .frame(width: 24, height: 24)
            .aspectRatio(contentMode: .fit)
    }
}
