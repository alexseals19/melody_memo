//
//  RecordingsListView.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import SwiftUI

struct RecordingsListView: View {
    
    // MARK: - API

    init(audioManager: AudioManager) {
        _viewModel = StateObject(
            wrappedValue: RecordingsListViewModel(
                audioManager: audioManager
            )
        )
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: RecordingsListViewModel
    
    // MARK: - Body
    
    var body: some View {
        if viewModel.recordings.isEmpty {
            Spacer()
            Text("Create your first recording!")
            Spacer()
        } else {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.recordings) { recording in
                        RecordingCell(
                            currentlyPlaying: $viewModel.currentlyPlaying,
                            removeRecording: $viewModel.removeRecording,
                            recording: recording
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    RecordingsListView(
        audioManager: DefaultAudioManager.shared
    )
}
