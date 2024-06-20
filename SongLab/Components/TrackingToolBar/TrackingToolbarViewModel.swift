//
//  TrackingToolbarViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import SwiftUI

@MainActor
class TrackingToolbarViewModel: ObservableObject {
    
    //MARK: - API
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
    }
    
    // MARK: - Variables
    
    private let audioManager: AudioManager
}
