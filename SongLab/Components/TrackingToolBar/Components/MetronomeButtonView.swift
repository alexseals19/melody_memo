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
    
    init(isMetronomeArmed: Binding<Bool>, metronomeBpm: Double) {
        _isMetronomeArmed = isMetronomeArmed
        self.metronomeBpm = metronomeBpm
    }
    
    // MARK: - Variables
    
    @Namespace private var namespace
    
    private var metronomeBpm: Double
            
    //MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                isMetronomeArmed.toggle()
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
                    Image(systemName: "metronome.fill")
                        .resizable()
                        .frame(width: 21.5, height: 20)
                        .matchedGeometryEffect(id: "metro", in: namespace, properties: .position)
                    Text("\(Int(metronomeBpm))")
                        .font(.caption)
                }
            } else {
                Image(systemName: "metronome")
                    .resizable()
                    .frame(width: 21.5, height: 20)
                    .matchedGeometryEffect(id: "metro", in: namespace, properties: .position)
            }
        }
    }
}

#Preview {
    MetronomeButtonView(isMetronomeArmed: .constant(false), metronomeBpm: 120)
}
