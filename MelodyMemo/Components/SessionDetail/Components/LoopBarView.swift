//
//  LoopBarView.swift
//  MelodyMemo
//
//  Created by Alex Seals on 8/14/24.
//

import SwiftUI

struct LoopBarView: View {
    
    //MARK: - API
    
    init(
        leftIndicatorFraction: Double,
        rightIndicatorFraction: Double,
        leftIndicatorDragOffset: Binding<CGFloat>,
        rightIndicatorDragOffset: Binding<CGFloat>,
        isLoopActive: Bool,
        sessionTracks: [UUID: Track],
        loopReferenceTrack: Binding<Track>,
        leftIndicatorPositionDidChange: @escaping (_: Double) -> Void,
        rightIndicatorPositionDidChange: @escaping (_: Double) -> Void,
        loopToggleButtonAction: @escaping () -> Void
    ){
        self.leftIndicatorFraction = leftIndicatorFraction
        self.rightIndicatorFraction = rightIndicatorFraction
        _leftIndicatorDragOffset = leftIndicatorDragOffset
        _rightIndicatorDragOffset = rightIndicatorDragOffset
        self.isLoopActive = isLoopActive
        self.sessionTracks = sessionTracks
        _loopReferenceTrack = loopReferenceTrack
        self.leftIndicatorPositionDidChange = leftIndicatorPositionDidChange
        self.rightIndicatorPositionDidChange = rightIndicatorPositionDidChange
        self.loopToggleButtonAction = loopToggleButtonAction
        
    }
    
    @Binding var loopReferenceTrack: Track
    
    @Binding var rightIndicatorDragOffset: CGFloat
    @Binding var leftIndicatorDragOffset: CGFloat
    
    //MARK: - Variables
    
    @State private var waveformWidth = 130.0
    @State private var selectedReferenceTrack: Track?
    
    @EnvironmentObject private var appTheme: AppTheme
    
    private var leftIndicatorFraction: Double
    private var rightIndicatorFraction: Double
    private let isLoopActive: Bool
    private let sessionTracks: [UUID: Track]
    
    private var leftIndicatorBound: Double {
        waveformWidth / -2.0
    }
    
    private var rightIndicatorBound: Double {
        waveformWidth / 2.0
    }
    
    private var leftIndicatorPosition: Double {
        leftIndicatorFraction * waveformWidth + leftIndicatorBound
    }
    
    private var rightIndicatorPosition: Double {
        rightIndicatorFraction * waveformWidth + leftIndicatorBound
    }
    
    private var loopWidth: Double {
        let rightPosition = rightIndicatorPosition + rightIndicatorDragOffset
        let leftPosition = leftIndicatorPosition + leftIndicatorDragOffset
        return rightPosition - leftPosition
    }
    
    private var loopPosisition: Double {
        let rightPosition = rightIndicatorPosition + rightIndicatorDragOffset
        let leftPosition = leftIndicatorPosition + leftIndicatorDragOffset
        return rightPosition + leftPosition
    }
    
    private var sortedSessionTracks: [Track] {
        Array(sessionTracks.values).sorted { (lhs: Track, rhs: Track) -> Bool in
            return rhs.name > lhs.name
        }
    }
    
    private let leftIndicatorPositionDidChange: (_: Double) -> Void
    private let rightIndicatorPositionDidChange: (_: Double) -> Void
    private let loopToggleButtonAction: () -> Void
    
    //MARK: - Body
        
