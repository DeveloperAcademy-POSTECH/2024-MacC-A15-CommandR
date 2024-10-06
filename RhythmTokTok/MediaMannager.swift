//
//  MediaMannager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AudioKit
import AVFoundation

struct MediaMannager {
    private var bpm = 60
    private var outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("output.wav").path()
    
    func getMediaFile(xmlData: Data) {
        Task {
            let parsedMeasures = await parseMusicXMLData(xmlData: xmlData)
            createMediaFile(from: parsedMeasures.flatMap { $0.notes })
        }
    }
    
    func parseMusicXMLData(xmlData: Data) async -> [Measure]{
        
        let parser = MusicXMLParser()
        let measures = await parser.parseMusicXML(from: xmlData)
        
        // 파싱이 완료된 후에 작업을 처리, 확인용 프린트
//        print("Parsed measures count: \(measures.count)")
//        for measure in measures {
//            for note in measure.notes {
//                print("Pitch: \(note.pitch), Duration: \(note.duration)")
//            }
//        }
//        
        return measures
    }
    
    func filePath(for pitch: String) -> URL? {
        // pitch가 비어있을 경우 `silence`를 반환
        if pitch.isEmpty {
            return Pitch.silence.fileURL
        }
        
        if let pitchEnum = Pitch(rawValue: pitch) {
            return pitchEnum.fileURL
        } else {
            print("Pitch not found in enum: \(pitch)")
            return nil
        }
    }
    
    func getChannelCount(of url: URL) -> AVAudioChannelCount {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            return audioFile.processingFormat.channelCount
        } catch {
            print("Error reading audio file: \(error)")
            return 1 // default to mono if there's an error
        }
    }
    
    func createMediaFile(from notes: [Note]) {
        let outputURL = URL(fileURLWithPath: outputPath)

        do {
            // 오디오 파일을 `.wav`로 생성
            let firstNoteFileURL = filePath(for: notes[0].pitch)!
            let channelCount = getChannelCount(of: firstNoteFileURL)
            let sampleRate = 44100.0
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: channelCount, interleaved: false)
            let file = try AVAudioFile(forWriting: outputURL, settings: format!.settings)
            
            // 모든 음표를 처리
            for note in notes {
                guard let fileURL = filePath(for: note.pitch) else {
                    print("Audio file not found for pitch: \(note.pitch)")
                    continue
                }
                
                let durationInSeconds = Double(note.duration) / Double(bpm) * 60.0
                
                // 오디오 샘플을 로드하여 버퍼에 합성
                try writeSample(fileURL: fileURL, duration: durationInSeconds, format: format!, audioFile: file)
            }
            
            print("Media file created at \(outputURL.path)")
        } catch {
            print("Error creating audio file: \(error)")
        }
    }
    
    // 오디오 샘플을 재생하고 버퍼에 쓰기
    func writeSample(fileURL: URL, duration: Double, format: AVAudioFormat, audioFile: AVAudioFile) throws {
        let sourceAudioFile = try AVAudioFile(forReading: fileURL)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: sourceAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(sourceAudioFile.length)) else {
            print("Failed to create buffer for source file.")
            return
        }
        
        try sourceAudioFile.read(into: buffer)
        
        // 버퍼 볼륨 조정
        let volumeScale: Float32 = 5.0 // 볼륨을 크게 조정하고 싶다면 1.0보다 크게 설정
        for channel in 0..<Int(buffer.format.channelCount) {
            if let channelData = buffer.floatChannelData?[channel] {
                for frame in 0..<Int(buffer.frameLength) {
                    channelData[frame] *= volumeScale
                }
            }
        }
        
        // 버퍼 길이 조절: `duration`에 따라 `frameLength` 설정
        let frameCount = AVAudioFrameCount(duration * format.sampleRate)
        buffer.frameLength = min(frameCount, buffer.frameCapacity)
        
        // 생성된 버퍼를 오디오 파일에 작성
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing audio buffer to file: \(error)")
        }
    }
}
