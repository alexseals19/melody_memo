//
//  SongLabApp.swift
//  SongLab
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

@main
struct SongLabApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(recordingManager: DefaultRecordingManager.shared)
        }
    }
}
