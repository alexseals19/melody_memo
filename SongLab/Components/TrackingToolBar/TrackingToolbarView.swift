//
//  TrackingToolbarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct TrackingToolbarView: View {
    
    //MARK: - API
    
    @Binding var isRecording: Bool
    
    init(audioManager: AudioManager, isRecording: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: TrackingToolbarViewModel(audioManager: audioManager))
        _isRecording = isRecording
    }
    
    //MARK: - Variables
    
    @StateObject private var viewModel: TrackingToolbarViewModel
    
    //MARK: - Body
    
    var body: some View {
        HStack {
            MetronomeView()
                .padding(.leading)
            Spacer()
            RecordButtonView(isRecording: $isRecording)
            Spacer()
            TrackingSettingsView()
                .padding(.trailing)
        }
        .padding(.bottom, 5)
        .padding(.top, 25)
    }
}

#Preview {
    TrackingToolbarView(audioManager: MockAudioManager(), isRecording: .constant(false))
}
