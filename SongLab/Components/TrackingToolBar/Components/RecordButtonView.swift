//
//  RecordButtonView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct RecordButtonView: View {
    
    //MARK: - API
    
    @Binding var isRecording: Bool
    
    @EnvironmentObject var appTheme: AppTheme
    
    init(isRecording: Binding<Bool>, inputLevel: [SampleModel]?) {
        _isRecording = isRecording
        self.inputSamples = inputLevel
    }
    
    // MARK: - Variables
                
    @State private var stopButtonOpacity = 0.0
    @State private var stopButtonDimensions: CGFloat = 65
    @State private var stopButtonCornerRadius: CGFloat = 32.5
    @State private var reordButtonOpacity = 1.0
    @State private var recordButtonDimensions: CGFloat = 65
    @State private var recordButtonCornerRadius: CGFloat = 32.5
    
    private var inputSamples: [SampleModel]?
    private var samples: [SampleModel] {
        if let inputSamples {
            return inputSamples
        } else {
            return []
        }
    }
    
    @Namespace private var namespace
    
    // MARK: - Body
        
    var body: some View {
        Button {
            stopButtonOpacity = 0.15
            withAnimation(.easeInOut) {
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
                .foregroundStyle(appTheme.accentColor)
                .shadow(color: appTheme.accentColor, radius: 2)
                .matchedGeometryEffect(id: 1, in: namespace, properties: .position)
                .padding(25)
            
            if isRecording {
                HStack(spacing: 5.0) {
                    HStack(spacing: 1.0) {
                        ForEach(samples) { sample in
                            Capsule()
                                .frame(width: 1.0, height: CGFloat(pow((sample.decibels + 80) / 10, 2)))
                                .foregroundStyle(Color(UIColor.label))
                        }
                        Spacer()
                            .frame(minWidth: 0.0)
                    }
                    .frame(width: 155, height: 55)
                    .clipped()
                    RoundedRectangle(cornerRadius: stopButtonCornerRadius)
                        .frame(width: stopButtonDimensions, height: stopButtonDimensions)
                        .foregroundColor(appTheme.accentColor)
                        .opacity(stopButtonOpacity)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.75)
                                .repeatForever(autoreverses: true)) {
                                    stopButtonOpacity = 1.0
                                }
                        }
                        .matchedGeometryEffect(id: 1, in: namespace, properties: .position)
                        .padding(.trailing, 25)
                }
            }
        }
    }
}

#Preview {
    RecordButtonView(isRecording: .constant(false), inputLevel: nil)
}
