//
//  TrackingToolbarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct TrackingToolbarView: View {
    
    //MARK: - API
    
    init(recordingManager: RecordingManager) {
        _viewModel = StateObject(wrappedValue: TrackingToolbarViewModel(recordingManager: recordingManager))
    }
    
    //MARK: - Variables
    
    @StateObject private var viewModel: TrackingToolbarViewModel
    
    //MARK: - Body
    
    var body: some View {
        HStack {
            MetronomeView()
                .padding(.leading)
            Spacer()
            RecordButtonView(isRecording: $viewModel.isRecording)
            Spacer()
            TrackingSettingsView()
                .padding(.trailing)
        }
    }
}

#Preview {
    TrackingToolbarView(recordingManager: MockRecordingManager())
}
