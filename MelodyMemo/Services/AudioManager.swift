//
//  AudioManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Combine
import Foundation
import AVFoundation
import SwiftUI

struct AudioPlayer {
    var player = AVAudioPlayerNode()
    var track: Track
}

struct SampleModel: Hashable, Identifiable {
    var decibels: Float
    var id = UUID()
}

@MainActor
protocol AudioManager {
    var trackLengthLimit: Int { get set }
    var currentlyPlaying: CurrentValueSubject<Session?, Never> { get }
    var isRecording: CurrentValueSubject<Bool, Never> { get }
    var playerProgress: CurrentValueSubject<Double, Never> { get }
    var inputSamples: CurrentValueSubject<[SampleModel]?, Never> { get }
    func startTracking() async throws
    func startTracking(for session: Session) async throws
    func stopTracking() async throws
    func stopTracking(for session: Session) async throws
    func startPlayback(for session: Session) throws
    func stopPlayback(stopTimer: Bool) throws
    func removeTrack(track: Track)
    func toggleMute(for tracks: [Track])
    func setTrackVolume(for track: Track)
    func setTrackPan(for track: Track)
    func getImage(for fileName: String, colorScheme: ColorScheme) throws -> Image
}

@MainActor
class DefaultAudioManager: AudioManager {
    
    // MARK: - API
    
    static let shared = DefaultAudioManager(
        audioSession: AVAudioSession(),
        recorder: AVAudioRecorder(),
        players: [AudioPlayer](),
        engine: AVAudioEngine(),
        playbackEngine: AVAudioEngine(),
        mixerNode: AVAudioMixerNode()
    )
    
    @AppStorage("trackLengthLimit") var trackLengthLimit: Int = 2
    
    var currentlyPlaying: CurrentValueSubject<Session?, Never>
    var isRecording: CurrentValueSubject<Bool, Never>
    var playerProgress: CurrentValueSubject<Double, Never>
    var inputSamples: CurrentValueSubject<[SampleModel]?, Never>
    var progressTimerSubscription: AnyCancellable?
    var meterTimerSubscription: AnyCancellable?
    
    func startTracking() async throws {
        try setupRecorder()
        isRecording.send(true)
                
        if await metronome.isArmed {
            try await metronome.prepare()
        }
        
        let countInDelay = await metronome.countInDelay
        
        let startTime = CACurrentMediaTime() + 0.25
        
        if await metronome.isArmed {
            await metronome.start(at: startTime + 0.25)
        }
        
        recorder.record(atTime: (startTime + countInDelay + bluetoothDelay))
        
        try startMetering(at: startTime + countInDelay)
        try startTimer(at: startTime + countInDelay)
    }
    
