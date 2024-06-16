//
//  RecordingCard.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

enum theme: Double {
    case glassy = 0.8
    case superGlassy = 0.51
    case opaque = 0.5
}

struct RecordingCell: View {
    
    // MARK: - API
    
    @Binding var appTheme: String
    
    init(
        currentlyPlaying: Session?,
        session: Session,
        appTheme: Binding<String>,
        playButtonAction: @escaping (_: Session) -> Void,
        stopButtonAction: @escaping () -> Void,
        trashButtonAction: @escaping (_: Session) -> Void
    ) {
        self.currentlyPlaying = currentlyPlaying
        self.session = session
        _appTheme = appTheme
        self.playButtonAction = playButtonAction
        self.stopButtonAction = stopButtonAction
        self.trashButtonAction = trashButtonAction
    }
    
    // MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var session: Session
    private var currentlyPlaying: Session?
    
    private let playButtonAction: (_ session: Session) -> Void
    private let stopButtonAction: () -> Void
    private let trashButtonAction: (_ session: Session) -> Void
    
    private var cellOpacity: Double {
        colorScheme == .dark ? 0.6 : 1.0
    }
    
    private var cellColor: Color {
        switch appTheme {
        case "glass":
            return Color.black.opacity(0.8)
        case "superglass":
            return Color.black.opacity(0.5)
        case "opaque":
            return Color.black.opacity(0.5)
        case "light":
            return Color.white.opacity(0.5)
        default:
            return Color.black.opacity(0.5)
        }
    }
    
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    
    @GestureState private var gestureOffset: CGFloat = 0.0
    @State private var offset: CGFloat = 0.0
    @State private var isLinkDisabled: Bool = false
    @State private var twoWayDrag: Bool = false
    
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
                            Text(session.name)
                                .font(.title2)
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                                .padding(.bottom, 3)
                            HStack() {
                                Text(session.lengthDisplayString)
                                    .font(.caption2)
                                Text(session.dateDisplayString)
                                    .font(.caption2)
                            }
                        }
                        .padding(EdgeInsets(top: 8, leading: 10, bottom: 11, trailing: 0))
                        Spacer()
                    }
                    .padding(.trailing, 80)
                    .background(
                        cellColor
                    )
                    .gesture(drag)
                    .onDisappear { 
                        offset = .zero
                        twoWayDrag = false
                    }
                }
                
                HStack {
                    Spacer()
                    playbackButton
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
    
    var playbackButton: some View {
        Button {
            if let currentlyPlaying, currentlyPlaying == session {
                stopButtonAction()
            } else {
                playButtonAction(session)
            }
        } label: {
            Group {
                if let currentlyPlaying, currentlyPlaying == session {
                    Image(systemName: "pause")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 24, height: 24)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 20))
            
        }
        .foregroundStyle(Gradient(colors: [.pink, .purple]))
    }
}

#Preview {
    
    RecordingCell(
        currentlyPlaying: nil,
        session: Session.recordingFixture,
        appTheme: .constant("glass"),
        playButtonAction: { _ in },
        stopButtonAction: {},
        trashButtonAction: { _ in }
    )
    .padding(.horizontal)
}
