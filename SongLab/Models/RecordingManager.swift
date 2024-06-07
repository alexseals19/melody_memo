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

protocol RecordingManager {
    var delegate: RecordingManagerDelegate? { get set }
    func startTracking()
    func stopTracking()
    func playRecording(id: UUID)
    func stopPlayback()
    func setUpSession()
    func getRecordings() -> [Recording]
}

class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager(session: AVAudioSession(), recorder: AVAudioRecorder(), player: AVAudioPlayer())
    
    weak var delegate: RecordingManagerDelegate?
    
    func startTracking() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = url.appendingPathComponent("Session " + "\(recordings.count + 1)")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 32000,
                AVNumberOfChannelsKey: 1,
            ]
            
            recordings.insert(Recording(name: fileName.lastPathComponent, date: Date().formatted(date: .numeric, time: .omitted), url: fileName), at: 0)
            
            recorder = try AVAudioRecorder(url: fileName, settings: settings)
            
            recorder.record()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopTracking() {
        self.recorder.stop()
        delegate?.recordingManagerDidUpdate(recordings: recordings)
    }
    
    func playRecording(id: UUID) {
        do {
            let recording = recordings.filter { $0.id == id }
            
            player = try AVAudioPlayer(contentsOf: recording[0].url)
            
            player.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopPlayback() {
        player.stop()
    }
    
    func setUpSession() {
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
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
    private var recordings: [Recording] = []
    
    // MARK: - Functions
    
    private init(session: AVAudioSession, recorder: AVAudioRecorder, player: AVAudioPlayer) {
        self.session = session
        self.recorder = recorder
        self.player = player
        loadRecordingsFromDisk()
    }
    
    private func loadRecordingsFromDisk() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
                        
            for i in result {
                recordings.append(Recording(name: i.lastPathComponent, date: Date().formatted(date: .numeric, time: .omitted), url: i))
            }
            
            recordings = recordings.sorted { (lhs: Recording, rhs: Recording) -> Bool in
                return lhs.name > rhs.name
            }
            
            delegate?.recordingManagerDidUpdate(recordings: recordings)
        } catch {
            print(error.localizedDescription)
        }
    }
}

class MockRecordingManager: RecordingManager {
    
    weak var delegate: RecordingManagerDelegate?
    
    func startTracking() {}
    
    func stopTracking() {}
    
    func playRecording(id: UUID) {}
    
    func stopPlayback() {}
    
    func setUpSession() {}
        
    func getRecordings() -> [Recording] {return []}
}
