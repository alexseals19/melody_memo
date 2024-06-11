//
//  AudioManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import AVFoundation

@MainActor
protocol AudioManager {
    func startTracking()
    func stopTracking() async
    func startPlayback(recording: Recording)
    func stopPlayback()
}

@MainActor
class DefaultAudioManager: AudioManager {
    
    // MARK: - API
    
    static let shared = DefaultAudioManager(
        audioSession: AVAudioSession(),
        recorder: AVAudioRecorder(),
        player: AVAudioPlayerNode(),
        engine: AVAudioEngine(),
        playbackEngine: AVAudioEngine(),
        mixerNode: AVAudioMixerNode()
    )
        
    func startTracking() {
        do {
            currentFileName = "Session\(DefaultRecordingManager.shared.recordings.value.count + 1)"
            
            guard let currentFileName else {
                assertionFailure("currentFileName is nil.")
                return
            }
            
            let url = DataPersistenceManager.createDocumentURL(withFileName: currentFileName, fileType: .caf)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 32000,
                AVNumberOfChannelsKey: 1
            ]
            guard let inputs = audioSession.availableInputs else {
                assertionFailure("inputs")
                return
            }
            try audioSession.setPreferredInput(inputs[0])
            recorder = try AVAudioRecorder(url: url, settings: settings)
                        
            recorder.record()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopTracking() async {
        
        defer { currentFileName = nil }
        
        recorder.stop()
    
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(withFileName: currentFileName, fileType: .caf)
        
        do {
            let audioAsset = AVURLAsset(url: url, options: nil)
            let duration = try await audioAsset.load(.duration)
            let durationInSeconds = CMTimeGetSeconds(duration)
            let recording = Recording(
                name: currentFileName,
                date: Date(),
                length: .seconds(durationInSeconds),
                id: UUID()
            )
            try DefaultRecordingManager.shared.saveRecording(recording)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startPlayback(recording: Recording) {
        do {
            configurePlayback(player: player)
            
            playbackEngine.prepare()
            try playbackEngine.start()
            
            let url = DataPersistenceManager.createDocumentURL(withFileName: recording.name, fileType: .caf)
            let audioFile = try AVAudioFile(forReading: url)
            
            player.scheduleFile(audioFile, at: nil)
        
            player.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopPlayback() {
        player.stop()
        playbackEngine.stop()
    }
    
    // MARK: - Variables
    
    private var audioSession: AVAudioSession
    private var recorder: AVAudioRecorder
    private var player: AVAudioPlayerNode
    private var engine: AVAudioEngine
    private var playbackEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var currentFileName: String?
        
    // MARK: - Functions
    
    private init(
        audioSession: AVAudioSession,
        recorder: AVAudioRecorder,
        player: AVAudioPlayerNode,
        engine: AVAudioEngine,
        playbackEngine: AVAudioEngine,
        mixerNode: AVAudioMixerNode) {
            self.audioSession = audioSession
            self.recorder = recorder
            self.player = player
            self.engine = engine
            self.playbackEngine = playbackEngine
            self.mixerNode = mixerNode
            setUpSession()
            setUpEngine()
            setupNotifications()
    }
    
    private func setUpSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.allowBluetoothA2DP, .defaultToSpeaker])
           
            try audioSession.setSupportsMultichannelContent(true)
            try audioSession.setActive(true)
            
            guard let inputs = audioSession.availableInputs else {
                assertionFailure("failed to retrieve inputs")
                return
            }
            try audioSession.setPreferredInput(inputs[0])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func configurePlayback(player: AVAudioPlayerNode) {
        playbackEngine.attach(player)
        playbackEngine.connect(player, to: playbackEngine.mainMixerNode, format: nil)
    }
    
    private func setUpEngine() {
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        mixerNode.volume = 0
        
        engine.attach(mixerNode)
        makeConnections()
    }
    
    private func makeConnections() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        let mainMixerNode = engine.mainMixerNode
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }
    
    private func setupNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
    }

    @objc func handleRouteChange(notification: Notification) {
        // To be implemented.
        guard let inputs = audioSession.availableInputs else {
            assertionFailure("failed to retrieve inputs")
            return
        }
        do {
            try audioSession.setPreferredInput(inputs[0])
        } catch {
            print(error.localizedDescription)
        }
    }
}
