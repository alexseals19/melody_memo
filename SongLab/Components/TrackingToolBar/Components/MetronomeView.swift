//
//  MetronomeView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct MetronomeView: View {
    
    //MARK: - API
    
    @AppStorage("bpm") var bpm: Int = 120
    @AppStorage("metronomeActive") var metronomeActive: Bool = false
    
    // MARK: - Variables
    
    @Namespace private var namespace
            
    //MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                metronomeActive.toggle()
            }
        } label: {
            metronomeLabel
        }
        .buttonStyle(.plain)
    }
    
    private var metronomeLabel: some View {
        Group {
            if metronomeActive {
                VStack(spacing: -2) {
                    Image(systemName: "metronome.fill")
                        .resizable()
                        .frame(width: 21.5, height: 20)
                        .matchedGeometryEffect(id: "metro", in: namespace, properties: .position)
                    Text("\(bpm)")
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
    MetronomeView()
}
