//
//  MetronomeButtonView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct MetronomeButtonView: View {
    
    //MARK: - API
    
    @Binding var isMetronomeArmed: Bool
    
    var isRecording: Bool
    
    init(
        isMetronomeArmed: Binding<Bool>,
        metronomeBpm: Int,
        isRecording: Bool
    ) {
        _isMetronomeArmed = isMetronomeArmed
        self.metronomeBpm = metronomeBpm
        self.isRecording = isRecording
    }
    
    // MARK: - Variables
    
    @Namespace private var namespace
    
    private var metronomeBpm: Int
            
    //MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                if !isRecording {
                    isMetronomeArmed.toggle()
                }
            }
        } label: {
            metronomeLabel
        }
        .buttonStyle(.plain)
    }
    
    private var metronomeLabel: some View {
        Group {
            if isMetronomeArmed {
                VStack(spacing: -2) {
                    AppButtonLabelView(name: "metronome.fill", color: .primary, size: 22)
                        .matchedGeometryEffect(id: "metro", in: namespace, properties: .position)
                    Text("\(Int(metronomeBpm))")
                        .font(.caption)
                }
            } else {
                AppButtonLabelView(name: "metronome", color: .primary, size: 22)
                    .matchedGeometryEffect(id: "metro", in: namespace, properties: .position)
            }
        }
    }
}

#Preview {
    MetronomeButtonView(
        isMetronomeArmed: .constant(false),
        metronomeBpm: 120,
        isRecording: false
    )
}
