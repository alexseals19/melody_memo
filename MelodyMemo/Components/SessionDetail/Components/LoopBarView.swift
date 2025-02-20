//
//  LoopBarView.swift
//  MelodyMemo
//
//  Created by Alex Seals on 8/14/24.
//

import SwiftUI

struct LoopBarView: View {
    
    //MARK: - API
    
    @Binding var leftIndicatorDragOffset: CGFloat
    @Binding var rightIndicatorDragOffset: CGFloat
    @Binding var isAdjustingGroupIndicators: SessionGroup?
    
    init(
        group: SessionGroup,
        leftIndicatorFraction: Double,
        rightIndicatorFraction: Double,
        leftIndicatorDragOffset: Binding<CGFloat>,
        rightIndicatorDragOffset: Binding<CGFloat>,
        isAdjustingGroupIndicators: Binding<SessionGroup?>,
        isLoopActive: Bool,
        sessionTracks: [UUID: Track],
        loopReferenceTrack: Track?,
        leftIndicatorPositionDidChange: @escaping (_: Double, _: SessionGroup) -> Void,
        rightIndicatorPositionDidChange: @escaping (_: Double, _: SessionGroup) -> Void,
        loopToggleButtonAction: @escaping (_: SessionGroup) -> Void,
        loopReferenceTrackDidChange: @escaping (_: Track, _: SessionGroup) -> Void
    ){
        self.group = group
        self.leftIndicatorFraction = leftIndicatorFraction
        self.rightIndicatorFraction = rightIndicatorFraction
        self.isLoopActive = isLoopActive
        self.sessionTracks = sessionTracks
        self.loopReferenceTrack = loopReferenceTrack
        self.leftIndicatorPositionDidChange = leftIndicatorPositionDidChange
        self.rightIndicatorPositionDidChange = rightIndicatorPositionDidChange
        self.loopToggleButtonAction = loopToggleButtonAction
        self.loopReferenceTrackDidChange = loopReferenceTrackDidChange
        
        _leftIndicatorDragOffset = leftIndicatorDragOffset
        _rightIndicatorDragOffset = rightIndicatorDragOffset
        _isAdjustingGroupIndicators = isAdjustingGroupIndicators
    }
    
    var loopReferenceTrack: Track?
    
    //MARK: - Variables
    
    @State private var waveformWidth = 130.0
    @State private var selectedReferenceTrack: Track?
    
    @EnvironmentObject private var appTheme: AppTheme
    
    private var leftIndicatorFraction: Double
    private var rightIndicatorFraction: Double
    private let isLoopActive: Bool
    private let sessionTracks: [UUID: Track]
    private let group: SessionGroup
    
