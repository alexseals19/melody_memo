//
//  AudioManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Combine
import Foundation
import AVFoundation


protocol AudioManager {
    var currentlyPlaying: CurrentValueSubject<Session?, Never> { get }
    var isRecording: CurrentValueSubject<Bool, Never> { get }
    func startTracking() throws
    func startTracking(for session: Session) throws
    func stopTracking() async
    func stopTracking(for session: Session) async
    func startPlayback(for tracks: [Track], session: Session) throws
    func stopPlayback()
}


class DefaultAudioManager: AudioManager {
    
    // MARK: - API
    
    static let shared = DefaultAudioManager(
        audioSession: AVAudioSession(),
        recorder: AVAudioRecorder(),
        players: [AVAudioPlayerNode](),
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
        let startTime = try setupPlayers(for: session.tracks, session: session)
        try setupRecorder()
        
        isRecording.send(true)
        currentlyPlaying.send(session)
        
        for player in players {
            player.play(at: startTime)
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
            let session = Session(
                name: "Session \(DefaultRecordingManager.shared.sessions.value.count + 1)",
                date: Date(),
                length: .seconds(durationInSeconds),
                tracks: [
                    Track(
                        name: "Track 1",
                        fileName: currentFileName,
                        date: Date(),
                        length: .seconds(durationInSeconds),
                        id: UUID()
                    )
                ],
                id: UUID()
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
            
            updatedSession.tracks.append(
                Track(
                    name: name,
                    fileName: currentFileName,
                    date: Date(),
                    length: .seconds(durationInSeconds),
                    id: UUID()
                )
            )
            
            if let track = updatedSession.tracks.last, track.length > updatedSession.length {
                updatedSession.length = track.length
            }
            
            try DefaultRecordingManager.shared.saveSession(updatedSession)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startPlayback(for tracks: [Track], session: Session) throws {
        
        let startTime = try setupPlayers(for: tracks, session: session)
        
        currentlyPlaying.send(session)
        
        for player in players {
            player.play(at: startTime)
        }
    }
    
    func stopPlayback() {
        Task { @MainActor in
            currentlyPlaying.send(nil)
        }
        
        for player in players {
            player.stop()
        }
        playbackEngine.stop()
        players.removeAll()
    }
    
    // MARK: - Variables
    
    private var audioSession: AVAudioSession
    private var recorder: AVAudioRecorder
    private var players: [AVAudioPlayerNode]
    private var engine: AVAudioEngine
    private var playbackEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var currentFileName: String?
    private var bufferInterrupt: Bool = false
        
    // MARK: - Functions
    
    private init(
        audioSession: AVAudioSession,
        recorder: AVAudioRecorder,
        players: [AVAudioPlayerNode],
        engine: AVAudioEngine,
        playbackEngine: AVAudioEngine,
        mixerNode: AVAudioMixerNode
    ) {
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
        self.audioSession = audioSession
        self.recorder = recorder
        self.players = players
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
    
    private func setupPlayers(for tracks: [Track], session: Session) throws -> AVAudioTime {
        let sortedTracks = tracks.sorted { (lhs: Track, rhs: Track) -> Bool in
            return lhs.length < rhs.length
        }
                
        if currentlyPlaying.value != nil {
            bufferInterrupt = true
            for player in players {
                player.stop()
            }
        } else {
            bufferInterrupt = false
        }
        
        players.removeAll()
        for _ in tracks {
            players.append(AVAudioPlayerNode())
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: sortedTracks[0].fileName,
            fileType: .caf
        )
        
        let sampleAudioFile = try AVAudioFile(forReading: url)
    
        let sampleRate = sampleAudioFile.processingFormat.sampleRate
    
        for player in players {
            playbackEngine.attach(player)
            playbackEngine.connect(player,
                                   to: playbackEngine.mainMixerNode,
                                   format: sampleAudioFile.processingFormat)
        }
        
        playbackEngine.prepare()
        try playbackEngine.start()
        
        let kStartDelayTime = 0.5
        guard let renderTime = players[0].lastRenderTime else {
            print("Could not get lastRenderTime")
            return AVAudioTime(hostTime: mach_absolute_time())
        }
        let now: AVAudioFramePosition = renderTime.sampleTime
        
        let sampleTime = AVAudioFramePosition(Double(now) + (kStartDelayTime * sampleRate))
        
        let startTime = AVAudioTime(sampleTime: sampleTime, atRate: sampleRate)
        
        for index in 0 ..< players.count {
            let lastPlayer = players.count - 1
            let url = DataPersistenceManager.createDocumentURL(
                withFileName: sortedTracks[index].fileName,
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

            players[index].scheduleBuffer(buffer,
                                  at: nil,
                                  options: .interrupts,
                                  completionCallbackType: .dataPlayedBack
            ) { _ in
                Task{ @MainActor in
                    if index == lastPlayer {
                        if !self.bufferInterrupt {
                            self.stopPlayback()
                            self.currentlyPlaying.send(nil)
                        }
                        self.bufferInterrupt = false
                    }
                }
            }
            players[index].prepare(withFrameCount: AVAudioFrameCount(audioFile.length))
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
