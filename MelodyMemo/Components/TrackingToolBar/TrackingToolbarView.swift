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
    
    var metronomeBpm: Int
    var inputSamples: [SampleModel]?
    
    init(
        isRecording: Binding<Bool>,
        isSettingsPresented: Binding<Bool>,
        inputSamples: [SampleModel]?,
        trackTimer: Double,
        isMetronomeArmed: Binding<Bool>,
        metronomeBpm: Int
    ) {
        _isRecording = isRecording
        _isSettingsPresented = isSettingsPresented
        _isMetronomeArmed = isMetronomeArmed
        self.inputSamples = inputSamples
        self.trackTimer = trackTimer
        self.metronomeBpm = metronomeBpm
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
        
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
                RecordButtonView(isRecording: $isRecording, inputLevel: inputSamples)
            }
            if isRecording {
                Text(timerDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.spring, value: isRecording)
        .offset(y: -20)
        .padding(.top, 25)
    }
    
    var appSettingsButton: some View {
        Button {
            if !isRecording {
                isSettingsPresented.toggle()
            }
        } label: {
            AppButtonLabelView(name: "slider.horizontal.3", color: .primary, size: 22)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
        }
    }
}

#Preview {
    TrackingToolbarView(
        isRecording: .constant(false),
        isSettingsPresented: .constant(false),
        inputSamples: nil,
        trackTimer: 0.0,
        isMetronomeArmed: .constant(false),
        metronomeBpm: 120
        )
}
