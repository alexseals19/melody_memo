//
//  MasterCell.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI

struct MasterCell: View {
    
    //MARK: - API
    
    init(session: Session, 
         currentlyPlaying: Session?,
         playButtonAction: @escaping (_: Session) -> Void,
         stopButtonAction: @escaping () -> Void,
         globalSoloButtonAction: @escaping () -> Void
    ) {
        self.session = session
        self.currentlyPlaying = currentlyPlaying
        self.playButtonAction = playButtonAction
        self.stopButtonAction = stopButtonAction
        self.globalSoloButtonAction = globalSoloButtonAction
    }
    
    //MARK: - Variables
    
    private var session: Session
    private var currentlyPlaying: Session?
        
    private let playButtonAction: (_ session: Session) -> Void
    private let stopButtonAction: () -> Void
    private let globalSoloButtonAction: () -> Void
    
    //MARK: - Body
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    HStack() {
                        VStack {
                            Text("Master")
                                .font(.title2)
                            Button {
                                globalSoloButtonAction()
                            } label: {
                                if session.isGlobalSoloActive {
                                    Image(systemName: "s.square.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                } else {
                                    Image(systemName: "s.square")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                        Spacer()
                        PlaybackControlButtonView(
                            session: session,
                            currentlyPlaying: currentlyPlaying,
                            playButtonAction: playButtonAction,
                            stopButtonAction: stopButtonAction
                        )
                    }
                }
                Spacer()
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    MasterCell(
        session: Session.recordingFixture,
        currentlyPlaying: nil,
        playButtonAction: { _ in },
        stopButtonAction: {},
        globalSoloButtonAction: {}
    )
}
