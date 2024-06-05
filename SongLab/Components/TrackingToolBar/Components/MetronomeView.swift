//
//  MetronomeView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct MetronomeView: View {
    
    //MARK: - API
    
    @State var metronomeActive = false
    
    // MARK: - Variables
    
    @State private var bpm = 120
    
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
                    Text("\(bpm)")
                        .font(.caption)
                        .opacity(0)
                    Image(systemName: "metronome.fill")
                        .frame(width: 26, height: 26)
                    Text("\(bpm)")
                        .font(.caption)
                        .matchedGeometryEffect(id: 2, in: namespace, properties: .position)
                }
            } else {
                Image(systemName: "metronome")
                    .frame(width: 26, height: 26)
                    .matchedGeometryEffect(id: 2, in: namespace, properties: .position)
            }
        }
    }
}

#Preview {
    MetronomeView()
}
