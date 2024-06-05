//
//  TrackingToolbarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct TrackingToolbarView: View {
    
    //MARK: - API
    
    @State var metronomeActive = false
    
    @State var isRecording = false
    
    //MARK: - Body
    
    var body: some View {
        HStack {
            MetronomeView()
                .padding(.leading)
            Spacer()
            RecordButtonView(isRecording: $isRecording)
            Spacer()
            TrackingSettingsView()
        }
    }
}

#Preview {
    TrackingToolbarView(metronomeActive: false, isRecording: false)
}
