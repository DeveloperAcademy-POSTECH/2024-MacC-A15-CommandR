//
//  MediaManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation
import AudioToolbox

class MediaManager {
    private let volumeScale: Float32 = 5.0 // 볼륨
    private let standardDivision: Double = 480.0  // 기준 division 값
    private var tempoBPM: Double = Double(UserSettingData.shared.getBPM())
    private var outputPath = FileManager.default
        .temporaryDirectory.appendingPathComponent("output2.wav").path()
    private var midiOutputPath = FileManager.default
        .temporaryDirectory.appendingPathComponent("midifile.mid").path() // MIDI 파일 경로
    private var currentPart: Part?

    func getScore(xmlData: Data) async throws -> Score {
        let parsedScore = await parseMusicXMLData(xmlData: xmlData)
        
        return parsedScore
    }
    
    func getMediaFile(parsedScore: Score) async throws -> URL {
        let notes = parsedScore.parts.flatMap { part in
            part.measures
                .sorted(by: { $0.key < $1.key })
                .flatMap { (_, measures) in
                measures.flatMap { $0.notes }
            }
        }
        let outputURL = try await createMediaFile(from: notes)

        return outputURL
    }
    
    // TODO: 뷰모델로 빼도 될 것 같다
    func setCurrentPart(part: Part, division: Double) {
        self.currentPart = part
    }
    
    func getMainPartMeasureCount(score: Score) -> Int {
        guard let currentPart = score.parts.last else {
            return 0
        }
        
        let measures = currentPart.measures
            .sorted(by: { $0.key < $1.key })
            .flatMap { (_, measures) in
                measures
            }
        
        return measures.last?.number ?? 0
    }
    
    // TODO: 나중에 시간 및 마디 번호 관리용 프로퍼티를 만들어서 최적화 필요
    func getCurrentMeasureNumber(currentTime: Double, division: Double) -> Int {
        guard let currentPart = currentPart else {
            return 0
        }

        let measures = currentPart.measures
            .sorted(by: { $0.key < $1.key })
            .flatMap { (_, measures) in
                measures
            }
        
        var previousStartTime = 0.0

        for (index, measure) in measures.enumerated() {
            let startTime = convertTicksToTime(convertTick: measure.startTime, division: division)

            if currentTime >= previousStartTime && currentTime < startTime {
                return measures[max(0, index - 1)].number
            }

            previousStartTime = startTime
        }

        // 마지막 마디 반환
        return measures.last?.number ?? -1
    }
    
    // 이전마디 시작틱
    func getMeasureStartTime(currentMeasure: Int, division: Double) -> TimeInterval {
        guard let currentPart = currentPart else { return 0 }
        
        let measures = currentPart.measures
            .sorted(by: { $0.key < $1.key })
            .flatMap { $0.value }
        
        if let currentIndex = measures.firstIndex(where: { $0.number == currentMeasure }) {
//            print("찾았다 인덱스: \(currentIndex), ")
            let startTime = convertTicksToTime(convertTick: measures[currentIndex].startTime,
                                               division: division)

            return startTime
        }
        
        return 0
    }
    
    func getTotalPartMIDIFile(parsedScore: Score) async throws -> URL {
        let notes = parsedScore.parts.flatMap { part in
            part.measures
                .sorted(by: { $0.key < $1.key })
                .flatMap { (_, measures) in
                measures.flatMap { $0.notes }
            }
        }
        let outputURL = try await createMIDIFile(from: notes, division: Double(parsedScore.divisions))
        
        return outputURL
    }
    
    func getPartMIDIFile(part: Part, divisions: Int, isChordEnabled: Bool = false) async throws -> URL {
        var notes: [Note] = []
        
        // 현재 무조건적으로 if 문 타게 해놨음, 높은음자리표만 나오게
        if !isChordEnabled {
            notes = part.measures
                .sorted(by: { $0.key < $1.key })
                .flatMap { (_, measures) in
                measures.flatMap { $0.notes.filter { $0.staff == 1 } }
            }
        } else {
            notes = part.measures
                .sorted(by: { $0.key < $1.key })
                .flatMap { (_, measures) in
                measures.flatMap { $0.notes }
            }
        }
        
        let outputURL = try await createMIDIFile(from: notes, division: Double(divisions))
        return outputURL
    }
    
