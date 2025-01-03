//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation

// MusicXML 파싱 클래스
class MusicXMLParser: NSObject, XMLParserDelegate {
    private var score = Score()           // Score 객체로 파싱된 데이터를 저장
    private var currentMeasure: Measure?
    private var currentNote: Note?
    private var previousNote: Note?
    private var isBackup: Bool = false // 백업 처리 구분
    private var isForward: Bool = false // 포워드 처리 구분
    private var isChord: Bool = false // 화음 처리 구분
    private var currentElement: String = ""
    private var currentVoice: String = "" // 현재 `voice` 값 저장
    private var currentPartId: String? // 파싱할 `part`의 `id` 값
    // TODO: 나중에 변수 최적화 필요, 나중에 ML로 인식하는게 젤 정확할 듯
    // 줄 계산을 위한 값
    private var isPageLayout: Bool = false
    private var scoreWidth: Double = 0 // 악보 가로 길이
    private var scoreHeight: Double = 0 // 악보 세로 높이
    private var leftMargin: Double = 0 // 왼쪽 여백
    private var rightMargin: Double = 0 // 왼쪽 여백
    private var topMargin: Double = 0 // 왼쪽 여백
    private var bottomMargin: Double = 0 // 왼쪽 여백
    private var currentWidth: Double = 0 // 현재 계산된 줄 길이
    private var currentMeasureWidth: Double = 0 // 현재 마디 길이
    private var currentLine: Int = 1 // 현재 줄
    private var newSystem = false // 다음 줄 다음 페이지 표시 태그
    private var currentLocationBarLine: String = "" // barLine 왼/오른쪽 확인용
    private var hasRepeat = false // 도돌이표 작업을 포함한 barLine인지 확인용
    private var isNextLine = false // 바라인으로 마무리 여부 확인용
    private var noteCountToMeasureMaxLength: [Int: Double] = [0: 0]// 음표 갯수별 최대가로 길이관리
    private var noteCountToMeasureMinLength: [Int: Double] = [0: 0]// 음표 갯수별 최소가로 길이관리
    
    // 마디의 duration에 대한 통계
    var measureDurationsCount: [Int: Int] = [:]
    var currentBeat: Int?
    var currentBeatType: Int?

    private var xmlData: Data?
    private var continuation: CheckedContinuation<Score, Never>?  // 파싱 마치고 리턴 관리

    // `async` 메서드로 비동기 파싱 수행
    func parseMusicXML(from xmlData: Data) async -> Score {
        self.xmlData = xmlData
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            let parser = XMLParser(data: xmlData)
            parser.delegate = self
            parser.parse()
        }
        // Title 값이 비어 있는 경우 대비
        if score.title.isEmpty {
            score.title = "제목없음"
        }
        