    private var loopReferenceDisplayName: String {
        if let loopReferenceTrack {
            return loopReferenceTrack.name
        }
        return "Select"
    }
    
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
        let rightPosition = rightIndicatorPosition + (isAdjustingGroupIndicators == group ? rightIndicatorDragOffset : 0)
        let leftPosition = leftIndicatorPosition + (isAdjustingGroupIndicators == group ? leftIndicatorDragOffset : 0)
        return rightPosition - leftPosition
    }
    
    private var loopPosisition: Double {
        let rightPosition = rightIndicatorPosition + rightIndicatorDragOffset
        let leftPosition = leftIndicatorPosition + leftIndicatorDragOffset
        return rightPosition + leftPosition
    }
    
    private var sortedSessionTracks: [Track] {
        Array(group.tracks.values).sorted { (lhs: Track, rhs: Track) -> Bool in
            return rhs.name > lhs.name
        }
    }
    
    private let leftIndicatorPositionDidChange: (_: Double, _: SessionGroup) -> Void
    private let rightIndicatorPositionDidChange: (_: Double, _: SessionGroup) -> Void
    private let loopToggleButtonAction: (_: SessionGroup) -> Void
    private let loopReferenceTrackDidChange: (_: Track, _: SessionGroup) -> Void
    
    //MARK: - Body
        
    var body: some View {
        
        let leftIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                
                isAdjustingGroupIndicators = group
                
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
                
                leftIndicatorDragOffset = 0.0
                
                if leftIndicatorPosition + delta < leftIndicatorBound {
                    leftIndicatorPositionDidChange(0.0, group)
                } else if leftIndicatorPosition + delta > rightIndicatorPosition - 3 {
                    let newPosition = rightIndicatorPosition - 3
                    leftIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth, group)
                } else {
                    let newPosition = leftIndicatorPosition + delta
                    leftIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth, group)
                }
                
                isAdjustingGroupIndicators = nil
            }
        
        let rightIndicatorDrag = DragGesture(minimumDistance: 1)
            .onChanged() { gesture in
                
                isAdjustingGroupIndicators = group
                
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
                
                rightIndicatorDragOffset = 0.0
                
                if rightIndicatorPosition + delta > rightIndicatorBound {
                    rightIndicatorPositionDidChange(1.0, group)
                } else if rightIndicatorPosition + delta < leftIndicatorPosition + 3 {
                    let newPosition = leftIndicatorPosition + 3
                    rightIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth, group)
                } else {
                    let newPosition = rightIndicatorPosition + delta
                    rightIndicatorPositionDidChange((newPosition - leftIndicatorBound) / waveformWidth, group)
                }
                isAdjustingGroupIndicators = nil
            }
        
        HStack(spacing: 0.0) {
            Button {
                loopToggleButtonAction(group)
            } label: {
                AppButtonLabelView(name: "repeat", color: isLoopActive ? .yellow : .primary)
            }
            .frame(width: 110)
            GeometryReader { proxy in
                ZStack {
                    Rectangle()
                        .frame(width: loopWidth, height: 28)
                        .foregroundStyle(.gray.opacity(0.1))
                        .offset(x: loopWidth / 2 + leftIndicatorPosition + (isAdjustingGroupIndicators == group ? leftIndicatorDragOffset : 0))
                    ZStack() {
                        Rectangle()
                            .frame(width: 25, height: 28)
                            .foregroundStyle(.gray.opacity(0.001))
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 2, height: 28)
                            .foregroundStyle(appTheme.accentColor)
                    }
                    .offset(x: leftIndicatorPosition + (isAdjustingGroupIndicators == group ? leftIndicatorDragOffset : 0))
                    .gesture(leftIndicatorDrag)
                    ZStack() {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 2, height: 28)
                            .foregroundStyle(appTheme.accentColor)
                        Rectangle()
                            .frame(width: 25, height: 28)
                            .foregroundStyle(.gray.opacity(0.001))
                        
                    }
                    .offset(x: rightIndicatorPosition + (isAdjustingGroupIndicators == group ? rightIndicatorDragOffset : 0))
                    .gesture(rightIndicatorDrag)
                    
                }
                .onAppear {
                    waveformWidth = proxy.size.width
                }
                .frame(width: waveformWidth)
                .onTapGesture(count: 2) {
                    rightIndicatorPositionDidChange(1.0, group)
                    leftIndicatorPositionDidChange(0.0, group)
                }
                
            }
            Menu {
                ForEach(sortedSessionTracks) { track in
                    Button(track.name, action: { loopReferenceTrackDidChange(track, group) } )
                }
            } label: {
                VStack(spacing: 0.5) {
                    Text(loopReferenceDisplayName)
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
    }
}

//#Preview {
//    LoopBarView(
//        leftIndicatorFraction: 0.0,
//        rightIndicatorFraction: 0.0,
//        leftIndicatorDragOffset: .constant(0.0),
//        rightIndicatorDragOffset: .constant(0.0),
//        isLoopActive: false,
//        sessionTracks: Session.sessionFixture.tracks,
//        loopReferenceTrack: .constant(Session.trackFixture),
//        leftIndicatorPositionDidChange: { _ in },
//        rightIndicatorPositionDidChange: { _ in },
//        loopToggleButtonAction: {}
//    )
//}
