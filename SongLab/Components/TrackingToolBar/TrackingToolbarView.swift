//
//  TrackingToolbarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct TrackingToolbarView: View {
    
    //MARK: - API
    
    init(audioManager: AudioManager) {
        _viewModel = StateObject(wrappedValue: TrackingToolbarViewModel(audioManager: audioManager))
    }
    
    //MARK: - Variables
    
    @StateObject private var viewModel: TrackingToolbarViewModel
    
    //MARK: - Body
    
    var body: some View {
        HStack {
            MetronomeView()
                .padding(.leading)
            Spacer()
            RecordButtonView(isRecording: viewModel.isRecording, recordButtonAction: viewModel.recordButtonAction)
            Spacer()
            TrackingSettingsView()
                .padding(.trailing)
        }
    }
}

#Preview {
    TrackingToolbarView(audioManager: MockAudioManager())
}
