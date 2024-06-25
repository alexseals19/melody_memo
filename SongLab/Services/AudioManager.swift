//
//  AudioManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Combine
import Foundation
import AVFoundation


struct AudioPlayer {
    var player = AVAudioPlayerNode()
    var track: Track
}

protocol AudioManager {
    var currentlyPlaying: CurrentValueSubject<Session?, Never> { get }
    var isRecording: CurrentValueSubject<Bool, Never> { get }
    func startTracking() throws
    func startTracking(for session: Session) throws
    func stopTracking() async
    func stopTracking(for session: Session) async
    func startPlayback(for session: Session) throws
    func stopPlayback()
    func toggleMute(for tracks: [Track])
    func setTrackVolume(for track: Track)
}


class DefaultAudioManager: AudioManager {
    
    // MARK: - API
    
    static let shared = DefaultAudioManager(
        audioSession: AVAudioSession(),
        recorder: AVAudioRecorder(),
        players: [AudioPlayer](),
        metronome: AVAudioPlayerNode(),
        engine: AVAudioEngine(),
        playbackEngine: AVAudioEngine(),
        mixerNode: AVAudioMixerNode()
    )
    
    var currentlyPlaying: CurrentValueSubject<Session?, Never>
    var isRecording: CurrentValueSubject<Bool, Never>
    
    func startTracking() throws {
        try setupRecorder()
        isRecording.send(true)
        recorder.record()
    }
    
    func startTracking(for session: Session) throws {
        let startTime = try setupPlayers(for: session)
        try setupRecorder()
        
        isRecording.send(true)
        currentlyPlaying.send(session)
        
        for player in players {
            player.player.play(at: startTime)
        }
        recorder.record(atTime: CACurrentMediaTime() + 0.5)
    }
        
    func stopTracking() async {
        
        defer { currentFileName = nil }
        
        Task { @MainActor in
            isRecording.send(false)
        }
        
        recorder.stop()
    
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: currentFileName,
            fileType: .caf
        )
        
