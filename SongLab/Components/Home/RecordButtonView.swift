//
//  RecordButtonView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordButtonView: View {
    
    // MARK: - Variables
    
    @State private var isRecording = false
    @State private var opacity = 0.0
    
    // MARK: - Body
        
    var body: some View {
        Button {
            isRecording.toggle()
            opacity = 0.15
        } label: {
            buttonLabel
        }
    }
    
    private var buttonLabel: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4.0)
                .frame(width: 55, height: 55)
                .foregroundColor(.red)
            if isRecording {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.red)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 0.75)
                            .repeatForever(autoreverses: true)) {
                                opacity = 1.0
                            }
                        
                    }
            }
        }
    }
}

#Preview {
    RecordButtonView()
}
