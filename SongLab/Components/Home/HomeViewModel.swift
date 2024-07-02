//
//  HomeViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    //MARK: - API
    @AppStorage("metronomeActive") var metronomeActive: Bool = false
    
    @Published var selectedSession: Session?
    @Published var isSettingsPresented: Bool = false
    @Published var inputSamples: [Float]?
    @Published var trackTimer: Double = 0.0
    @Published var isRecording: Bool = false {
        didSet {
            if isRecording {
                if let selectedSession {
                    do {
                        try audioManager.startTracking(for: selectedSession)
                        metronomeActive ? try metronome.playMetronome(timeSignature: 4, beat: 0) : nil
                    } catch {
                        //TODO
                    }
                } else {
                    audioManager.stopPlayback()
                    do {
                        try audioManager.startTracking()
                        metronomeActive ? try metronome.playMetronome(timeSignature: 4, beat: 0) : nil
                    } catch {
                        //TODO
                    }
                }
            } else {
                Task{
                    if let selectedSession {
                        await audioManager.stopTracking(for: selectedSession)
                        metronomeActive ? metronome.stopMetronome() : nil
                    } else {
                        await audioManager.stopTracking()
                        metronomeActive ? metronome.stopMetronome() : nil
                    }
                }
            }
        }
    }
    
    let audioManager: AudioManager
    let recordingManager: RecordingManager
    var metronome = Metronome()
    
    init(audioManager: AudioManager, recordingManager: RecordingManager) {
        self.audioManager = audioManager
        self.recordingManager = recordingManager
        recordingManager.sessions
            .compactMap { $0.first { $0.id == self.selectedSession?.id }}
            .assign(to: &$selectedSession)  
        audioManager.inputSamples
            .assign(to: &$inputSamples)
        audioManager.playerProgress
            .assign(to: &$trackTimer)
    }
    
    // MARK: - Variables
    
    // MARK: - Functions
    
}
