//
//  TrackCell.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI

struct TrackCell: View {
    
    //MARK: - API
        
    init(
        track: Track,
        isGlobalSoloActive: Bool,
        muteButtonAction: @escaping (_: Track) -> Void,
        soloButtonAction: @escaping (_: Track) -> Void,
        onTrackVolumeChange: @escaping (_: Track, _ : Double) -> Void
    ) {
        self.track = track
        self.isGlobalSoloActive = isGlobalSoloActive
        self.muteButtonAction = muteButtonAction
        self.soloButtonAction = soloButtonAction
        self.onTrackVolumeChange = onTrackVolumeChange
        self.sliderValue = Double(track.volume)
    }
    
    //MARK: - Variables
    
    @State private var isShowingVolumeSlider: Bool = true
    @State private var sliderValue: Double
    
    private var track: Track
    private var isGlobalSoloActive: Bool
    
    private let muteButtonAction: (_: Track) -> Void
    private let soloButtonAction: (_: Track) -> Void
    private let onTrackVolumeChange: (_: Track, _ : Double) -> Void
    
    //MARK: - Body
        
    var body: some View {
        VStack {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    HStack() {
                        Text(track.name + " |")
                        Text(track.lengthDisplayString)
                            .font(.caption)
                    }
                }
                Spacer()
                HStack {
                    Button {
                        soloButtonAction(track)
                    } label: {
                        if track.isSolo, isGlobalSoloActive {
                            TrackCellButtonImage("s.square.fill")
                        } else {
                            TrackCellButtonImage("s.square")
                        }
                    }
                    
                    Button {
                        muteButtonAction(track)
                    } label: {
                        if track.isMuted {
                            TrackCellButtonImage("m.square.fill")
                        } else {
                            TrackCellButtonImage("m.square")
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 20)
            
            Slider(value: $sliderValue)
                .tint(.primary)
                .padding(.horizontal, 20)
                .onChange(of: sliderValue) {
                    onTrackVolumeChange(track, sliderValue)
                }
        }
        .foregroundColor(.primary)
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

#Preview {
    TrackCell(
        track: Track(
            name: "track 1",
            fileName: "",
            date: Date(),
            length: .seconds(2),
            id: UUID(),
            volume: 1.0,
            isMuted: false,
            isSolo: false
        ),
        isGlobalSoloActive: false,
        muteButtonAction: { _ in },
        soloButtonAction: { _ in },
        onTrackVolumeChange: { _ , _ in }
    )
}