    func getClipMIDIFile(part: Part, divisions: Int, startNumber: Int, endNumber: Int) async throws -> URL? {
        if let adjustedNotes = getAdjustedNotes(from: part, startNumber: startNumber, endNumber: endNumber) {
            let outputURL = try await createMIDIFile(from: adjustedNotes, division: Double(divisions))
            return outputURL
        } else {
            return nil
        }
    }
    
    private func convertTicksToTime(convertTick: Int, division: Double) -> Double {
        return (Double(convertTick) / division) * 60 / tempoBPM
    }
    
    // MARK: - XML 파싱 부분
    private func parseMusicXMLData(xmlData: Data) async -> Score {
        let parser = MusicXMLParser()
        let score = await parser.parseMusicXML(from: xmlData)
        
        return score
    }
    
    private func handleNoteTie(_ note: inout Note, _ tieStartNotes: inout [String: Note]) {
        let noteKey = "\(note.staff)-\(note.pitch)-\(note.octave)-\(note.voice)" // Unique key
        if let tieType = note.tieType {
            if tieType == "start" {
                // "tie start"일 때는 노트를 저장만 해주기
                // 키값이 이미 저장되어 있다면 붙임줄이 여러 개가 이어지고 있는 상황임
                if tieStartNotes[noteKey] != nil {
                    tieStartNotes[noteKey]!.duration += note.duration
                } else {
                    // 붙임줄이 처음 시작될 때에 키값을 저장해둠
                    tieStartNotes[noteKey] = note
                }
            } else if tieType == "stop" {
                // 매칭하는 "tie start"를 찾고, 그 노트의 duration을 연장한 뒤 add
                // 그 노트를 사용하여 MIDI파일에 붙임
                if tieStartNotes[noteKey] != nil {
                    tieStartNotes[noteKey]!.duration += note.duration
                    note = tieStartNotes[noteKey]!
                    tieStartNotes.removeValue(forKey: noteKey)
                }
            }
        }
    }
    
    
    // MARK: - 햅틱 시퀀스 생성 부분
    func createHapticSequence(from notes: [Note], division: Double) -> [Double] {
        var haptics: [Double] = []
        var tieStartNotes: [String: Note] = [:]
        
        for index in 0..<notes.count {
            var note = notes[index]
            
            if note.pitch.isEmpty {
                continue
            }
            
            // 붙임줄 관련 처리 로직
            if let tieType = note.tieType {
                handleNoteTie(&note, &tieStartNotes)
                if tieType == "start" {
                    continue
                }
            }
            
            let startTimeInSeconds = convertTicksToTime(convertTick: note.startTime, division: division)
            haptics.append(startTimeInSeconds)
        }
        // 시간순으로 정렬
        haptics.sort()
//        print("최종 햅틱 배열: \(haptics)")
        return haptics
    }
    
    func getHapticSequence(part: Part, divisions: Int) async throws -> [Double] {
        let notes = part.measures.flatMap { (_, measures) in
            measures.flatMap { $0.notes.filter { $0.staff == 1 } }
        }
        let hapticSequence = createHapticSequence(from: notes, division: Double(divisions))

        return hapticSequence
    }
    
    func getClipMeasureHapticSequence(part: Part, divisions: Int, startNumber: Int, endNumber: Int) async throws -> [Double] {
        
        if let adjustedNotes = getAdjustedNotes(from: part, startNumber: startNumber, endNumber: endNumber) {
            // 조정된 음표들을 기반으로 햅틱 시퀀스 생성
            let hapticSequence = createHapticSequence(from: adjustedNotes, division: Double(divisions))
            
            return hapticSequence
        } else {
            return []
        }
    }
    
    // 일시정지 시 햅틱 시퀀스 재산출
    func getClipPauseHapticSequence(part: Part, divisions: Int, pauseTime: TimeInterval) async throws -> [TimeInterval] {
        var totalHapticSequence = try await getHapticSequence(part: part, divisions: divisions)
        
        if let startIndex = totalHapticSequence.firstIndex(where: { $0 > pauseTime }) {
            var clipHaticSequence = Array(totalHapticSequence[startIndex...])
            let diff = totalHapticSequence[startIndex] - pauseTime
            clipHaticSequence = clipHaticSequence.map { $0 - (totalHapticSequence[startIndex] - diff) }
            
            return clipHaticSequence
        }
        
        return []
    }
    
