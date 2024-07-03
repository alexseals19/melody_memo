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
    @Binding var isMetronomeArmed: Bool
    var metronomeBpm: Double
    var inputSamples: [Float]?
    
    init(
        audioManager: AudioManager,
        isRecording: Binding<Bool>,
        isSettingsPresented: Binding<Bool>,
        inputSamples: [Float]?,
        trackTimer: Double,
        metronome: Metronome,
        isMetronomeArmed: Binding<Bool>,
        metronomeBpm: Double
    ) {
        _viewModel = StateObject(wrappedValue: TrackingToolbarViewModel(audioManager: audioManager, metronome: metronome))
        _isRecording = isRecording
        _isSettingsPresented = isSettingsPresented
        _isMetronomeArmed = isMetronomeArmed
        self.inputSamples = inputSamples
        self.trackTimer = trackTimer
        self.metronomeBpm = metronomeBpm
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @StateObject private var viewModel: TrackingToolbarViewModel
    
    private var trackTimer: Double
    
    private var timerDisplay: String {
        let minutes: Int = Int(trackTimer) / 60
        let seconds: Int = Int(trackTimer) % 60
        let miliseconds: Int = Int(modf(trackTimer).1 * 100)
        
        return String(format: "%02d:%02d.%02d", minutes, seconds, miliseconds)
    }
        
    //MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                MetronomeButtonView(isMetronomeArmed: $isMetronomeArmed, metronomeBpm: metronomeBpm)
                    .padding(.leading)
                RecordButtonView(isRecording: $isRecording, inputLevel: inputSamples)
                appSettingsButton
                    .padding(.trailing)
            }
            if isRecording {
                Text(timerDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
        isSettingsPresented: .constant(false),
        inputSamples: nil,
        trackTimer: 0.0,
        metronome: Metronome.shared,
        isMetronomeArmed: .constant(false),
        metronomeBpm: 120
        )
}
