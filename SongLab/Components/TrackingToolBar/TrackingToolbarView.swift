//
//  TrackingToolbarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct TrackingToolbarView: View {
    
    //MARK: - API
    @Binding var isSettingsPresented: Bool
    @Binding var isRecording: Bool
    
    init(
        audioManager: AudioManager,
        isRecording: Binding<Bool>,
        isSettingsPresented: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: TrackingToolbarViewModel(audioManager: audioManager))
        _isRecording = isRecording
        _isSettingsPresented = isSettingsPresented
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @StateObject private var viewModel: TrackingToolbarViewModel
        
    //MARK: - Body
    
    var body: some View {
        HStack {
            MetronomeView()
                .padding(.leading)
            RecordButtonView(isRecording: $isRecording)
                .padding(.horizontal, 25)
            appSettingsButton
                .padding(.trailing)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(.ultraThinMaterial.opacity(appTheme.toolbarMaterialOpacity))
                    .frame(height: 90)
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(Color(UIColor.systemBackground).opacity(0.5))
                    .frame(height: 90)
            }
                
        )
        .animation(.spring, value: isRecording)
        .offset(y: -20)
        .padding(.top, 25)
    }
    
    var appSettingsButton: some View {
        Button {
            isSettingsPresented.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .foregroundStyle(.primary)
        
    }
    
}

#Preview {
    TrackingToolbarView(
        audioManager: MockAudioManager(), 
        isRecording: .constant(false),
        isSettingsPresented: .constant(false)
        )
}
