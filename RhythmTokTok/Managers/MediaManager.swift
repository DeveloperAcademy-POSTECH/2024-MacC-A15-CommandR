//
//  MediaManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation
import AudioToolbox

struct MediaManager {
    private let volumeScale: Float32 = 5.0 // 볼륨
    private let quarterNoteDuration = 24.0
    private var bpm = 60
    private var outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("output2.wav").path()
    private var midiOutputPath = FileManager.default.temporaryDirectory.appendingPathComponent("output2.mid").path() // MIDI 파일 경로

    func getMediaFile(xmlData: Data) async throws -> URL {
        let parsedScore = await parseMusicXMLData(xmlData: xmlData)
        //TODO: main part note만 따로 파싱방법 구상 해야됨
        let notes = parsedScore.parts.flatMap { $0.measures.flatMap { $0.notes } }
        let outputURL = try await createMediaFile(from: notes)

        return outputURL
    }
    
    func getMIDIFile(xmlData: Data) async throws -> URL {
        let parsedScore = await parseMusicXMLData(xmlData: xmlData)
        let notes = parsedScore.parts.flatMap { $0.measures.flatMap { $0.notes } }
        let outputURL = try await createMIDIFile(from: notes)

        return outputURL
    }
    
    func parseMusicXMLData(xmlData: Data) async -> Score {
        let parser = MusicXMLParser()
        let score = await parser.parseMusicXML(from: xmlData)
        
        return score
    }
    
    func filePath(for pitch: String) -> URL? {
        // pitch가 비어있을 경우 `silence`를 반환
        if pitch.isEmpty {
            return Pitch.silence.fileURL
        }
        
        if let pitchEnum = Pitch(rawValue: pitch) {
            return pitchEnum.fileURL
        } else {
            ErrorHandler.handleError(errorMessage: "Pitch not found in enum: \(pitch)")
            return nil
        }
    }
    
    func getChannelCount(of url: URL) -> AVAudioChannelCount {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            return audioFile.processingFormat.channelCount
        } catch {
            ErrorHandler.handleError(error: error)
            return 1
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
                    ErrorHandler.handleError(errorMessage: "Audio file not found for pitch: \(note.pitch)")
                    continue
                }
                
                let durationInSeconds = Double(note.duration) / Double(bpm) * 60.0 / quarterNoteDuration
                try writeSample(fileURL: fileURL, duration: durationInSeconds, format: format!, audioFile: file)
            }
            //print("Media file created at \(outputURL.path)")
            return outputURL
        } catch {
            ErrorHandler.handleError(error: error)
            throw error
        }
    }
    
    // 채널 카운트를 변환하는 함수
    func convertChannelCount(buffer: AVAudioPCMBuffer, to targetChannelCount: AVAudioChannelCount) -> AVAudioPCMBuffer? {
        // 대상 포맷 생성
        guard let targetFormat = AVAudioFormat(
            commonFormat: buffer.format.commonFormat,
            sampleRate: buffer.format.sampleRate,
            channels: targetChannelCount,
            interleaved: buffer.format.isInterleaved)
        else {
            ErrorHandler.handleError(errorMessage: "Failed to create target format for channel conversion.")
            return nil
        }
        
        // AVAudioConverter 생성
        guard let converter = AVAudioConverter(from: buffer.format, to: targetFormat) else {
            ErrorHandler.handleError(errorMessage: "Failed to create AVAudioConverter.")
            return nil
        }
        
        // 변환된 버퍼 생성
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: buffer.frameCapacity) else {
            ErrorHandler.handleError(errorMessage: "Failed to create converted buffer.")
            return nil
        }
        
        var error: NSError?
        
        // 변환 작업 수행
        converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        if let error = error {
            ErrorHandler.handleError(error: error)
            return nil
        }
        
        return convertedBuffer
    }
    
    func writeSample(fileURL: URL, duration: Double, format: AVAudioFormat, audioFile: AVAudioFile) throws {
        let sourceAudioFile = try AVAudioFile(forReading: fileURL)
        
        guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: sourceAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(sourceAudioFile.length)) else {
            ErrorHandler.handleError(errorMessage: "Failed to create buffer for source file.")
            return
        }
        
        try sourceAudioFile.read(into: sourceBuffer)
                
        var bufferToWrite = sourceBuffer
        
        // 채널 카운트가 다를 경우 변환
        if sourceBuffer.format.channelCount != format.channelCount {
            guard let convertedBuffer = convertChannelCount(buffer: sourceBuffer, to: format.channelCount) else {
                ErrorHandler.handleError(errorMessage: "Failed to convert buffer channel count.")
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
            ErrorHandler.handleError(error: error)
            throw error
        }
    }

    // MIDI 파일로 변환하는 기능
    func createMIDIFile(from notes: [Note]) async throws -> URL {
        var musicSequence: MusicSequence? = nil
        var musicTrack: MusicTrack? = nil

        // MusicSequence 생성
        NewMusicSequence(&musicSequence)
        // MusicTrack 추가
        MusicSequenceNewTrack(musicSequence!, &musicTrack)

        let ticksPerQuarterNote: Double = 240 // 사분음표당 틱 수
        var currentTick: MusicTimeStamp = 0

        for note in notes {
            // 음표의 시작 시간을 currentTick으로 설정
            let noteStartTick = MusicTimeStamp(note.startTime)
            print("음 \(note.pitch)\(note.octave), 시작시간 \(note.startTime)")
            // 노트 온 이벤트 생성
            var noteOnMessage = MIDINoteMessage(
                channel: 0,
                note: UInt8(note.pitchNoteNumber()), // pitch를 MIDI note number로 변환
                velocity: 64, // 음의 강도
                releaseVelocity: 0,
                duration: 0
            )

            // 노트 온 이벤트를 트랙에 추가
            MusicTrackNewMIDINoteEvent(musicTrack!, currentTick, &noteOnMessage)

            // 노트의 길이를 MIDI 틱으로 변환
            let noteDurationTicks = note.duration / 12

            // 현재 시간 갱신 (노트의 길이만큼)
            currentTick = noteStartTick + MusicTimeStamp(noteDurationTicks)

            // 노트 오프 이벤트 생성
            var noteOffMessage = MIDINoteMessage(
                channel: 0,
                note: UInt8(note.pitchNoteNumber()), // 동일한 pitch로 오프
                velocity: 0, // 음을 끌 때는 velocity 0
                releaseVelocity: 0,
                duration: 0 // duration은 사용되지 않음
            )

            // 노트 오프 이벤트를 트랙에 추가 (currentTick 시점에서)
            MusicTrackNewMIDINoteEvent(musicTrack!, currentTick, &noteOffMessage)
        }

        // MIDI 파일 경로 설정
        let midiFileURL = URL(fileURLWithPath: midiOutputPath)

        // MusicSequence를 파일로 저장
        let status = MusicSequenceFileCreate(musicSequence!, midiFileURL as CFURL, .midiType, .eraseFile, Int16(ticksPerQuarterNote))
        
        if status != noErr {
            ErrorHandler.handleError(errorMessage: "Failed to create MIDI file. Error code: \(status)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
        print("MIDI file created at: \(midiFileURL)")
        return midiFileURL
    }
}
