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
    var lastPlayheadPosition: CurrentValueSubject<Double, Never> { get }
    var inputSamples: CurrentValueSubject<[SampleModel]?, Never> { get }
    func startTracking(for session: Session?) async throws
    func stopTracking(for session: Session?) async throws
    func startPlayback(for session: Session, at time: Double) throws
    func stopPlayback(stopTimer: Bool) throws
    func removeTrack(track: Track)
    func toggleMute(for tracks: [Track])
    func setTrackVolume(for track: Track)
    func setTrackPan(for track: Track)
    func getImage(for fileName: String, colorScheme: ColorScheme) throws -> UIImage
    func updateCurrentlyPlaying(_ session: Session)
    func updatePlayheadPosition(position: Double)
    func stopTimer(willReset: Bool)
    func setLastPlayheadPosition(_ position: Double)
    func loopIndicatorChangedPosition() throws
    func restartPlayback(from position: Double) throws
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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var currentlyPlaying: CurrentValueSubject<Session?, Never>
    var isRecording: CurrentValueSubject<Bool, Never>
    var playerProgress: CurrentValueSubject<Double, Never>
    var lastPlayheadPosition: CurrentValueSubject<Double, Never>
    var inputSamples: CurrentValueSubject<[SampleModel]?, Never>
    var progressTimerSubscription: AnyCancellable?
    var meterTimerSubscription: AnyCancellable?
    var loopTimerSubscription: AnyCancellable?
    
    func startTracking(for session: Session?) async throws {
                
        try setupRecorder()
        
        if await metronome.isArmed {
            try await metronome.prepare()
        }
        
        isRecording.send(true)
        
        let startTime = CACurrentMediaTime() + 0.5
        
        if let session, !session.tracks.isEmpty {
            try setupPlayers(for: session, at: 0, stopTimer: false)
            
            currentlyPlaying.send(session)
            
            if !session.tracks.isEmpty {
                for player in players {
                    await player.player.play(at: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: startTime + metronome.countInDelay)))
                }
            }
        }
        
        if await metronome.isArmed {
            await metronome.start(at: startTime)
        }
        await recorder.record(atTime: (startTime + metronome.countInDelay + bluetoothDelay))
        
        try await startMetering(at: (startTime +  metronome.countInDelay + bluetoothDelay))
        try await startTimer(at: (startTime +  metronome.countInDelay + bluetoothDelay))
    }
    
    func stopTracking(for session: Session?) async throws {
        defer { currentFileName = nil }
        
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
        
        if durationInSeconds < Double(trackLengthLimit) {
            try DataPersistenceManager.delete(currentFileName, fileType: .m4a)
            return
        }
        
        guard let lightWaveforomData = try getImage(for: currentFileName, colorScheme: .dark).pngData() else {
            return
        }
        guard let darkWaveformData = try getImage(for: currentFileName, colorScheme: .light).pngData() else {
            return
        }
        
        var name = "Track 1"
        
        if let session {
            name = "Track \(session.absoluteTrackCount + 1)"
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
            soloOverride: false,
            darkWaveformImage: darkWaveformData,
            lightWaveformImage: lightWaveforomData
        )
        
        if let session {
            var updatedSession = session
            updatedSession.tracks[track.id] = track
            updatedSession.absoluteTrackCount += 1
            
            if track.length > updatedSession.length {
                updatedSession.length = track.length
            }
            
            try DefaultRecordingManager.shared.saveSession(updatedSession)
        } else {
            
            let sessionBpm = await metronome.isArmed ? metronome.bpm.value : 0
            
            let session = Session(
                name: "Session \(DefaultRecordingManager.shared.absoluteSessionCount + 1)",
                date: Date(),
                length: durationInSeconds,
                tracks: [track.id : track],
                absoluteTrackCount: 1,
                sessionBpm: sessionBpm,
                isUsingGlobalBpm: false,
                id: UUID(),
                isGlobalSoloActive: false,
                isLoopActive: false,
                leftIndicatorFraction: 0.0,
                rightIndicatorFraction: 1.0,
                loopReferenceTrack: track
            )
            try DefaultRecordingManager.shared.saveSession(session)
            DefaultRecordingManager.shared.incrementAbsoluteSessionCount()
        }
        
    }
    
    func startPlayback(for session: Session, at time: Double) throws {
        try setupPlayers(for: session, at: time)
        
        let startTimeInSeconds = CACurrentMediaTime() + 0.25
        
        let startTime = AVAudioTime(
            hostTime: AVAudioTime.hostTime(
                forSeconds: startTimeInSeconds
            )
        )
        
        currentlyPlaying.send(session)
        
        for player in players {
            player.player.play(at: startTime)
        }
        
        loopTimer(isFinalCheck: false)
        try startTimer(at: startTimeInSeconds + 0.03)
    }
    
    func stopPlayback(stopTimer: Bool) throws {
        
        for player in players {
            player.player.stop()
        }
        playbackEngine.stop()
        players.removeAll()
        if stopTimer {
            self.stopTimer(willReset: true)
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
    
    @MainActor func getImage(for fileName: String, colorScheme: ColorScheme) throws -> UIImage {
        var samples = try getWaveform(for: fileName)
        
        var color: Color {
            colorScheme == .dark ? .white : .black
        }
        
        let sortedSamples = samples.sorted { (lhs: SampleModel, rhs: SampleModel) -> Bool in
            return lhs.decibels > rhs.decibels
        }
        
        guard let maxSample = sortedSamples.first else {
            return UIImage(imageLiteralResourceName: "waveform")
        }
        
        guard let minSample = sortedSamples.last else {
            return UIImage(imageLiteralResourceName: "waveform")
        }
        
        let range = maxSample.decibels - minSample.decibels
        let normalizingValue = minSample.decibels * -1
        
        for index in 0..<samples.count {
            samples[index].decibels += normalizingValue
            let sampleFraction = samples[index].decibels / range
            
            samples[index].decibels = 70 * sampleFraction
        }
                
        let renderer = ImageRenderer(
            content:
                HStack(spacing: 1.0) {
                    ForEach(samples) { sample in
                        Capsule()
                            .frame(width: 1, height: max(CGFloat(sample.decibels), 1))
                    }
                    .foregroundStyle(color)
                }
        )
        
        guard let uiImage = renderer.uiImage else  {
            return UIImage(imageLiteralResourceName: "waveform")
        }
        
        return uiImage
    }
    
    func updateCurrentlyPlaying(_ session: Session) {
        currentlyPlaying.send(session)
        if session.isLoopActive, playerProgress.value < session.rightIndicatorTime {
            loopTimer(isFinalCheck: false)
        } else if !session.isLoopActive {
            loopTimerSubscription?.cancel()
        }
    }
    
    func updatePlayheadPosition(position: Double) {
        playerProgress.send(position)
    }
    
    func stopTimer(willReset: Bool) {
        if willReset {
            loopTimerSubscription?.cancel()
            progressTimerSubscription?.cancel()
            playerProgress.send(0.0)
            lastPlayheadPosition.send(0.0)
        } else {
            lastPlayheadPosition.send(playerProgress.value)
            progressTimerSubscription?.cancel()
        }
    }
    
    func setLastPlayheadPosition(_ position: Double) {
        lastPlayheadPosition.send(position)
    }
    
    func loopIndicatorChangedPosition() throws {
        guard let session = currentlyPlaying.value else {
            return
        }
        if playerProgress.value > session.rightIndicatorTime, session.isLoopActive {
            loopTimerSubscription?.cancel()
        }
    }
    
    func restartPlayback(from position: Double) throws {
        
        guard let session = currentlyPlaying.value else {
            return
        }
        
        try stopPlayback(stopTimer: false)
        try startPlayback(for: session, at: position)
        
        if position > session.rightIndicatorTime {
            loopTimerSubscription?.cancel()
        }
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
    private var currentPort: AVAudioSession.Port = .builtInSpeaker
    
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
        lastPlayheadPosition = CurrentValueSubject(0.0)
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
    
    private func startNextLoop(for session: Session, from time: Double, at startTimeInSeconds: Double) throws {
        
        let firstPlayerIndex = session.tracks.count
        
        try setupPlayers(for: session, at: session.leftIndicatorTime, firstPlayerIndex: firstPlayerIndex, isInLoop: true)
                
        let startTime = AVAudioTime(
            hostTime: AVAudioTime.hostTime(
                forSeconds: startTimeInSeconds
            )
        )
        
        for index in firstPlayerIndex ..< players.count {
            players[index].player.play(at: startTime)
        }
    }
        
    private func setupPlayers(for session: Session, at time: Double, firstPlayerIndex: Int = 0, stopTimer: Bool = true, isInLoop: Bool = false) throws {
        
        if session.tracks.values.isEmpty {
            return
        }
        
        let sortedTracks = session.tracks.values.sorted { (lhs: Track, rhs: Track) -> Bool in
            return lhs.length < rhs.length
        }
                
        if currentlyPlaying.value != nil, currentlyPlaying.value != session {
            for player in players {
                player.player.stop()
                playbackEngine.detach(player.player)
            }
            players.removeAll()
        }
        
        for track in sortedTracks {
            players.append(AudioPlayer(track: track))
        }
                
        for player in players {
            
            if !player.player.isPlaying {
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
                
                var offset = AVAudioFramePosition(playerProgress.value * audioFile.processingFormat.sampleRate)
                if isInLoop {
                    offset = AVAudioFramePosition(time * audioFile.processingFormat.sampleRate)
                }
                let audioLengthSamples: AVAudioFramePosition = audioFile.length
                var seekFrame: AVAudioFramePosition = offset
                seekFrame = max(offset, 0)
                seekFrame = min(offset, audioLengthSamples)
                let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)

                if frameCount > 0 {
                    player.player.scheduleSegment(audioFile,
                                                  startingFrame: seekFrame,
                                                  frameCount: frameCount,
                                                  at: nil,
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
            }
            
        }
        
        if currentlyPlaying.value == nil {
            playbackEngine.prepare()
            try playbackEngine.start()
        }
        
        if session.isGlobalSoloActive {
            for player in players {
                if !player.player.isPlaying {
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
            }
        } else {
            for player in players {
                if !player.player.isPlaying {
                    if player.track.isMuted {
                        player.player.volume = 0.0
                    } else {
                        player.player.volume = player.track.volume
                    }
                    player.player.pan = player.track.pan
                }
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
        
        let chunked = samples.chunked(into: samples.count / 220)
        
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
    
    private func loopTimer(isFinalCheck: Bool) {
        
        guard let session = currentlyPlaying.value else {
            return
        }
                
        var nextCheck: Double {
            if isFinalCheck {
                return session.rightIndicatorTime - playerProgress.value
            } else {
                return session.rightIndicatorTime - playerProgress.value - 0.5
            }
        }
        
        let loopTimer = Timer.publish(every: nextCheck, on: .main, in: .common).autoconnect()
        
        loopTimerSubscription = loopTimer.sink { date in
            if isFinalCheck {
                guard let session = self.currentlyPlaying.value else {
                    return
                }
                if session.isLoopActive {
                    self.loopTimerSubscription?.cancel()
                    self.playerProgress.send(session.leftIndicatorTime)
                    do {
                        try self.startTimer(at: CACurrentMediaTime())
                    } catch {}
                    for _ in 0 ..< session.tracks.count {
                        self.players[0].player.stop()
                        self.playbackEngine.detach(self.players[0].player)
                        self.players.remove(at: 0)
                    }
                    self.loopTimer(isFinalCheck: false)
                }
            } else {
                guard let session = self.currentlyPlaying.value else {
                    return
                }
                if session.isLoopActive {
                    do {
                        let nextLoopInterval = session.rightIndicatorTime - self.playerProgress.value
                        try self.startNextLoop(for: session, from: session.leftIndicatorTime, at: CACurrentMediaTime() + nextLoopInterval)
                    } catch {}
                    self.loopTimer(isFinalCheck: true)
                }
            }
        }
    }
    
    private func startTimer(at startTime: TimeInterval) throws {
        
        let delay: Double = startTime - CACurrentMediaTime()
        let start: Date = Date() + delay
        let startPosition = playerProgress.value
        
        self.progressTimerSubscription = self.progressTimer.sink { date in
            let interval = date.timeIntervalSince(start)
            if interval > 0 {
                self.playerProgress.send(interval + startPosition)
                self.lastPlayheadPosition.send(interval + startPosition)
            } else {
                self.playerProgress.send(startPosition)
                self.lastPlayheadPosition.send(startPosition)
            }
        }
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
        
        let newPort = audioSession.currentRoute.outputs[0].portType
                
        if newPort == .builtInSpeaker, (currentPort == .bluetoothA2DP || currentPort == .headphones)  {
            do {
                try stopPlayback(stopTimer: true)
            } catch {
                assertionFailure("Could not stop playback.")
            }
        } else if newPort == .bluetoothA2DP {
            bluetoothDelay = 0.15
        }
        if newPort != .bluetoothA2DP {
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
        
        currentPort = newPort
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
