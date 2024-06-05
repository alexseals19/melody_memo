//
//  RecordButtonView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordButtonView: View {
    
    //MARK: - API
    
    @Binding public var isRecording: Bool
    
    init(isRecording: Binding<Bool>) {
        _isRecording = isRecording
    }
    
    // MARK: - Variables
            
    @State private var stopButtonOpacity = 0.0
    @State private var stopButtonDimensions: CGFloat = 55
    @State private var stopButtonCornerRadius: CGFloat = 27.5
    @State private var reordButtonOpacity = 1.0
    @State private var recordButtonDimensions: CGFloat = 55
    @State private var recordButtonCornerRadius: CGFloat = 27.5
    
    @Namespace private var namespace
    
    // MARK: - Body
        
    var body: some View {
        Button {
            stopButtonOpacity = 0.15
            withAnimation(.linear) {
                if isRecording {
                    stopButtonDimensions = 55
                    stopButtonCornerRadius = 27.5
                    recordButtonDimensions = 55
                    recordButtonCornerRadius = 27.5
                    reordButtonOpacity = 1.0
                } else {
                    stopButtonDimensions = 25
                    stopButtonCornerRadius = 5
                    recordButtonDimensions = 21
                    recordButtonCornerRadius = 5
                    reordButtonOpacity = 0.0
                    
                }
            }
            isRecording.toggle()
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
            if isRecording {
                HStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
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
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    RecordButtonView(isRecording: .constant(false))
}