        return score
    }
    
    // XML 파싱이 완료되었을 때 continuation 호출
    func parserDidEndDocument(_ parser: XMLParser) {
        // 총 음표 갯수를 계산
        var totalNotes = 0

        for part in score.parts {
            for (_, measures) in part.measures {
                for measure in measures {
                    totalNotes += measure.notes.count
                }
            }
        }
        
        continuation?.resume(returning: score)
        continuation = nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        
        // 페이지 레이아웃 설정 값 범위
        if elementName == "page-layout" {
            isPageLayout = true
         }
        
        // MusicXML 내 새로운 줄, 새로운 페이지 표시 태그가 실제 악보와 차이가 커서 바로 사용할 수 없음
        if currentElement == "print" {
            newSystem = true
        }
        
        // barline 태그가 시작될 때
        if elementName == "barline" {
            if let location = attributeDict["location"] {
                currentLocationBarLine = location
            }
        }
        
        // notiations 내에 있는 "tie" 혹은 "tied" 원소를 발견할 시 이를 note의 속성에 추가함
        if elementName == "tie" || elementName == "tied",
            let tieType = attributeDict["type"],
            let note = currentNote {
            currentNote?.tieType = tieType // Store "start" or "stop" in the current note
        }
        
        // repeat 태그가 발견되면 플래그를 true로 설정
        if elementName == "repeat" {
            hasRepeat = true
        }
        
        // 모든 `part`를 파싱하도록 수정
        if elementName == "part", let partId = attributeDict["id"] {
            // 파트 추가: 새로운 Part 객체를 생성하고 Score에 추가
            let newPart = Part(id: partId, measures: [:])
            currentPartId = partId
            score.addPart(newPart)
        }
        
        // 각 파트 내에서 마디(measure) 파싱
        if elementName == "measure", let measureNumberString = attributeDict["number"],
           let measureNumber = Int(measureNumberString), let measureWidthString = attributeDict["width"],
           let measureWidth = Double(measureWidthString) {
            // 현재 마디 길이 저장
            currentMeasureWidth = measureWidth
            // 이전 마디의 currentTimes
            var previousTimes = [1: 0, 2: 0]
//            print("마디 \(measureNumberString)")
            if let lastPart = score.parts.last,
               let lastLine = lastPart.measures.keys.sorted().last, let lastMeasure = lastPart.measures[lastLine]?.last {
//                print("마지막 틱 \(lastMeasure.currentTimes)")
                previousTimes = lastMeasure.currentTimes
            }
            
            currentMeasure = Measure(number: measureNumber, notes: [],
                                     currentTimes: previousTimes, startTime: previousTimes[previousNote?.staff ?? 1] ?? 0,
                                     beats: 0, beatType: 0)  // 두 개의 스태프 관리
        }

        // 노트(note) 태그를 만났을 때
        if elementName == "note" {
//            if attributeDict["chord"] != nil {
//                print("화성 발견")
//                isChord = true
//            }
            currentNote = Note(pitch: "", duration: 0, octave: 0, type: "", voice: 0, staff: 1, startTime: 0)
        } else if elementName == "backup" {
            // 백업 처리
            isBackup = true
        } else if elementName == "forward" {
            isForward = true
        } else if elementName == "chord" {
            isChord = true
        }
        
        // 쉼표 처리: `rest` 태그를 만났을 때
        if elementName == "rest", currentNote != nil {
            currentNote?.isRest = true // 쉼표 여부를 나타내는 플래그 설정
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Note 관련 정보 파싱
        parseNoteAttributes(trimmedString)
        
        // Page layout 및 system layout 관련 정보 파싱
        if let currentScale = Double(trimmedString), isPageLayout || newSystem {
            parseLayoutAttributes(currentScale)
        }
    }

    private func parseNoteAttributes(_ trimmedString: String) {
        switch currentElement {
        case "divisions":
            if let divisionValue = Int(trimmedString) {
                score.divisions = divisionValue
            }
        case "step":
            currentNote?.pitch = trimmedString
        case "octave":
            if let octave = Int(trimmedString) {
                currentNote?.octave = octave
            }
        case "duration":
            parseDuration(trimmedString)
        case "voice":
            if let voice = Int(trimmedString), var note = currentNote {
                note.voice = voice
                currentNote = note
            }
        case "type":
            currentNote?.type = trimmedString
        case "staff":
            if let staff = Int(trimmedString), var note = currentNote {
                note.staff = staff
                currentNote = note
            }
        case "alter":
            if let alter = Int(trimmedString), var note = currentNote {
                note.accidental = alter == 1 ? .sharp : .flat
                currentNote = note
            }
            
        case "beats":
            if let beats = Int(trimmedString), let _ = currentMeasure {
                currentBeat = beats
                currentMeasure?.beats = beats
            }
            
        case "beat-type":
            if let beatType = Int(trimmedString), let _ = currentMeasure {
                currentBeatType = beatType
                currentMeasure?.beatType = beatType
            }
        default:
            break
        }
    }
    
    private func parseDuration(_ value: String) {
        if let duration = Int(value) {
            if isBackup {
                currentMeasure?.backupNoteTime(duration: duration, staff: previousNote?.staff ?? 1)
                isBackup = false
            } else if isForward {
                currentMeasure?.forwardNoteTime(duration: duration, staff: previousNote?.staff ?? 1)
                isForward = false
            } else {
                currentNote?.duration = duration
            }
        }
    }

    private func parseLayoutAttributes(_ currentScale: Double) {
        switch currentElement {
        case "page-height":
            scoreHeight = currentScale
        case "page-width":
            scoreWidth = currentScale
        case "left-margin":
            if isPageLayout {
                leftMargin = currentScale
            } else if newSystem {
                currentWidth += currentScale
            }
        case "right-margin":
            if isPageLayout {
                rightMargin = currentScale
            } else if newSystem {
                currentWidth += currentScale
            }
        case "top-margin":
            topMargin = currentScale
        case "bottom-margin":
            bottomMargin = currentScale
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "page-layout" {
            scoreWidth -= leftMargin
            scoreWidth -= rightMargin
            scoreHeight -= topMargin
            scoreHeight -= bottomMargin
            isPageLayout = false
         }
        
        if currentElement == "print" {
            newSystem = false
        }
        
        // TODO: 나중에 도돌이표 처리를 위한 로직 필요
        // barline 태그가 끝났을 때
        if elementName == "barline" {
            if currentLocationBarLine == "right", !hasRepeat {
                // repeat 태그가 없는 경우, 바라인이 오른쪽에 위치할 때 다음 줄 처리
                isNextLine = true
            }
            // 값 초기화
            currentLocationBarLine = ""
            hasRepeat = false
        }
  
        if elementName == "note", let note = currentNote, currentMeasure != nil {
            // 마디에 음표 추가
            if isChord {
                if let previousNote {
                    currentMeasure?.addChordNote(note, previousNote: previousNote)
                    isChord = false
                }
            } else {
                currentMeasure?.addNote(note)
                previousNote = note
            }
            currentNote = nil
        }
        
        if elementName == "measure", var measure = currentMeasure {
            // 부족한 박자를 채워 넣는 보정 작업
//            for staffKey in 1...2 {
//                let filteredNotes = currentMeasure!.notes.filter { $0.staff == staffKey }
//                // 마디 내에 위치한 모든 노트들의 duration의 sum을 구함
//                let totalNotesDuration = filteredNotes.reduce(0) { $0 + $1.duration }
//                // 마디의 duration에 대한 통계를 유지
//                measureDurationsCount[totalNotesDuration, default: 0] += 1
//                
//                // 마디에 저장된 비트 혹은 통계를 통해 현 마디에 있어야 할 길이를 구함
//                let measureFullDuration = getMeasureFullDuration()
//                
//                // 마디 내에서 부족한 길이를 구함
//                let remainingDuration = measureFullDuration - totalNotesDuration
//                
//                // 부족한 길이만큼 쉼표를 생성하여 마디에 추가함
//                if remainingDuration > 0 {
//                    currentNote = Note(pitch: "", duration: remainingDuration, octave: 0, type: "", voice: 1, staff: staffKey, startTime: 0, isRest: true)
//                    currentNote?.isRest = true
//                    currentMeasure?.addNote(currentNote!)
//                    measure = currentMeasure!
//                }
//            }
               
            // TODO: 마디 줄 파싱 로직 더 좋은 방법 구상 필요
            // 초기값 최댓값으로 설정
            var minWidth = scoreWidth

            if let width = noteCountToMeasureMinLength[measure.notes.count] {
                minWidth = width
            } else {
                noteCountToMeasureMinLength[measure.notes.count] = currentMeasureWidth
            }

            if let maxWidth = noteCountToMeasureMaxLength[measure.notes.count] {
                // 최솟값이랑 80이상 차이나는 길이는 특이 케이스로 간주하고 사용안함
                if maxWidth < currentMeasureWidth && currentMeasureWidth < minWidth + 80 {
                    noteCountToMeasureMaxLength[measure.notes.count] = currentMeasureWidth
                } else {
                    // 기존 음표 갯수에 따른 길이 보다 작으면 보정가로 크기로 보정
//                    print("보정 최대 길이: \(maxWidth), 현재 길이: \(currentMeasureWidth), 차이: \(maxWidth - currentMeasureWidth)")
                    currentMeasureWidth = maxWidth
                }
            } else {
                noteCountToMeasureMaxLength[measure.notes.count] = currentMeasureWidth
            }

            // 현재 마디 길이를 더한 값이 악보 길이보다 크면 다음 줄로 계산
            if scoreWidth > currentWidth + currentMeasureWidth {
                currentWidth += currentMeasureWidth
            } else {
                currentLine += 1
                currentWidth = currentMeasureWidth
            }
            
            
//            print("현재 마디 포함 길이: \(currentWidth), 악보 전체 길이: \(scoreWidth)")
//            print("현재 마디 번호: \(measure.number),현재 마디 줄: \(currentLine), 마디 포함 음수: \(measure.notes.count)")
            score.addMeasure(to: currentPartId!, measure: currentMeasure!, lineNumber: currentLine)
            currentMeasure = nil
            // 바라인이 들어가서 끝난 마디면 다음 마디부터 다음 라인 적용되게 만듦
            if isNextLine {
                currentLine += 1
                currentWidth = 0
                isNextLine = false
            }
//            print("생성")
        }
        
        if elementName == "part" {
            currentPartId = nil // 파트가 끝났으므로 currentPartId를 nil로 설정
        }
        
        currentElement = ""
    }
    
    private func getMeasureFullDuration() -> Int {
        // currentBeat, currentBeatType이 있다면 그것을 기준으로 삼기
        if let currentBeat = currentBeat, let currentBeatType = currentBeatType {
            let measureFullDuration = self.score.divisions * currentBeat * (4 / currentBeatType)
            return measureFullDuration
        } else {
            // currentBeat, currentBeatType,
            // 현재까지 가장 많이 발생한 duration에 해당하는 값을 기준으로 삼아 보정작업을 진행함
            measureDurationsCount.removeValue(forKey: 0)
            let measureFullDuration = measureDurationsCount.max(by: { $0.value < $1.value })?.key ?? 0
            return measureFullDuration
        }
    }
}
