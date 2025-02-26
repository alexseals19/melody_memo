//
//  SessionCellView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct SessionCellView: View {
    
    // MARK: - API
    
    @Binding var nameChangeText: String
    @Binding var isEditingSession: Session?
        
    init(
        currentlyPlaying: SessionGroup?,
        session: Session,
        playerProgress: Double,
        nameChangeText: Binding<String>,
        isEditingSession: Binding<Session?>,
        playButtonAction: @escaping (_: SessionGroup) -> Void,
        stopButtonAction: @escaping () -> Void,
        trashButtonAction: @escaping (_: Session) -> Void,
        sessionNameDidChange: @escaping (_: Session, _: String) -> Void
    ) {
        self.currentlyPlaying = currentlyPlaying
        self.session = session
        self.playerProgress = playerProgress
        self.playButtonAction = playButtonAction
        self.stopButtonAction = stopButtonAction
        self.trashButtonAction = trashButtonAction
        self.sessionNameDidChange = sessionNameDidChange
        
        _nameChangeText = nameChangeText
        _isEditingSession = isEditingSession
    }
    
    // MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    private var session: Session
    private var currentlyPlaying: SessionGroup?
    private var playerProgress: Double
    
    private let playButtonAction: (_ group: SessionGroup) -> Void
    private let stopButtonAction: () -> Void
    private let trashButtonAction: (_ session: Session) -> Void
    private let sessionNameDidChange: (_: Session, _: String) -> Void
    
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    
    @GestureState private var gestureOffset: CGFloat = 0.0
    @State private var offset: CGFloat = 0.0
    @State private var isLinkDisabled: Bool = false
    @State private var twoWayDrag: Bool = false
    
    @State private var progressViewWidth: CGFloat = 0.0
    
    @FocusState private var isTextFieldFocused: Bool
    
    
    private var opacity: Double {
        if let currentlyPlaying, currentlyPlaying == session.armedGroup {
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
                                if isEditingSession == session {
                                    TextField("\(session.name)", text: $nameChangeText)
                                        .focused($isTextFieldFocused)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            if !nameChangeText.isEmpty {
                                                sessionNameDidChange(session, nameChangeText)
                                            }
                                            isEditingSession = nil
                                        }
                                    Spacer()
                                    
                                } else {
                                    Text(session.name)
                                        .font(.title2)
                                        .minimumScaleFactor(0.9)
                                        .lineLimit(1)
                                        .padding(.bottom, 1)
                                    Menu {
                                        Button("Change Name") {
                                            isEditingSession = session
                                            isTextFieldFocused = true
                                        }
                                        Button("Delete", role: .destructive) {
                                            trashButtonAction(session)
                                        }
                                    } label: {
                                        AppButtonLabelView(name: "ellipsis", color: .primary)
                                    }
                                }
                                
                                
                                if let currentlyPlaying, currentlyPlaying.sessionId == session.id {
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
                    .background(.clear)
                    .gesture(drag)
                    .onDisappear {
                        offset = .zero
                        twoWayDrag = false
                    }
                }
                HStack {
                    Spacer()
                    PlaybackControlButtonView(
                        group: session.armedGroup,
                        currentlyPlaying: currentlyPlaying,
                        playButtonTapped: playButtonAction,
                        pauseButtonTapped: stopButtonAction
                    )
                    .padding(.trailing, 20)
                }
            }
            .offset(x: gestureOffset + offset)
            .animation(.snappy(duration: animationDuration), value: gestureOffset)
            
            if let isEditingSession, isEditingSession != session {
                Color.gray.opacity(0.001)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        self.isEditingSession = nil
                        nameChangeText = ""
                    }
            }
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
        nameChangeText: .constant(""),
        isEditingSession: .constant(nil),
        playButtonAction: {_ in },
        stopButtonAction: {},
        trashButtonAction: { _ in },
        sessionNameDidChange: { _, _ in }
    )
}
