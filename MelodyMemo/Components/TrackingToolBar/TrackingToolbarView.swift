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
                MetronomeButtonView(
                    isMetronomeArmed: $isMetronomeArmed,
                    metronomeBpm: metronomeBpm,
                    isRecording: isRecording
                )
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
            Color(UIColor.systemBackground).opacity(0.3)
                .background(.ultraThickMaterial.opacity(0.97))
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        )
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
            Image(systemName: "slider.horizontal.3")
        }
        .foregroundStyle(.primary)
        
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
