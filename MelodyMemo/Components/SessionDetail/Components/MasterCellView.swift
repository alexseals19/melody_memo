//
//  MasterCellView.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI

struct MasterCellView: View {
    
    //MARK: - API
    
    init(session: Session, 
         currentlyPlaying: Session?,
         useGlobalBpm: Binding<Bool>,
         sessionBpm: Binding<Int>,
         playheadPosition: Double,
         playButtonAction: @escaping (_: Session) -> Void,
         pauseButtonAction: @escaping () -> Void,
         stopButtonAction: @escaping () -> Void,
         globalSoloButtonAction: @escaping () -> Void,
         restartButtonAction: @escaping () -> Void,
         setBpmButtonAction: @escaping (_: Int) -> Void
    ) {
        self.session = session
        self.currentlyPlaying = currentlyPlaying
        _isUsingGlobalBpm = useGlobalBpm
        _sessionBpm = sessionBpm
        self.playheadPosition = playheadPosition
        self.playButtonAction = playButtonAction
        self.pauseButtonAction = pauseButtonAction
        self.stopButtonAction = stopButtonAction
        self.globalSoloButtonAction = globalSoloButtonAction
        self.restartButtonAction = restartButtonAction
        self.setBpmButtonAction = setBpmButtonAction
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @Binding private var isUsingGlobalBpm: Bool
    @Binding private var sessionBpm: Int
    
    @State private var isEditingBpm: Bool = false
    @State private var bpm: Int = 120
    
    private var session: Session
    private var currentlyPlaying: Session?
    private var playheadPosition: Double
    
    private var bpmSectionOpacity: Double {
        isUsingGlobalBpm ? 0.3 : 1.0
    }
        
    private let playButtonAction: (_ session: Session) -> Void
    private let pauseButtonAction: () -> Void
    private let stopButtonAction: () -> Void
    private let globalSoloButtonAction: () -> Void
    private let restartButtonAction: () -> Void
    private let setBpmButtonAction: (_ newBpm: Int) -> Void
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                Divider()
                HStack() {
                    Spacer()
                    VStack {
                        HStack {
                            Button {
                                if sessionBpm > 0 {
                                    sessionBpm -= 1
                                }
                            } label: {
                                AppButtonLabelView(name: "minus", color: .primary)
                            }
                            .buttonRepeatBehavior(.enabled)
                            Text("BPM")
                                .frame(width: 40)
                            Text("\(sessionBpm == 0 ? "--" : "\(sessionBpm)")")
                                .frame(width: 33)
                                .foregroundStyle(.secondary)
                            Button {
                                if sessionBpm < 300 {
                                    sessionBpm += 1
                                }
                            } label: {
                                AppButtonLabelView(name: "plus", color: .primary)
                            }
                            .buttonRepeatBehavior(.enabled)
                        }
                        .opacity(bpmSectionOpacity)
                        useGlobalBpmButtonView
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: 1, height: 65)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                        .padding(.horizontal, 5)
                    Spacer()
                    HStack(spacing: 20) {
                        Button {
                            globalSoloButtonAction()
                        } label: {
                            if session.isGlobalSoloActive {
                                Image(systemName: "s.square.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.purple)
                            } else {
                                Image(systemName: "s.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        Button {
                            stopButtonAction()
                        } label: {
                            if playheadPosition != 0.0, currentlyPlaying == nil {
                                AppButtonLabelView(name: "backward.end", color: .primary)
                            } else {
                                AppButtonLabelView(name: "stop", color: currentlyPlaying != nil ? .red : .primary)
                            }
                        }
                        PlaybackControlButtonView(
                            session: session,
                            currentlyPlaying: currentlyPlaying,
                            playButtonAction: playButtonAction,
                            pauseButtonAction: pauseButtonAction
                        )
                    }
                    Spacer()
                }
                Divider()
            }
            .padding(.vertical, 10)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground).opacity(0.3))
        }
    }
    
    var useGlobalBpmButtonView: some View {
        
        Button {
            isUsingGlobalBpm.toggle()
        } label: {
            ZStack {
                if isUsingGlobalBpm {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 75, height: 15)
                        .foregroundStyle(appTheme.accentColor)
                    Text("Use Global")
                        .font(.caption)
                        .foregroundStyle(.black)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1.0)
                        .frame(width: 75, height: 15)
                        .foregroundStyle(appTheme.accentColor)
                    Text("Use Global")
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

#Preview {
    MasterCellView(
        session: Session.sessionFixture,
        currentlyPlaying: nil,
        useGlobalBpm: .constant(false),
        sessionBpm: .constant(120),
        playheadPosition: 0.0,
        playButtonAction: { _ in },
        pauseButtonAction: {},
        stopButtonAction: {},
        globalSoloButtonAction: {},
        restartButtonAction: {},
        setBpmButtonAction: { _ in }
    )
}
