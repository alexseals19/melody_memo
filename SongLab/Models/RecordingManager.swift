//
//  RecordingManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import AVKit

protocol RecordingManagerDelegate: AnyObject {
    func recordingManagerDidUpdate(recordings: [Recording])
}

@MainActor
protocol RecordingManager {
    var delegate: RecordingManagerDelegate? { get set }
    func startTracking()
    func stopTracking() async
    func startPlayback(id: UUID)
    func stopPlayback()
    func setUpSession()
    func getRecordings() -> [Recording]
}

@MainActor
class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager(
        session: AVAudioSession(),
        recorder: AVAudioRecorder(),
        player: AVAudioPlayer(),
        currentRecordingName: URL(filePath: ""),
        fileNameWithExtension: URL(filePath: ""),
        dataPersistenceManager: DataPersistenceManager())
    
    weak var delegate: RecordingManagerDelegate?
    
    func startTracking() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            currentRecordingName = url.appendingPathComponent("Session " + "\(recordings.count + 1).m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 32000,
                AVNumberOfChannelsKey: 1
            ]
            
            recorder = try AVAudioRecorder(url: currentRecordingName, settings: settings)
            
            recorder.record()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopTracking() async {
        self.recorder.stop()
        do {
            let audioAsset = AVURLAsset(url: currentRecordingName, options: nil)
            let duration = try await audioAsset.load(.duration)
            let durationInSeconds = CMTimeGetSeconds(duration)
            let name = currentRecordingName.lastPathComponent.replacingOccurrences(of: ".m4a", with: "")
            recordings.insert(Recording(
                                name: name,
                                date: Date(),
                                url: currentRecordingName,
                                length: .seconds(durationInSeconds),
                                id: UUID()), at: 0)
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try DataPersistenceManager.save(recordings, to: "recordings")
        } catch {
            print(error.localizedDescription)
        }
        delegate?.recordingManagerDidUpdate(recordings: recordings)
    }
    
    func startPlayback(id: UUID) {
        do {
            if let recording = recordings.first(where: { $0.id == id }) {
                print("\(recording.url)")
                player = try AVAudioPlayer(contentsOf: recording.url)
                player.play()
            }
            
            
        } catch {
            print(error.localizedDescription)
            print("Error is here")
        }
    }
    
    func stopPlayback() {
        player.stop()
    }
    
    func setUpSession() {
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetoothA2DP, .allowBluetooth, .defaultToSpeaker])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getRecordings() -> [Recording] {
        return recordings
    }
    
    // MARK: - Variables
    
    private var session: AVAudioSession
    private var recorder: AVAudioRecorder
    private var player: AVAudioPlayer
    private var isRecording = false
    private var currentRecordingName: URL
    private var fileNameWithExtension: URL
    private var dataPersistenceManager: DataPersistenceManager
    
    private var recordings: [Recording] = []
    
    // MARK: - Functions
    
    private init(
        session: AVAudioSession,
        recorder: AVAudioRecorder,
        player: AVAudioPlayer,
        currentRecordingName: URL,
        fileNameWithExtension: URL,
        dataPersistenceManager: DataPersistenceManager) {
            self.session = session
            self.recorder = recorder
            self.player = player
            self.currentRecordingName = currentRecordingName
            self.fileNameWithExtension = fileNameWithExtension
            self.dataPersistenceManager = dataPersistenceManager
            loadRecordingsFromDisk()
    }
    
    private func loadRecordingsFromDisk() {
        do {
            recordings = try DataPersistenceManager.retrieve([Recording].self, from: "recordings")
            
            delegate?.recordingManagerDidUpdate(recordings: recordings)
        } catch {}
    }
}

class MockRecordingManager: RecordingManager {
    
    weak var delegate: RecordingManagerDelegate?
    
    func startTracking() {}
    
    func stopTracking() async {}
    
    func startPlayback(id: UUID) {}
    
    func stopPlayback() {}
    
    func setUpSession() {}
        
    func getRecordings() -> [Recording] {return []}
}
