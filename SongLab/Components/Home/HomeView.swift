//
//  ContentView.swift
//  SongLab
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

struct HomeView: View {
    
    init(recordingManager: RecordingManager) {
        self.recordingManager = recordingManager
    }
    
    private let recordingManager: RecordingManager
    
    var body: some View {
        VStack {
            RecordingsListView(recordingManager: recordingManager)
            Divider()
            Divider()
            TrackingToolbarView(recordingManager: recordingManager)
                .ignoresSafeArea()
                .padding(.top)
        }
        .padding()
        .onAppear {
            recordingManager.setUpSession()
        }
    }
}

#Preview {
    HomeView(recordingManager: DefaultRecordingManager.shared)
}
