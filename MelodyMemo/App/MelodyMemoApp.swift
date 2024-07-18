//
//  MelodyMemoApp.swift
//  MelodyMemo
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

@main
struct MelodyMemoApp: App {
        
    var appTheme = AppTheme()

    var body: some Scene {
        WindowGroup {
            HomeView(
                audioManager: DefaultAudioManager.shared,
                recordingManager: DefaultRecordingManager.shared
            )
            .environmentObject(appTheme)
        }
    }
}
