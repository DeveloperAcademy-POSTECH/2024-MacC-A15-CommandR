//
//  MediaMannager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AudioKit
import AVFoundation

struct MediaMannager {
    private let volumeScale: Float32 = 5.0 // 볼륨
    private let quarterNoteDuration = 1.0 // 예: 1초를 의미할 경우
    private var bpm = 60
    private var outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("output2.wav").path()
    
    func getMediaFile(xmlData: Data) async throws -> URL {
        let parsedMeasures = await parseMusicXMLData(xmlData: xmlData)
        let outputURL = try await createMediaFile(from: parsedMeasures.flatMap { $0.notes })
        return outputURL
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
    
    func createMediaFile(from notes: [Note]) async throws -> URL {
        let outputURL = URL(fileURLWithPath: outputPath)

        do {
            let firstNoteFileURL = filePath(for: notes[0].pitch)!
            let channelCount = getChannelCount(of: firstNoteFileURL)
            let sampleRate = 44100.0
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: channelCount, interleaved: false)
            let file = try AVAudioFile(forWriting: outputURL, settings: format!.settings)

            for note in notes {
                guard let fileURL = filePath(for: note.pitch) else {
                    print("Audio file not found for pitch: \(note.pitch), duration \(note.duration)")
                    continue
                }
                
                let durationInSeconds = Double(note.duration) / Double(bpm) * 60.0 / quarterNoteDuration

                try writeSample(fileURL: fileURL, duration: durationInSeconds, format: format!, audioFile: file)
            }
            
            print("Media file created at \(outputURL.path)")
            return outputURL
        } catch {
            print("Error creating audio file: \(error)")
            throw error
        }
    }
    
    // 채널 카운트를 변환하는 함수
    func convertChannelCount(buffer: AVAudioPCMBuffer, to targetChannelCount: AVAudioChannelCount) -> AVAudioPCMBuffer? {
        // 대상 포맷 생성
        guard let targetFormat = AVAudioFormat(commonFormat: buffer.format.commonFormat, sampleRate: buffer.format.sampleRate, channels: targetChannelCount, interleaved: buffer.format.isInterleaved) else {
            print("Failed to create target format for channel conversion.")
            return nil
        }
        
        // AVAudioConverter 생성
        guard let converter = AVAudioConverter(from: buffer.format, to: targetFormat) else {
            print("Failed to create AVAudioConverter.")
            return nil
        }
        
        // 변환된 버퍼 생성
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: buffer.frameCapacity) else {
            print("Failed to create converted buffer.")
            return nil
        }
        
        var error: NSError?
        
        // 변환 작업 수행
        converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        if let error = error {
            print("Error during conversion: \(error)")
            return nil
        }
        
        return convertedBuffer
    }
    
    func writeSample(fileURL: URL, duration: Double, format: AVAudioFormat, audioFile: AVAudioFile) throws {
        let sourceAudioFile = try AVAudioFile(forReading: fileURL)
        
        guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: sourceAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(sourceAudioFile.length)) else {
            print("Failed to create buffer for source file.")
            return
        }
        
        try sourceAudioFile.read(into: sourceBuffer)
                
        var bufferToWrite = sourceBuffer
        
        // 채널 카운트가 다를 경우 변환
        if sourceBuffer.format.channelCount != format.channelCount {
            guard let convertedBuffer = convertChannelCount(buffer: sourceBuffer, to: format.channelCount) else {
                print("Failed to convert buffer channel count.")
                return
            }
            bufferToWrite = convertedBuffer
        }
        
        // 볼륨 스케일 적용
        for channel in 0..<Int(bufferToWrite.format.channelCount) {
            if let channelData = bufferToWrite.floatChannelData?[channel] {
                for frame in 0..<Int(bufferToWrite.frameLength) {
                    channelData[frame] *= volumeScale
                }
            }
        }
        
        // 변환된 버퍼의 프레임 길이 조정
        let frameCount = AVAudioFrameCount(duration * format.sampleRate)
        bufferToWrite.frameLength = min(frameCount, bufferToWrite.frameCapacity)
                
        // 버퍼를 오디오 파일에 쓰기
        do {
            try audioFile.write(from: bufferToWrite)
        } catch {
            print("Error writing audio buffer to file: \(error)")
            throw error
        }
    }

    
    //파일 존재하면 삭제
    func deleteFile(URL: URL) {
        let fileManager = FileManager.default
        
        // 기존 파일이 있다면 삭제
        if fileManager.fileExists(atPath: URL.path) {
            do {
                try fileManager.removeItem(at: URL)
            } catch {
                print("기존 파일 삭제 오류: \(error)")
            }
        }
    }
    
    //파일권한 쓰기 확인
    func checkWriteable(path: String) {
        let fileManager = FileManager.default

        // 쓰기 권한 확인
        if fileManager.isWritableFile(atPath: path) {
            print("파일에 쓰기 권한이 있습니다.")
        } else {
            print("파일에 쓰기 권한이 없습니다.")
        }
    }
    
    //파일권한 읽기 확인
    func checkReadable(path: String) {
        let fileManager = FileManager.default

        // 읽기 권한 확인
        if fileManager.isReadableFile(atPath: path) {
            print("파일에 읽기 권한이 있습니다.")
        } else {
            print("파일에 읽기 권한이 없습니다.")
        }
    }
}
