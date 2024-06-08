//
//  RecordingManager.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import Foundation
import AVFoundation

protocol RecordingManagerDelegate: AnyObject {
    func recordingManagerDidUpdate(recordings: [Recording])
}

@MainActor
protocol RecordingManager {
    var delegate: RecordingManagerDelegate? { get set }
    func startTracking()
    func stopTracking() async
    func startPlayback(recording: Recording)
    func stopPlayback()
    func removeRecording(with name: String)
    func getRecordings() -> [Recording]
}

@MainActor
class DefaultRecordingManager: RecordingManager {
    
    // MARK: - API
    
    static let shared = DefaultRecordingManager(
        recordSession: AVAudioSession(),
        recorder: AVAudioRecorder(),
        player: AVAudioPlayer(),
        engine: AVAudioEngine(),
        mixerNode: AVAudioMixerNode(),
        file: AVAudioFile(),
        dataPersistenceManager: DataPersistenceManager())
    
    weak var delegate: RecordingManagerDelegate?
    
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
            guard let inputs = recordSession.availableInputs else {
                assertionFailure("inputs")
                return
            }
            try recordSession.setPreferredInput(inputs[0])
            recorder = try AVAudioRecorder(url: url, settings: settings)
            
            recorder.record()
        } catch {
            print(error.localizedDescription)
        }
        
//        do {
//            let tapNode: AVAudioNode = mixerNode
//            let format = tapNode.outputFormat(forBus: 0)
//            
//            print("\(format.settings)")
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
//            guard let inputs = recordSession.inputDataSources else {
//                assertionFailure("inputs")
//                return
//            }
//            try recordSession.setInputDataSource(inputs[0])
//            tapNode.installTap(onBus: 0, bufferSize: 1024, format: format, block: { (buffer, time ) in
//                try? self.file.write(from: buffer)
//            })
//            
//            try engine.start()
//            recorder.record()
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
    func stopTracking() async {
//        engine.inputNode.removeTap(onBus: 0)
//        engine.stop()
        
        
        self.recorder.stop()
        
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
    
    func startPlayback(recording: Recording) {
        print(recordSession.availableInputs)
        
        let url = DataPersistenceManager.createDocumentURL(withFileName: recording.name, fileType: .caf)
        do {
//            guard let inputs = recordSession. else {
//                assertionFailure("inputs")
//                return
//            }
            try recordSession.overrideOutputAudioPort(.none)
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("\(url)")
            print(error.localizedDescription)
        }
    }
    
    func stopPlayback() {
        player.stop()
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
        delegate?.recordingManagerDidUpdate(recordings: recordings)
    }
    
    func getRecordings() -> [Recording] {
        return recordings
    }
    
    // MARK: - Variables
    
    private var recordSession: AVAudioSession
    private var recorder: AVAudioRecorder
    private var player: AVAudioPlayer
    private var engine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode
    private var file: AVAudioFile
    private var isRecording = false
    private var currentFileName: String?
    private var dataPersistenceManager: DataPersistenceManager
    
    private var recordings: [Recording] = []
    
    // MARK: - Functions
    
    private init(
        recordSession: AVAudioSession,
        recorder: AVAudioRecorder,
        player: AVAudioPlayer,
        engine: AVAudioEngine,
        mixerNode: AVAudioMixerNode,
        file: AVAudioFile,
        dataPersistenceManager: DataPersistenceManager) {
            self.recordSession = recordSession
            self.recorder = recorder
            self.player = player
            self.engine = engine
            self.mixerNode = mixerNode
            self.file = file
            self.dataPersistenceManager = dataPersistenceManager
            loadRecordingsFromDisk()
            setUpSession()
            setUpEngine()
    }
    
    private func setUpSession() {
        do {
            recordSession = AVAudioSession.sharedInstance()
            try recordSession.setCategory(.multiRoute)
//            print(recordSession.availableInputs)
            guard let inputs = recordSession.availableInputs else {
                assertionFailure("inputs")
                return
            }
            try recordSession.setPreferredInput(inputs[0])
//            try recordSession.overrideOutputAudioPort(.speaker)
            try recordSession.setSupportsMultichannelContent(true)
            try recordSession.setActive(true)
            
        } catch {
            print(error.localizedDescription)
            print("Recording")
        }
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
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 2, interleaved: false)
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
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
    
    func startPlayback(recording: Recording) {}
    
    func stopPlayback() {}
    
    func removeRecording(with name: String) {}
            
    func getRecordings() -> [Recording] {return []}
}