    // MARK: - 구간 노트 파싱 부분
    func getAdjustedNotes(from part: Part, startNumber: Int, endNumber: Int, staff: Int = 1) -> [Note]? {
        // 필터링과 정렬된 노트들을 가져옴
        let notes: [Note] = part.measures
            .sorted(by: { $0.key < $1.key }) // measureNumber 순서대로 정렬
            .flatMap { (_, measures) in
                measures.filter { measure in
                    // measure.number를 사용하여 범위 내의 마디만 필터링
                    measure.number >= startNumber && measure.number <= endNumber
                }.flatMap { $0.notes.filter { $0.staff == staff } } // 해당 스태프의 노트만 필터링
            }

        // 첫 번째 노트가 있는지 확인 후, startTime 조정
        guard let firstNote = notes.first else {
            return nil
        }

        // 첫 번째 음표의 startTime을 기준으로 나머지 음표들의 startTime을 조정
        let adjustedNotes = notes.map { note -> Note in
            var adjustedNote = note
            adjustedNote.startTime -= firstNote.startTime
            return adjustedNote
        }

        return adjustedNotes
    }

    // MARK: - WAV 파일 생성 부분
    private func filePath(for pitch: String) -> URL? {
        // pitch가 비어있을 경우 `silence`를 반환
        if pitch.isEmpty {
            return Pitch.silence.fileURL
        }
        
        if let pitchEnum = Pitch(rawValue: pitch) {
            return pitchEnum.fileURL
        } else {
            ErrorHandler.handleError(error: "Pitch not found in enum: \(pitch)")
            return nil
        }
    }
    