    var body: some View {
        
        let leftIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                var delta = gesture.translation.width
                
                if leftIndicatorPosition + delta < leftIndicatorBound {
                    delta = leftIndicatorBound - leftIndicatorPosition
                } else if leftIndicatorPosition + delta > rightIndicatorPosition - 3 {
                    delta = (rightIndicatorPosition - 3) - leftIndicatorPosition
                }
                leftIndicatorDragOffset = delta
            }
            .onEnded { gesture in
                let delta = gesture.translation.width
                
                if leftIndicatorPosition + delta < leftIndicatorBound {
                    leftIndicatorPositionDidChange(0.0)
                } else if leftIndicatorPosition + delta > rightIndicatorPosition - 3 {
                    let newPosition = rightIndicatorPosition - 3
                    leftIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth)
                } else {
                    let newPosition = leftIndicatorPosition + delta
                    leftIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth)
                }
            }
        
        let rightIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                
                var delta = gesture.translation.width
                if rightIndicatorPosition + delta > rightIndicatorBound {
                    delta = rightIndicatorBound - rightIndicatorPosition
                } else if rightIndicatorPosition + delta < leftIndicatorPosition + 3 {
                    delta = (leftIndicatorPosition + 3) - rightIndicatorPosition
                }
                rightIndicatorDragOffset = delta
                
            }
            .onEnded { gesture in
                let delta = gesture.translation.width
                if rightIndicatorPosition + delta > rightIndicatorBound {
                    rightIndicatorPositionDidChange(1.0)
                } else if rightIndicatorPosition + delta < leftIndicatorPosition + 3 {
                    let newPosition = leftIndicatorPosition + 3
                    rightIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth)
                } else {
                    let newPosition = rightIndicatorPosition + delta
                    rightIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth)
                }
            }
        
        HStack(spacing: 0.0) {
            Button {
                loopToggleButtonAction()
            } label: {
                AppButtonLabelView(name: "repeat", color: isLoopActive ? .yellow : .primary)
            }
            .frame(width: 110)
            GeometryReader { proxy in
                ZStack {
                    Rectangle()
                        .frame(width: loopWidth, height: 28)
                        .foregroundStyle(.gray.opacity(0.1))
                        .offset(x: loopWidth / 2 + leftIndicatorPosition + leftIndicatorDragOffset)
                    ZStack() {
                        Rectangle()
                            .frame(width: 25, height: 28)
                            .foregroundStyle(.gray.opacity(0.001))
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 2, height: 28)
                            .foregroundStyle(appTheme.accentColor)
                    }
                    .offset(x: leftIndicatorPosition + leftIndicatorDragOffset)
                    .gesture(leftIndicatorDrag)
                    ZStack() {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 2, height: 28)
                            .foregroundStyle(appTheme.accentColor)
                        Rectangle()
                            .frame(width: 25, height: 28)
                            .foregroundStyle(.gray.opacity(0.001))
                        
                    }
                    .offset(x: rightIndicatorPosition + rightIndicatorDragOffset)
                    .gesture(rightIndicatorDrag)
                    
                }
                .onAppear {
                    waveformWidth = proxy.size.width
                }
                .frame(width: waveformWidth)
                .onTapGesture(count: 2) {
                    rightIndicatorPositionDidChange(1.0)
                    leftIndicatorPositionDidChange(0.0)
                }
                
            }
            Menu {
                ForEach(sortedSessionTracks) { track in
                    Button(track.name, action: { loopReferenceTrack = track })
                }
            } label: {
                VStack(spacing: 0.5) {
                    Text(loopReferenceTrack.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    AppButtonLabelView(name: "chevron.compact.down", color: .secondary, size: 12)
                }
            }
            .foregroundStyle(.secondary)
            .frame(width: 100)
        }
        .opacity(isLoopActive ? 1.0 : 0.4)
        .frame(height: 28)
        .background(Color(UIColor.systemBackground).opacity(0.3))
    }
}

#Preview {
    LoopBarView(
        leftIndicatorFraction: 0.0,
        rightIndicatorFraction: 0.0,
        leftIndicatorDragOffset: .constant(0.0),
        rightIndicatorDragOffset: .constant(0.0),
        isLoopActive: false,
        sessionTracks: Session.sessionFixture.tracks,
        loopReferenceTrack: .constant(Session.trackFixture),
        leftIndicatorPositionDidChange: { _ in },
        rightIndicatorPositionDidChange: { _ in },
        loopToggleButtonAction: {}
    )
}
