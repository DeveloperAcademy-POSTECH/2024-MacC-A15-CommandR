//
//  MediaManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation
import AudioToolbox

class MediaManager {
    var currentScore: Score? {
        didSet {
            // currentScore가 변경될 때 tempoBPM을 업데이트
            tempoBPM = Double(currentScore?.bpm ?? 60)
        }
    }

    private let volumeScale: Float32 = 5.0 // 볼륨
    private let standardDivision: Double = 480.0  // 기준 division 값
    private lazy var tempoBPM: Double = Double(currentScore?.bpm ?? 60)
    private var midiOutputPath = FileManager.default
        .temporaryDirectory.appendingPathComponent("midifile.mid").path() // MIDI 멜로디 파일 경로
    private var metronomeOutputPath = FileManager.default
        .temporaryDirectory.appendingPathComponent("metronome.mid").path() // MIDI 매트로놈 파일 경로
    private var currentPart: Part?
    
    func getScore(xmlData: Data) async throws -> Score {
        let parsedScore = await parseMusicXMLData(xmlData: xmlData)
        
        return parsedScore
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
            return 1
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
            let startTime = convertTicksToTime(convertTick: measures[currentIndex].startTime,
                                               division: division)

            return startTime
        }
        
        return 0
    }
    
    // 매트로놈 MIDI파일
    func getMetronomeMIDIFile(parsedScore: Score) async throws -> URL {
        let outputURL = try await createMetronomeMIDIFile(division: Double(parsedScore.divisions))
        
        return outputURL
    }
 
    func getTotalPartMIDIFile(parsedScore: Score) async throws -> URL {
        print("parsedScore: \(parsedScore.parts)")
        
        
        let notes = parsedScore.parts.flatMap { part in
            part.measures
                .sorted(by: { $0.key < $1.key })
                .flatMap { (_, measures) in
                measures.flatMap { $0.notes }
            }
        }
        let outputURL = try await createMIDIFile(from: notes, division: Double(parsedScore.divisions), soundOption: currentScore?.soundOption ?? .melody)
        
        return outputURL
    }
    
    func getPartMIDIFile(part: Part, divisions: Int, soundKey: Double,isChordEnabled: Bool = false) async throws -> URL {
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
        
        let outputURL = try await createMIDIFile(from: notes, division: Double(divisions), soundOption: currentScore?.soundOption ?? .melody, soundKey: soundKey)
        return outputURL
    }
    
    // 미리 듣기 MIDI 파일 생성
    func getPartPreviewMIDIFile(currnetScore: Score, divisions: Int, isChordEnabled: Bool = false) async throws -> URL {
        let part = currnetScore.parts.last!
        var notes: [Note] = []
        
        // 마디 번호 3번까지만 필터링
        let filteredMeasures = part.measures
            .filter { $0.key <= 3 } // 마디 번호가 3번 이하만 선택
            .sorted(by: { $0.key < $1.key }) // 정렬
        
        // 선택된 마디의 노트 추출
        if !isChordEnabled {
            notes = filteredMeasures.flatMap { (_, measures) in
                measures.flatMap { $0.notes.filter { $0.staff == 1 } } // 높은음자리표만 선택
            }
        } else {
            notes = filteredMeasures.flatMap { (_, measures) in
                measures.flatMap { $0.notes } // 모든 노트 선택
            }
        }
        
        let outputURL = try await createMIDIFile(from: notes, division: Double(divisions), soundKey: currnetScore.soundKeyOption)
        return outputURL
    }
    
    func getClipMIDIFile(part: Part, divisions: Int, startNumber: Int, endNumber: Int) async throws -> URL? {
        if let adjustedNotes = getAdjustedNotes(from: part, startNumber: startNumber, endNumber: endNumber) {
            let outputURL = try await createMIDIFile(from: adjustedNotes, division: Double(divisions), soundOption: currentScore?.soundOption ?? .melody)
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
    
    private func handleNoteTie(_ note: Note, _ tieStartNotes: inout [String: Note]) -> Note? {
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
                    let modifiedNote = tieStartNotes[noteKey]!
                    tieStartNotes.removeValue(forKey: noteKey)
                    return modifiedNote
                }
            }
        }
        return nil
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
            if note.tieType != nil {
                if let modifiedNote = handleNoteTie(note, &tieStartNotes) {
                    // tieType이 end일 때 바꿔넣을 note가 return됨
                    // note 바꿔넣기
                    note = modifiedNote
                } else {
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
    
    func getMetronomeHapticSequence() async -> [Double] {
        var metronomehapticSequence: [Double] = []
        let beatInterval = 60.0 / tempoBPM
        
        // 160박까지 매트로놈 생성
        for i in 0..<160 {
            let time = Double(i) * beatInterval
            metronomehapticSequence.append(time)
        }
        
        return metronomehapticSequence
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
        let totalHapticSequence = try await getHapticSequence(part: part, divisions: divisions)
        
        if let startIndex = totalHapticSequence.firstIndex(where: { $0 > pauseTime }) {
            var clipHaticSequence = Array(totalHapticSequence[startIndex...])
            let diff = totalHapticSequence[startIndex] - pauseTime
            clipHaticSequence = clipHaticSequence.map { $0 - (totalHapticSequence[startIndex] - diff) }
            
            return clipHaticSequence
        }
        
        return []
    }
    
    // 일시정지 시 매트로놈 햅틱 시퀀스 재산출
    func getClipPauseMetronomeHapticSequence(pauseTime: TimeInterval) async -> [TimeInterval] {
        
        let totalHapticSequence = await getMetronomeHapticSequence()
        
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

    // MARK: - MIDI 파일 생성 부분
    // MIDI 파일로 변환하는 기능
    func createMIDIFile(
        from notes: [Note],
        division: Double,
        soundOption: SoundSetting = .melody, // 기본값 제공
        soundKey: Double = 0.0
    ) async throws -> URL {
        var musicSequence: MusicSequence?
        var musicTrack: MusicTrack?
        var tempoTrack: MusicTrack?
        var tieStartNotes: [String: Note] = [:]

        // MusicSequence 생성
        NewMusicSequence(&musicSequence)

        // MusicTrack 추가
        MusicSequenceNewTrack(musicSequence!, &musicTrack)

        // 템포 트랙 생성
        MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack)

        // 기준 division과의 보정 값
        let divisionCorrectionFactor = standardDivision / division
        let tempoBPM = Double(currentScore?.bpm ?? 60)
        let correctedTempoBPM = tempoBPM * standardDivision

        // 템포 설정
        MusicTrackNewExtendedTempoEvent(tempoTrack!, 0, correctedTempoBPM)

        for index in 0..<notes.count {
            var note = notes[index]

            // 붙임줄 관련 처리
            if let tieType = note.tieType {
                if let modifiedNote = handleNoteTie(note, &tieStartNotes) {
                    note = modifiedNote
                } else {
                    continue
                }
            }

            // 쉼표 처리
            if note.isRest { continue }

            // 노트 시작 시간 계산
            let noteStartTick = MusicTimeStamp(Double(note.startTime) * divisionCorrectionFactor)
            
            let noteNumber: UInt8 = {
                if soundOption == .melody || soundOption == .melodyBeat {
                    return UInt8(note.pitchNoteNumber(with: soundKey)) // 사운드 옵션에 따라 MIDI 노트 번호 설정
                } else {
                    return 60 // 기본값
                }
            }()

            // 노트 온 이벤트 생성
            var noteOnMessage = MIDINoteMessage(
                channel: 0,
                note: noteNumber,
                velocity: soundOption == .mute ? 1 : 64,
                releaseVelocity: 0,
                duration: 0
            )

            // 노트 온 이벤트 추가
            MusicTrackNewMIDINoteEvent(musicTrack!, noteStartTick, &noteOnMessage)

            // 노트 길이 계산
            let noteDurationTicks = MusicTimeStamp(Double(soundOption == .melody || soundOption == .melodyBeat
                                                          ? note.duration
                                                          : 0) * divisionCorrectionFactor)

            // 노트 오프 이벤트 생성
            var noteOffMessage = MIDINoteMessage(
                channel: 0,
                note: noteNumber, // 동일한 pitch로 오프
                velocity: 0,
                releaseVelocity: 0,
                duration: 0
            )

            // 노트 오프 이벤트 추가
            MusicTrackNewMIDINoteEvent(musicTrack!, noteStartTick + MusicTimeStamp(noteDurationTicks), &noteOffMessage)
        }

        // MIDI 파일 저장
        let midiFileURL = URL(fileURLWithPath: midiOutputPath)
        let status = MusicSequenceFileCreate(musicSequence!, midiFileURL as CFURL,
                                             .midiType, .eraseFile, Int16(standardDivision))

        if status != noErr {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }

        return midiFileURL
    }
    
    // MARK: 매트로놈 MIDI파일 생성
    func createMetronomeMIDIFile(division: Double) async throws -> URL {
        var musicSequence: MusicSequence?
        var musicTrack: MusicTrack?
        var tempoTrack: MusicTrack?

        // MusicSequence 생성
        NewMusicSequence(&musicSequence)

        // Metronome MusicTrack 생성
        MusicSequenceNewTrack(musicSequence!, &musicTrack)

        // TempoTrack 생성 및 보정된 템포 설정
        MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack)
        let tempoBPM = Double(currentScore?.bpm ?? 60)
        let correctedTempoBPM = tempoBPM * standardDivision
        MusicTrackNewExtendedTempoEvent(tempoTrack!, 0, correctedTempoBPM)

        // 드럼 사운드 추가
        let noteVelocity: UInt8 = 60
        let noteOn: UInt8 = 60
        let beatInterval = MusicTimeStamp(standardDivision) // 바뀐 부분: BPM에 맞춘 4분음표 간격 계산

        // 보정된 전체 길이 설정
        let totalDurationInBeats = MusicTimeStamp(160.0 * standardDivision) // 바뀐 부분: BPM에 따른 전체 길이 계산

        // 여러 박자를 반복하여 드럼 노트 추가
        for beat in stride(from: 0.0, to: totalDurationInBeats, by: beatInterval) {
            // 노트 온 이벤트 생성 및 추가
            var noteOnMessage = MIDINoteMessage(
                channel: 9,
                note: noteOn,
                velocity: noteVelocity,
                releaseVelocity: 0,
                duration: Float(beatInterval)
            )
            MusicTrackNewMIDINoteEvent(musicTrack!, beat, &noteOnMessage)
            
            // 노트 오프 이벤트 생성 및 추가
            let noteOffTime = beat + beatInterval // 오프 시간 조정
            var noteOffMessage = MIDINoteMessage(
                channel: 9,
                note: noteOn,
                velocity: 0, // 0으로 설정해 음을 끔
                releaseVelocity: 0,
                duration: 0
            )
            MusicTrackNewMIDINoteEvent(musicTrack!, noteOffTime, &noteOffMessage)
        }

        // MIDI 파일 저장
        let destinationURL = URL(fileURLWithPath: metronomeOutputPath)
        let status = MusicSequenceFileCreate(musicSequence!, destinationURL as CFURL, .midiType, .eraseFile, Int16(standardDivision))

        if status != noErr {
            ErrorHandler.handleError(error: "Failed to create Metronome MIDI file. Error code: \(status)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }

        return destinationURL
    }
}