    private func getChannelCount(of url: URL) -> AVAudioChannelCount {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            return audioFile.processingFormat.channelCount
        } catch {
            ErrorHandler.handleError(error: error)
            return 1
        }
    }
    
    private func createMediaFile(from notes: [Note]) async throws -> URL {
        let outputURL = URL(fileURLWithPath: outputPath)

        do {
            let firstNoteFileURL = filePath(for: notes[0].pitch)!
            let channelCount = getChannelCount(of: firstNoteFileURL)
            let sampleRate = 44100.0
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                       sampleRate: sampleRate, channels: channelCount, interleaved: false)
            let file = try AVAudioFile(forWriting: outputURL, settings: format!.settings)

            for note in notes {
                guard let fileURL = filePath(for: note.pitch) else {
                    ErrorHandler.handleError(error: "Audio file not found for pitch: \(note.pitch)")
                    continue
                }
                
                let durationInSeconds = Double(note.duration) / Double(tempoBPM) * 60.0 / 24
                try writeSample(fileURL: fileURL, duration: durationInSeconds, format: format!, audioFile: file)
            }
            
            return outputURL
        } catch {
            ErrorHandler.handleError(error: error)
            throw error
        }
    }
    
    // 채널 카운트를 변환하는 함수
    private func convertChannelCount(buffer: AVAudioPCMBuffer,
                                     to targetChannelCount: AVAudioChannelCount) -> AVAudioPCMBuffer? {
        // 대상 포맷 생성
        guard let targetFormat = AVAudioFormat(
            commonFormat: buffer.format.commonFormat,
            sampleRate: buffer.format.sampleRate,
            channels: targetChannelCount,
            interleaved: buffer.format.isInterleaved)
        else {
            ErrorHandler.handleError(error: "Failed to create target format for channel conversion.")
            return nil
        }
        
        // AVAudioConverter 생성
        guard let converter = AVAudioConverter(from: buffer.format, to: targetFormat) else {
            ErrorHandler.handleError(error: "Failed to create AVAudioConverter.")
            return nil
        }
        
        // 변환된 버퍼 생성
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat,
                                                     frameCapacity: buffer.frameCapacity) else {
            ErrorHandler.handleError(error: "Failed to create converted buffer.")
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
    
    private func writeSample(fileURL: URL, duration: Double, format: AVAudioFormat, audioFile: AVAudioFile) throws {
        let sourceAudioFile = try AVAudioFile(forReading: fileURL)
        
        guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: sourceAudioFile.processingFormat,
                                                  frameCapacity: AVAudioFrameCount(sourceAudioFile.length)) else {
            ErrorHandler.handleError(error: "Failed to create buffer for source file.")
            return
        }
        
        try sourceAudioFile.read(into: sourceBuffer)
                
        var bufferToWrite = sourceBuffer
        
        // 채널 카운트가 다를 경우 변환
        if sourceBuffer.format.channelCount != format.channelCount {
            guard let convertedBuffer = convertChannelCount(buffer: sourceBuffer, to: format.channelCount) else {
                ErrorHandler.handleError(error: "Failed to convert buffer channel count.")
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

    // MARK: - MIDI 파일 생성 부분
    // MIDI 파일로 변환하는 기능
    func createMIDIFile(from notes: [Note], division: Double) async throws -> URL {
        var musicSequence: MusicSequence?
        var musicTrack: MusicTrack?
        var tempoTrack: MusicTrack?
        var tieStartNotes: [String: Note] = [:]
        
        // MusicSequence 생성
        NewMusicSequence(&musicSequence)
        
        // MusicTrack 추가
        MusicSequenceNewTrack(musicSequence!, &musicTrack)
        
        // 템포 트랙을 따로 생성
        MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack)
        
        // 기준 division과의 보정 값
        let divisionCorrectionFactor = standardDivision / division
        tempoBPM = Double(UserSettingData.shared.getBPM())
        let correctedTempoBPM = tempoBPM * standardDivision
        // 템포 설정 (0 번째 시점에서 보정된 템포 이벤트 추가)
        MusicTrackNewExtendedTempoEvent(tempoTrack!, 0, correctedTempoBPM)
        
        for index in 0..<notes.count {
            var note = notes[index]
            
            // 붙임줄 관련 처리 로직
            if let tieType = note.tieType {
                handleNoteTie(&note, &tieStartNotes)
                if tieType == "start" {
                    continue
                }
            }
    
            if note.isRest {
//                print("쉼표: \(note.duration) ticks, 시작시간 \(note.startTime)")
                continue // 쉼표는 MIDI 이벤트를 생성하지 않으므로 다음 음표로 넘어감
            }
            
            // 음표의 시작 시간을 note.startTime으로 설정
            let noteStartTick = MusicTimeStamp(Double(note.startTime) * divisionCorrectionFactor)
//            print("음 \(note.pitch)\(note.octave), 시작시간 \(noteStartTick)")
            
            // 노트 온 이벤트 생성
            var noteOnMessage = MIDINoteMessage(
                channel: 0,
                note: UInt8(UserSettingData.shared.getSoundOption() == .melody ?
                            note.pitchNoteNumber() :
                            60), // pitch를 MIDI note number로 변환
                velocity: UserSettingData.shared.getSoundOption() == .mute ? 1 : 64, // 음의 강도 (나중에 수정 가능)
                releaseVelocity: 0,
                duration: 0
            )
            
            // 노트 온 이벤트를 트랙에 추가
            MusicTrackNewMIDINoteEvent(musicTrack!, noteStartTick, &noteOnMessage)
            
            // 노트의 길이를 MIDI 틱으로 변환
            let noteDurationTicks = MusicTimeStamp(Double(UserSettingData.shared.getSoundOption() == .melody ?
                                                          note.duration :
                                                            0) * divisionCorrectionFactor)
 
            // 노트 오프 이벤트 생성
            var noteOffMessage = MIDINoteMessage(
                channel: 0,
                note: UInt8(note.pitchNoteNumber()), // 동일한 pitch로 오프
                velocity: 0, // 음을 끌 때는 velocity 0
                releaseVelocity: 0,
                duration: 0 // duration은 사용되지 않음
            )
            
            // 노트 오프 이벤트를 트랙에 추가 (note의 시작시간 + duration 시점에서)
            MusicTrackNewMIDINoteEvent(musicTrack!, noteStartTick + MusicTimeStamp(noteDurationTicks), &noteOffMessage)
        }
        
        // MIDI 파일 경로 설정
        let midiFileURL = URL(fileURLWithPath: midiOutputPath)
        // MusicSequence를 파일로 저장
        let status = MusicSequenceFileCreate(musicSequence!, midiFileURL as CFURL,
                                             .midiType, .eraseFile, Int16(standardDivision))
        
        if status != noErr {
            ErrorHandler.handleError(error: "Failed to create MIDI file. Error code: \(status)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
        print("MIDI file created at: \(midiFileURL)")
        return midiFileURL
    }
}
