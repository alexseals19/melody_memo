//
//  SessionCellView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct SessionCellView: View {
    
    // MARK: - API
        
    init(
        currentlyPlaying: Session?,
        session: Session,
        playerProgress: Double,
        playButtonAction: @escaping (_: Session) -> Void,
        stopButtonAction: @escaping () -> Void,
        trashButtonAction: @escaping (_: Session) -> Void
    ) {
        self.currentlyPlaying = currentlyPlaying
        self.session = session
        self.playerProgress = playerProgress
        self.playButtonAction = playButtonAction
        self.stopButtonAction = stopButtonAction
        self.trashButtonAction = trashButtonAction
    }
    
    // MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    private var session: Session
    private var currentlyPlaying: Session?
    private var playerProgress: Double
    
    private let playButtonAction: (_ session: Session) -> Void
    private let stopButtonAction: () -> Void
    private let trashButtonAction: (_ session: Session) -> Void
    
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    
    @GestureState private var gestureOffset: CGFloat = 0.0
    @State private var offset: CGFloat = 0.0
    @State private var isLinkDisabled: Bool = false
    @State private var twoWayDrag: Bool = false
    
    @State private var progressViewWidth: CGFloat = 0.0
    
    private var opacity: Double {
        if let currentlyPlaying, currentlyPlaying == session {
            return 1.0
        }
        return 0.0
    }
    
    private var trashButtonWidth: Double {
        if gestureOffset != 0 {
            return (gestureOffset + offset) * -1.0
        } else {
            return offset * -1.0
        }
        
    }
    private var trashButtonOpacity: Double {
        if gestureOffset != 0 {
            return gestureOffset / -70.0
        } else {
            return offset / -70.0
        }
    }
    private var heavyHapticOccured: Bool {
        if gestureOffset + offset < -130 {
            return true
        } else {
            return false
        }
    }
    private var softHapticOccured: Bool {
        if gestureOffset + offset <= -70 {
            return true
        } else {
            return false
        }
    }
    
    private var animationDuration: Double {
        if gestureOffset != 0 {
            return 0.0
        } else {
            return 0.5
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        
        let drag = DragGesture()
            .updating($gestureOffset) { currentState, gestureState, transaction in
                let delta = currentState.location.x - currentState.startLocation.x
                if delta < 0, delta > -200, !twoWayDrag {
                    gestureState = delta
                } else if twoWayDrag, delta < 70 {
                    gestureState = delta
                }
                if gestureState + offset < -130, !heavyHapticOccured {
                    heavyImpact.impactOccurred()
                } else if gestureState + offset <= -70, !softHapticOccured {
                    softImpact.impactOccurred()
                }
            }
            
            .onEnded() { gestureState in
                if gestureState.translation.width + offset < -130 {
                    offset = -1000
                    trashButtonAction(session)
                } else if gestureState.translation.width + offset < -70 {
                    twoWayDrag = true
                    offset = -70
                    isLinkDisabled = true
                } else {
                    offset = .zero
                    twoWayDrag = false
                    isLinkDisabled = false
                }
            }
        
        ZStack {
            HStack {
                Spacer()
                trashButton
            }
            ZStack {
                NavigationLink(value: session) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(session.name)
                                    .font(.title2)
                                    .minimumScaleFactor(0.75)
                                    .lineLimit(1)
                                    .padding(.bottom, 1)
                                if let currentlyPlaying, currentlyPlaying == session {
                                    ProgressView(value: min(playerProgress / session.length, 1.0))
                                        .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                                        .transition(.scale(0.0, anchor: .trailing).animation(.linear(duration: 0.2)))
                                }
                            }
                            Capsule()
                                .frame(maxWidth: .infinity, maxHeight: 1)
                                .foregroundStyle(appTheme.accentColor)
                            HStack() {
                                Text(session.lengthDisplayString)
                                    .font(.caption2)
                                Text(session.dateDisplayString)
                                    .font(.caption2)
                                
                            }
                            .foregroundStyle(.secondary)
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 13, trailing: 0))
                        Spacer()
                        
                    }
                    .padding(.trailing, 80)
                    .foregroundStyle(.primary)
                    .background(Color(UIColor.systemBackground).opacity(0.3))
                    .gesture(drag)
                    .onDisappear {
                        offset = .zero
                        twoWayDrag = false
                    }
                }
                HStack {
                    Spacer()
                    PlaybackControlButtonView(
                        session: session,
                        currentlyPlaying: currentlyPlaying,
                        playButtonAction: playButtonAction,
                        pauseButtonAction: stopButtonAction
                    )
                    .padding(.trailing, 20)
                }
            }
            .offset(x: gestureOffset + offset)
            .animation(.snappy(duration: animationDuration), value: gestureOffset)
        }
        .foregroundStyle(.primary)
    }
    
    var trashButton: some View {
        HStack {
            Spacer()
            Button {
                trashButtonAction(session)
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
                    .opacity(trashButtonOpacity)
                    .animation(.spring, value: trashButtonOpacity)
            }
            Spacer()
        }
        .frame(width: trashButtonWidth)
        .frame(maxHeight: .infinity)
        .background(Color.red.opacity(0.5))
        .clipped()
        .animation(.snappy(duration: animationDuration), value: trashButtonWidth)
    }
}

#Preview {
    SessionCellView(
        currentlyPlaying: nil,
        session: Session.sessionFixture,
        playerProgress: 0.0,
        playButtonAction: {_ in },
        stopButtonAction: {},
        trashButtonAction: { _ in }
    )
}
