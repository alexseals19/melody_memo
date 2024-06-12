//
//  RecordButtonView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordButtonView: View {
    
    //MARK: - API
    
    var isRecording: Bool
    
    init(isRecording: Bool,
         recordButtonAction: @escaping () -> Void
    ) {
        self.isRecording = isRecording
        self.recordButtonAction = recordButtonAction
    }
    
    // MARK: - Variables
            
    @State private var stopButtonOpacity = 0.0
    @State private var stopButtonDimensions: CGFloat = 65
    @State private var stopButtonCornerRadius: CGFloat = 32.5
    @State private var reordButtonOpacity = 1.0
    @State private var recordButtonDimensions: CGFloat = 65
    @State private var recordButtonCornerRadius: CGFloat = 32.5
    @State private var buttonToggle: Bool = false
    
    @Namespace private var namespace
    
    let recordButtonAction: () -> Void
    
    // MARK: - Body
        
    var body: some View {
        Button {
            stopButtonOpacity = 0.15
            withAnimation(.linear) {
                if isRecording {
                    stopButtonDimensions = 65
                    stopButtonCornerRadius = 27.5
                    recordButtonDimensions = 65
                    recordButtonCornerRadius = 32.5
                    reordButtonOpacity = 1.0
                } else {
                    stopButtonDimensions = 25
                    stopButtonCornerRadius = 5
                    recordButtonDimensions = 21
                    recordButtonCornerRadius = 5
                    reordButtonOpacity = 0.0
                }
            }
            recordButtonAction()
            buttonToggle.toggle()
        } label: {
            buttonLabel
                .frame(height: 55)
        }
    }
    
    private var buttonLabel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: recordButtonCornerRadius)
                .stroke(lineWidth: 4.0)
                .opacity(reordButtonOpacity)
                .frame(width: recordButtonDimensions, height: recordButtonDimensions)
                .foregroundColor(.red)
                .matchedGeometryEffect(id: 1, in: namespace, properties: .position)
            if buttonToggle {
                HStack {
                    Spacer()
                        .frame(width: 140)
                    RoundedRectangle(cornerRadius: stopButtonCornerRadius)
                        .frame(width: stopButtonDimensions, height: stopButtonDimensions)
                        .foregroundColor(.red)
                        .opacity(stopButtonOpacity)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.75)
                                .repeatForever(autoreverses: true)) {
                                    stopButtonOpacity = 1.0
                                }
                        }
                        .matchedGeometryEffect(id: 1, in: namespace, properties: .position)
                }
            }
        }
    }
}

#Preview {
    RecordButtonView(isRecording: false, recordButtonAction: {})
}
