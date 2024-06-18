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
    
    init(audioManager: AudioManager, isRecording: Binding<Bool>, isSettingsPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: TrackingToolbarViewModel(audioManager: audioManager))
        _isRecording = isRecording
        _isSettingsPresented = isSettingsPresented
    }
    
    //MARK: - Variables
    
    @StateObject private var viewModel: TrackingToolbarViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
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
                    .foregroundStyle(.ultraThinMaterial.opacity(0.8))
                    .frame(height: 90)
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(Color.black.opacity(0.3))
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
    
    var color: some View {
        colorScheme == .dark ? Color.black : Color.clear
    }
}

#Preview {
    TrackingToolbarView(audioManager: MockAudioManager(), isRecording: .constant(false), isSettingsPresented: .constant(false))
}