    func startTracking(for session: Session) async throws {
        try setupPlayers(for: session, stopTimer: false)
                
        try setupRecorder()
        
        if await metronome.isArmed {
            try await metronome.prepare()
        }
        
        isRecording.send(true)
        currentlyPlaying.send(session)
        
        let startTime = CACurrentMediaTime() + 0.5
        
        if !session.tracks.isEmpty {
            for player in players {
                await player.player.play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: startTime + metronome.countInDelay - 0.28)))
            }
        }
        
        if await metronome.isArmed {
            await metronome.start(at: startTime)
        }
        await recorder.record(atTime: (startTime + metronome.countInDelay + bluetoothDelay) - 0.25)
        
        try await startMetering(at: (startTime +  metronome.countInDelay) - 0.25)
        try await startTimer(at: (startTime +  metronome.countInDelay) - 0.25)
    }
        
    func stopTracking() async throws {
        
        defer { currentFileName = nil }
        
        currentTrackLength = playerProgress.value
        
        if await metronome.isArmed {
            await metronome.stopMetronome()
        }
        
        stopMetering()
        stopTimer()
        
        isRecording.send(false)
                
        recorder.stop()
            
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: currentFileName,
            fileType: .m4a
        )
        
        let audioAsset = AVURLAsset(url: url, options: nil)
        
        let duration = try await audioAsset.load(.duration)
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        if durationInSeconds < Double(trackLengthLimit) {
            do {
                try DataPersistenceManager.delete(currentFileName, fileType: .m4a)
            } catch {
                print(error.localizedDescription)
            }
            return
        }
        
        let track = Track(
            name: "Track 1",
            fileName: currentFileName,
            date: Date(),
            length: durationInSeconds,
            id: UUID(),
            volume: 1.0,
            pan: 0.0,
            isMuted: false,
            isSolo: false,
            soloOverride: false
        )
        let session = Session(
            name: "Session \(DefaultRecordingManager.shared.absoluteSessionCount + 1)",
            date: Date(),
            length: durationInSeconds,
            tracks: [track.id : track],
            absoluteTrackCount: 1,
            id: UUID(),
            isGlobalSoloActive: false
        )
        try DefaultRecordingManager.shared.saveSession(session)
        DefaultRecordingManager.shared.incrementAbsoluteSessionCount()
    }
    
    func stopTracking(for session: Session) async throws {
        defer { currentFileName = nil }
        
        var updatedSession = session
        
        stopMetering()
        isRecording.send(false)
        
        recorder.stop()
        try stopPlayback(stopTimer: true)
        
        if await metronome.isArmed {
            await metronome.stopMetronome()
        }
    
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: currentFileName,
            fileType: .m4a
        )
        
        let audioAsset = AVURLAsset(url: url, options: nil)
        let duration = try await audioAsset.load(.duration)
        let durationInSeconds = CMTimeGetSeconds(duration)
        let name = "Track \(session.absoluteTrackCount + 1)"
        
        if durationInSeconds < Double(trackLengthLimit) {
            try DataPersistenceManager.delete(currentFileName, fileType: .m4a)
            return
        }
        
        let track = Track(
            name: name,
            fileName: currentFileName,
            date: Date(),
            length: Double(durationInSeconds),
            id: UUID(),
            volume: 1.0,
            pan: 0.0,
            isMuted: false,
            isSolo: false,
            soloOverride: false
        )
        
        updatedSession.tracks[track.id] = track
        updatedSession.absoluteTrackCount += 1
        
        if track.length > updatedSession.length {
            updatedSession.length = track.length
        }
        
        try DefaultRecordingManager.shared.saveSession(updatedSession)
    }
    
    func startPlayback(for session: Session) throws {
        try setupPlayers(for: session)
        
        let startTimeInSeconds = CACurrentMediaTime() + 0.25
        
        let startTime = AVAudioTime(
            hostTime: AVAudioTime.hostTime(
                forSeconds: startTimeInSeconds
            )
        )
        
        currentlyPlaying.send(session)
        playerProgress.send(0.0)
        
        for player in players {
            player.player.play(at: startTime)
        }
        
        try startTimer(at: startTimeInSeconds + 0.03)
    }
    
    func stopPlayback(stopTimer: Bool) throws {
        
        for player in players {
            player.player.stop()
        }
        playbackEngine.stop()
        players.removeAll()
        if stopTimer {
            self.stopTimer()
        }
        currentlyPlaying.send(nil)
    }
    
    func removeTrack(track: Track) {
        guard let newPlayer = players.first(where: { $0.track.id == track.id }) else {
            return
        }
        newPlayer.player.stop()
        playbackEngine.detach(newPlayer.player)
        players = players.filter( { $0.track != track } )
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
    
    func setTrackPan(for track: Track) {
        guard let newPlayer = players.first(where: { $0.track.id == track.id }) else {
            return
        }
        newPlayer.player.pan = track.pan
    }
    
    @MainActor func getImage(for fileName: String, colorScheme: ColorScheme) throws -> Image {
        let samples = try getWaveform(for: fileName)
        
        var color: Color {
            colorScheme == .dark ? .white : .black
        }
        
        let renderer = ImageRenderer(
            content:
                HStack(spacing: 1.0) {
                    ForEach(samples) { sample in
                        Capsule()
                            .frame(width: 1, height: self.normalizeSoundLevel(level: sample.decibels))
                    }
                    .foregroundStyle(color)
                }
        )
        
        guard let uiImage = renderer.uiImage else  {
            return Image(systemName: "doc")
        }
        
        return Image(uiImage: uiImage)
    }
    
    
    // MARK: - Variables
    
    private var audioSession: AVAudioSession
    private var recorder: AVAudioRecorder
    private var players: [AudioPlayer]
    private var engine: AVAudioEngine
    private var playbackEngine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var currentFileName: String?
    private var currentTrackLength: Double?
    
    private var bufferInterrupt: Bool = false
    private var audioLengthSamples: AVAudioFramePosition = 0
    private var startDate: Date = Date()
    private var metronome = Metronome.shared
    private var bluetoothDelay: Double = 0.0
    
    private let progressTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    private let meterTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
        
    // MARK: - Functions
    
    private init(
        audioSession: AVAudioSession,
        recorder: AVAudioRecorder,
        players: [AudioPlayer],
        engine: AVAudioEngine,
        playbackEngine: AVAudioEngine,
        mixerNode: AVAudioMixerNode
    ) {
        currentlyPlaying = CurrentValueSubject(nil)
        isRecording = CurrentValueSubject(false)
        playerProgress = CurrentValueSubject(0.0)
        inputSamples = CurrentValueSubject(nil)
        self.audioSession = audioSession
        self.recorder = recorder
        self.players = players
        self.engine = engine
        self.playbackEngine = playbackEngine
        self.mixerNode = mixerNode
        setUpSession()
        setupNotifications()
            
    }
    
    private func setUpSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playAndRecord,
                options: [.allowBluetoothA2DP, .defaultToSpeaker, .mixWithOthers]
            )
           
            try audioSession.setSupportsMultichannelContent(true)
            try audioSession.setActive(true)
            
            guard let inputs = audioSession.availableInputs else {
                assertionFailure("failed to retrieve inputs")
                return
            }
            try audioSession.setPreferredInput(inputs[0])
            
            try audioSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission(completionHandler: { _ in })
        } catch {
            print(error.localizedDescription)
        }
        
    }
        
    private func setupPlayers(for session: Session, stopTimer: Bool = true) throws {
        
        if session.tracks.values.isEmpty {
            return
        }
        
        let sortedTracks = session.tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
            return lhs.length < rhs.length
        }
                
        if currentlyPlaying.value != nil {
            playerProgress.send(0.0)
            for player in players {
                player.player.stop()
                playbackEngine.detach(player.player)
            }
        }
        
        players.removeAll()
        for track in sortedTracks {
            players.append(AudioPlayer(track: track))
        }
        
        for player in players {
            let url = DataPersistenceManager.createDocumentURL(
                withFileName: player.track.fileName,
                fileType: .m4a
            )
            
            let audioFile = try AVAudioFile(forReading: url)
            
            playbackEngine.attach(player.player)
            playbackEngine.connect(player.player,
                                   to: playbackEngine.mainMixerNode,
                                   format: audioFile.processingFormat)
            
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                assertionFailure("Could not assign buffer")
                return
            }
            
            try audioFile.read(into: buffer)

            player.player.scheduleBuffer(buffer,
                                  at: nil,
                                  options: .interrupts,
                                  completionCallbackType: .dataPlayedBack
            ) { _ in
                Task{ @MainActor in
                    if player.player == self.players.last?.player {
                        try self.stopPlayback(stopTimer: stopTimer)
                    }
                }
            }
            player.player.prepare(withFrameCount: AVAudioFrameCount(audioFile.length))
        }
        
        playbackEngine.prepare()
        try playbackEngine.start()
        
        if session.isGlobalSoloActive {
            for player in players {
                if player.track.isSolo {
                    if player.track.isMuted, !player.track.soloOverride {
                        player.player.volume = 0.0
                    } else {
                        player.player.volume = player.track.volume
                    }
                } else {
                    player.player.volume = 0.0
                }
                player.player.pan = player.track.pan
            }
        } else {
            for player in players {
                if player.track.isMuted {
                    player.player.volume = 0.0
                } else {
                    player.player.volume = player.track.volume
                }
                player.player.pan = player.track.pan
            }
        }
    }
    
    private func setupRecorder() throws {
        currentFileName = "Track\(UUID())"
        
        guard let currentFileName else {
            assertionFailure("currentFileName is nil.")
            return
        }
        
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: currentFileName,
            fileType: .m4a
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
        recorder.isMeteringEnabled = true
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2
        
        return CGFloat(level * (40/20))
    }
    
    private func getWaveform(for fileName: String) throws -> [SampleModel] {
        let url = DataPersistenceManager.createDocumentURL(
            withFileName: fileName,
            fileType: .m4a
        )
        
        let audioFile = try AVAudioFile(forReading: url)
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFile.processingFormat,
            frameCapacity: AVAudioFrameCount(audioFile.length)
        ) else {
            assertionFailure("Could not assign buffer")
            return []
        }
        
        try audioFile.read(into: buffer)
        
        guard let floatChannelData = buffer.floatChannelData else {
            return []
        }
        
        let frameLength = Int(buffer.frameLength)
        
        let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))
        
        var result = [SampleModel]()
        
        let chunked = samples.chunked(into: samples.count / Int(UIScreen.main.bounds.width - 300))
        
        for row in chunked {
            var accumulator: Float = 0
            let newRow = row.map { $0 * $0 }
            accumulator = newRow.reduce(0, +)
            let power: Float = accumulator / Float(row.count)
            let decibels = 10 * log10f(power)
            
            result.append(SampleModel(decibels: decibels))
        }
        
        return result
    }
    
    private func startMetering(at startTime: TimeInterval) throws {
        inputSamples.send([])
        
        let delay: Double = startTime - CACurrentMediaTime()
        
        let start: Date = Date() + delay
        self.meterTimerSubscription = self.meterTimer.sink { date in
            let interval = date.timeIntervalSince(start)
            if interval > 0 {
                self.recorder.updateMeters()
                guard var updatedSamples: [SampleModel] = self.inputSamples.value else {
                    return
                }
                let power = self.recorder.averagePower(forChannel: 0)
                if power > -80.0 {
                    updatedSamples.append(SampleModel(decibels: power))
                } else {
                    updatedSamples.append(SampleModel(decibels: -80.0))
                }
                
                if updatedSamples.count > 77 {
                    updatedSamples.removeFirst()
                }
                self.inputSamples.send(updatedSamples)
            }
        }
    }
    
    private func stopMetering() {
        meterTimerSubscription?.cancel()
        inputSamples.send(nil)
    }
    
    private func startTimer(at startTime: TimeInterval) throws {
        
        let delay: Double = startTime - CACurrentMediaTime()
        
        let start: Date = Date() + delay
        
        self.progressTimerSubscription = self.progressTimer.sink { date in
            let interval = date.timeIntervalSince(start)
            if interval > 0 {
                self.playerProgress.send(interval)
            }
        }
    }
    
    private func stopTimer() {
        self.progressTimerSubscription?.cancel()
        self.playerProgress.send(0.0)
    }
    
    private func setupNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        do {
            try stopPlayback(stopTimer: true)
        } catch {
            assertionFailure("Stop playback due to interruption could not be completed")
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        
                
        if audioSession.currentRoute.outputs[0].portType == .builtInSpeaker {
            do {
                try stopPlayback(stopTimer: true)
            } catch {
                assertionFailure("Could not stop playback.")
            }
        } else if audioSession.currentRoute.outputs[0].portType == .bluetoothA2DP {
            bluetoothDelay = 0.15
        }
        if audioSession.currentRoute.outputs[0].portType != .bluetoothA2DP {
            bluetoothDelay = 0.0
        }
        
        guard let inputs = audioSession.availableInputs else {
            assertionFailure("Failed to retrieve inputs.")
            return
        }
        do {
            try audioSession.setPreferredInput(inputs[0])
        } catch {
            assertionFailure("Could not set preferred input.")
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
