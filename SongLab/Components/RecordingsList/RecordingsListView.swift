//
//  RecordingsListView.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import SwiftUI

struct RecordingsListView: View {
    
    // MARK: - API

    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        _viewModel = StateObject(
            wrappedValue: RecordingsListViewModel(
                audioManager: audioManager,
                recordingManager: recordingManager
            )
        )
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: RecordingsListViewModel
    
    // MARK: - Body
    
    var body: some View {
        if viewModel.sessions.isEmpty {
            Spacer()
            Text("Create your first recording!")
            Spacer()
        } else {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.sessions) { session in
                        RecordingCell(
                            currentlyPlaying: $viewModel.currentlyPlaying,
                            audioIsPlaying: viewModel.audioIsPlaying,
                            session: session,
                            trashButtonAction: viewModel.trashButtonAction
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    RecordingsListView(
        audioManager: MockAudioManager(),
        recordingManager: MockRecordingManager()
    )
}
