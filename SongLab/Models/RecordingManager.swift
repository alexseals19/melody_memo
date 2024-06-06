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
    func setUpSession()
    func getRecordings() -> [Recording]
}

class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager(session: AVAudioSession(), recorder: AVAudioRecorder())
    
    weak var delegate: RecordingManagerDelegate?
    
    func startTracking() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = url.appendingPathComponent("Session \(self.recordings.count + 1).m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recorder = try AVAudioRecorder(url: fileName, settings: settings)
            
            recorder.record()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopTracking() {
        self.recorder.stop()
        print(self.recordings.count)
        recordings.removeAll()
        loadRecordingsFromDisk()
        for i in recordings {
            print(i.name)
        }
        print(self.recordings.count)
    }
    
    func playRecording(id: UUID) {}
    
    func setUpSession() {
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)
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
    private var isRecording = false
    private var recordings: [Recording] = []
    
    // MARK: - Functions
    
    private init(session: AVAudioSession, recorder: AVAudioRecorder) {
        self.session = session
        self.recorder = recorder
        loadRecordingsFromDisk()
    }
    
    private func loadRecordingsFromDisk() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
                        
            for i in result {
                recordings.append(Recording(name: i.relativeString, date: Date().formatted(date: .numeric, time: .omitted), url: i))
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
    
    func setUpSession() {}
        
    func getRecordings() -> [Recording] {return []}
}
