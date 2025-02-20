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
                
    @State private var stopButtonOpacity = 0.15
    @State private var stopButtonDimensions: CGFloat = 25
    @State private var stopButtonCornerRadius: CGFloat = 5
    @State private var reordButtonOpacity = 1.0
    @State private var recordButtonDimensions: CGFloat = 80
    @State private var recordButtonCornerRadius: CGFloat = 40
    @State private var recordButtonOffset: CGFloat = 0.0
    @State private var inputMeterWidth: CGFloat = 0.0
    
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
            
            withAnimation(.easeInOut(duration: 0.25)) {
                if isRecording {
                    recordButtonDimensions = 80
                    recordButtonCornerRadius = 40
                    reordButtonOpacity = 1.0
                    recordButtonOffset = 0.0
                    inputMeterWidth = 0.0
                } else {
                    recordButtonDimensions = 21
                    recordButtonCornerRadius = 5
                    reordButtonOpacity = 0.0
                    recordButtonOffset = 75.0
                    inputMeterWidth = 155.0
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
                .stroke(lineWidth: 2.0)
                .opacity(reordButtonOpacity)
                .frame(width: recordButtonDimensions, height: recordButtonDimensions)
                .foregroundStyle(appTheme.accentColor)
                .offset(x: recordButtonOffset)
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
                    .frame(width: inputMeterWidth, height: 55)
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
                        .onDisappear {
                            stopButtonOpacity = 0.15
                        }
                        .padding(.trailing, 25)
                }
                .background(
                    .ultraThinMaterial
                )
                .matchedGeometryEffect(id: "back", in: namespace)
                .cornerRadius(15)
            }
            else {
                RoundedRectangle(cornerRadius: 75 / 2)
                    .opacity(reordButtonOpacity)
                    .frame(width: 75, height: 75)
                    .foregroundStyle(.ultraThinMaterial)
                    .offset(x: recordButtonOffset)
                    .padding(25)
                    .matchedGeometryEffect(id: "back", in: namespace)
            }
        }
    }
}

#Preview {
    RecordButtonView(isRecording: .constant(false), inputLevel: nil)
}
