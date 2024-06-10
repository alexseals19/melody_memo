//
//  AudioManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import AVFoundation

protocol AudioManagerDelegate: AnyObject {
    func audioManagerDidUpdate(recordings: [Recording])
}

@MainActor
protocol AudioManager {
    var delegate: AudioManagerDelegate? { get set }
    func startTracking()
    func stopTracking() async
    func startPlayback(recording: Recording)
    func stopPlayback()
    func getRecordings() -> [Recording]
    func removeRecording(with name: String)
}

@MainActor
class DefaultAudioManager: AudioManager {
    
    // MARK: - API
    
    static let shared = DefaultAudioManager(
        audioSession: AVAudioSession(),
        recorder: AVAudioRecorder(),
        player: AVAudioPlayerNode(),
        players: [AVAudioPlayerNode](),
        engine: AVAudioEngine(),
        playbackEngine: AVAudioEngine(),
        mixerNode: AVAudioMixerNode()
    )
    
    weak var delegate: AudioManagerDelegate?
    
    func startTracking() {
        do {
            currentFileName = "Session\(recordings.count + 1)"
            
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
        
//        do {
//            let tapNode: AVAudioNode = mixerNode
//            let format = tapNode.outputFormat(forBus: 0)
//
//            currentFileName = "Session\(recordings.count + 1)"
//
//            guard let currentFileName else {
//                assertionFailure("currentFileName is nil.")
//                return
//            }
//
//            let url = DataPersistenceManager.createDocumentURL(withFileName: currentFileName, fileType: .caf)
//            file = try AVAudioFile(forWriting: url, settings: format.settings)
//            tapNode.removeTap(onBus: 0)
//
//            guard let inputs = recordSession.availableInputs else {
//                assertionFailure("No available inputs")
//                return
//            }
//
//            tapNode.installTap(onBus: 0, bufferSize: 1024, format: format, block: { (buffer, time ) in
//                try? self.file.write(from: buffer)
//            })
//
//            try engine.start()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopTracking() async {
//        engine.inputNode.removeTap(onBus: 0)
//        engine.stop()
        
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
            recordings.insert(
                Recording(
                    name: currentFileName,
                    date: Date(),
                    length: .seconds(durationInSeconds),
                    id: UUID()
                ),
                at: 0
            )
            
            try DataPersistenceManager.save(recordings, to: "recordings")
        } catch {
            print(error.localizedDescription)
        }
        
        delegate?.audioManagerDidUpdate(recordings: recordings)
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
    
    func getRecordings() -> [Recording] {
        return recordings
    }
    
    func removeRecording(with name: String) {
        do {
            try DataPersistenceManager.delete(name, fileType: .caf)
            if let index = recordings.firstIndex(where: { $0.name == name }) {
                recordings.remove(at: index)
            }
        } catch {
            print(error.localizedDescription)
        }
        delegate?.audioManagerDidUpdate(recordings: recordings)
    }
    
    // MARK: - Variables
    
    private var audioSession: AVAudioSession
    private var recorder: AVAudioRecorder
    private var player: AVAudioPlayerNode
    private var players: [AVAudioPlayerNode]
    private var engine: AVAudioEngine
    private var playbackEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var currentFileName: String?
    
    private var recordings: [Recording] = []
    
    // MARK: - Functions
    
    private init(
        audioSession: AVAudioSession,
        recorder: AVAudioRecorder,
        player: AVAudioPlayerNode,
        players: [AVAudioPlayerNode],
        engine: AVAudioEngine,
        playbackEngine: AVAudioEngine,
        mixerNode: AVAudioMixerNode) {
            self.audioSession = audioSession
            self.recorder = recorder
            self.player = player
            self.players = players
            self.engine = engine
            self.playbackEngine = playbackEngine
            self.mixerNode = mixerNode
            loadRecordingsFromDisk()
            setUpSession()
            setUpEngine()
            setupNotifications()
    }
    
    private func setUpPlayers() {
        for _ in recordings {
            players.append(AVAudioPlayerNode())
        }
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
    
    private func loadRecordingsFromDisk() {
        do {
            recordings = try DataPersistenceManager.retrieve([Recording].self, from: "recordings")
            delegate?.audioManagerDidUpdate(recordings: recordings)
        } catch {}
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

class MockAudioManager: AudioManager {
    
    weak var delegate: AudioManagerDelegate?
    
    func startTracking() {}
    
    func stopTracking() async {}
    
    func startPlayback(recording: Recording) {}
    
    func stopPlayback() {}
    
    func getRecordings() -> [Recording] {return []}
    
    func removeRecording(with name: String) {}
            
}

