//
//  RecordingsListView.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import SwiftUI

struct RecordingsListView: View {
    
    // MARK: - API

    init(recordingManager: RecordingManager) {
        _viewModel = StateObject(wrappedValue: RecordingsListViewModel(recordingManager: recordingManager))
    }
    
    // MARK: - Variables
    
    @StateObject private var viewModel: RecordingsListViewModel
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.recordings) { recording in
                    RecordingCell(currentlyPlaying: $viewModel.currentlyPlaying, recording: recording)
                        .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    RecordingsListView(recordingManager: DefaultRecordingManager.shared)
}