        do {
            let audioAsset = AVURLAsset(url: url, options: nil)
            let duration = try await audioAsset.load(.duration)
            let durationInSeconds = CMTimeGetSeconds(duration)
            let track = Track(
                name: "Track 1",
                fileName: currentFileName,
                date: Date(),
                length: .seconds(durationInSeconds),
                id: UUID(),
                volume: 1.0,
                isMuted: false,
                isSolo: false
            )
            let session = Session(
                name: "Session \(DefaultRecordingManager.shared.sessions.value.count + 1)",
                date: Date(),
                length: .seconds(durationInSeconds),
                tracks: [track.id : track],
                id: UUID(),
                isGlobalSoloActive: false
            )
            try DefaultRecordingManager.shared.saveSession(session)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopTracking(for session: Session) async {
        defer { currentFileName = nil }
        
        var updatedSession = session
        
        Task { @MainActor in
            isRecording.send(false)
        }
        
        recorder.stop()
        stopPlayback()
    
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: currentFileName,
            fileType: .caf
        )
        
        do {
            let audioAsset = AVURLAsset(url: url, options: nil)
            let duration = try await audioAsset.load(.duration)
            let durationInSeconds = CMTimeGetSeconds(duration)
            let name = "Track \(session.tracks.count + 1)"
            let track = Track(
                name: name,
                fileName: currentFileName,
                date: Date(),
                length: .seconds(durationInSeconds),
                id: UUID(),
                volume: 1.0,
                isMuted: false,
                isSolo: false
            )
            
            updatedSession.tracks[track.id] = track
           
            if track.length > updatedSession.length {
                updatedSession.length = track.length
            }
            
            try DefaultRecordingManager.shared.saveSession(updatedSession)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startPlayback(for session: Session) throws {
        
        let startTime = try setupPlayers(for: session)
        
        currentlyPlaying.send(session)
        
        for player in players {
            player.player.play(at: startTime)
        }
        
    }
    
    func stopPlayback() {
        Task { @MainActor in
            currentlyPlaying.send(nil)
        }
        
        for player in players {
            player.player.stop()
        }
        playbackEngine.stop()
        players.removeAll()
    }
    
    func toggleMute(for tracks: [Track]) {
        for track in tracks {
            guard let newPlayer = players.first(where: { $0.track.id == track.id }) else {
                return
            }
            if newPlayer.player.volume == 0.0 {
                newPlayer.player.volume = track.volume
            } else {
                newPlayer.player.volume = 0.0
            }
        }
    }
    
    func setTrackVolume(for track: Track) {
        guard let newPlayer = players.first(where: { $0.track.id == track.id }) else {
            return
        }
        newPlayer.player.volume = track.volume
    }
    
    // MARK: - Variables
    
    private var audioSession: AVAudioSession
    private var recorder: AVAudioRecorder
    private var players: [AudioPlayer]
    private var metronome: AVAudioPlayerNode
    private var engine: AVAudioEngine
    private var playbackEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var currentFileName: String?
    private var bufferInterrupt: Bool = false
    private var beats: [AVAudioPlayerNode] = []
    private var metronomeActive: Bool = true
    private var firstBeat: Bool = true
        
    // MARK: - Functions
    
    private init(
        audioSession: AVAudioSession,
        recorder: AVAudioRecorder,
        players: [AudioPlayer],
        metronome: AVAudioPlayerNode,
        engine: AVAudioEngine,
        playbackEngine: AVAudioEngine,
        mixerNode: AVAudioMixerNode
    ) {
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
        self.audioSession = audioSession
        self.recorder = recorder
        self.players = players
        self.metronome = metronome
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
            try audioSession.setCategory(
                .playAndRecord,
                options: [.allowBluetoothA2DP, .defaultToSpeaker]
            )
           
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
    
    private func setupPlayers(for session: Session) throws -> AVAudioTime {
        let sortedTracks = session.tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
            return lhs.length < rhs.length
        }
                
        if currentlyPlaying.value != nil {
            bufferInterrupt = true
            for player in players {
                player.player.stop()
            }
        } else {
            bufferInterrupt = false
        }
        
        players.removeAll()
        for track in sortedTracks {
            players.append(AudioPlayer(track: track))
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: sortedTracks[0].fileName,
            fileType: .caf
        )
        
        let sampleAudioFile = try AVAudioFile(forReading: url)
    
        let sampleRate = sampleAudioFile.processingFormat.sampleRate
    
        for player in players {
            playbackEngine.attach(player.player)
            playbackEngine.connect(player.player,
                                   to: playbackEngine.mainMixerNode,
                                   format: sampleAudioFile.processingFormat)
        }

        playbackEngine.prepare()
        try playbackEngine.start()
        
        let kStartDelayTime = 0.5
        guard let renderTime = players[0].player.lastRenderTime else {
            print("Could not get lastRenderTime")
            return AVAudioTime(hostTime: mach_absolute_time())
        }
        let now: AVAudioFramePosition = renderTime.sampleTime
        
        let sampleTime = AVAudioFramePosition(Double(now) + (kStartDelayTime * sampleRate))
        
        let startTime = AVAudioTime(sampleTime: sampleTime, atRate: sampleRate)
        
        for player in players {
            let url = DataPersistenceManager.createDocumentURL(
                withFileName: player.track.fileName,
                fileType: .caf
            )
            
            let audioFile = try AVAudioFile(forReading: url)
            
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                assertionFailure("Could not assign buffer")
                return AVAudioTime(hostTime: mach_absolute_time())
            }
            
            try audioFile.read(into: buffer)

            player.player.scheduleBuffer(buffer,
                                  at: nil,
                                  options: .interrupts,
                                  completionCallbackType: .dataPlayedBack
            ) { _ in
                Task{ @MainActor in
                    if player.player == self.players.last?.player {
                        if !self.bufferInterrupt {
                            self.stopPlayback()
                            self.currentlyPlaying.send(nil)
                        }
                        self.bufferInterrupt = false
                    }
                }
            }
            player.player.prepare(withFrameCount: AVAudioFrameCount(audioFile.length))
            
        }
        if session.isGlobalSoloActive {
            for player in players {
                if player.track.isSolo {
                    player.player.volume = player.track.volume
                } else {
                    player.player.volume = 0.0
                }
            }
        } else {
            for player in players {
                print("\(player.track.name) \(player.track.isMuted)")
                if player.track.isMuted {
                    player.player.volume = 0.0
                } else {
                    player.player.volume = player.track.volume
                }
            }
        }
        return startTime
    }
    
    private func setupRecorder() throws {
        currentFileName = "Track\(UUID())"
        
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: currentFileName,
            fileType: .caf
        )
        
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
        
        recorder.prepareToRecord()
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
        let mixerFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: inputFormat.sampleRate,
            channels: 1,
            interleaved: false
        )
        
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
