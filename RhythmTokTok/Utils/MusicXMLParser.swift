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
    private var currentElement: String = ""
    private var currentVoice: String = "" // 현재 `voice` 값 저장
    private var currentPartId: String? // 파싱할 `part`의 `id` 값
    // 줄 계산을 위한 값
    private var isPageLayout: Bool = false
    private var scoreWidth: Double = 0 // 악보 가로 길이
    private var scoreHeight: Double = 0 // 악보 세로 높이
    private var leftMargin: Double = 0 // 왼쪽 여백
    private var rightMargin: Double = 0 // 왼쪽 여백
    private var topMargin: Double = 0 // 왼쪽 여백
    private var bottomMargin: Double = 0 // 왼쪽 여백
    private var currentWidth: Double = 0 // 현재 계산된 줄 길이
    private var currentLine: Int = 1 // 현재 줄
    private var newSystem = false // 다음 줄 다음 페이지 표시 태그
    private var currentLocationBarLine: String = "" // barLine 왼/오른쪽 확인용
    private var hasRepeat = false // 도돌이표 작업을 포함한 barLine인지 확인용
    private var isNextLine = false // 바라인으로 마무리 여부 확인용
    private var firstMeasureOffset: Double = 50 // 임시 첫마디 길이 보정값

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
    }
    
    // XML 파싱이 완료되었을 때 continuation 호출
    func parserDidEndDocument(_ parser: XMLParser) {
        // 총 음표 갯수를 계산
        let totalNotes = score.parts.reduce(0) { total, part in
            total + part.measures.reduce(0) { measureTotal, measure in
                measureTotal + measure.notes.count
            }
        }
        
        print("Parsing finished. Total parts: \(score.parts.count), Total Notes: \(totalNotes)")
        print("악보 크기 : 가로 \(scoreWidth), 세로\(scoreHeight)")
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
            print("############ 시스템 설정 할거임 ###########")
            newSystem = true
        }
        
        // barline 태그가 시작될 때
        if elementName == "barline" {
            if let location = attributeDict["location"] {
                currentLocationBarLine = location
            }
        }
        
        // repeat 태그가 발견되면 플래그를 true로 설정
        if elementName == "repeat" {
            hasRepeat = true
        }
        
        // 모든 `part`를 파싱하도록 수정
        if elementName == "part", let partId = attributeDict["id"] {
            // 파트 추가: 새로운 Part 객체를 생성하고 Score에 추가
            let newPart = Part(id: partId, measures: [])
            currentPartId = partId
            score.addPart(newPart)
        }
        
        // 각 파트 내에서 마디(measure) 파싱
        if elementName == "measure", let measureNumberString = attributeDict["number"],
           let measureNumber = Int(measureNumberString), let measureWidthString = attributeDict["width"],
           let measureWidth = Double(measureWidthString) {
            // 현재 마디 길이를 더한 값이 악보 길이보다 크면 다음 줄로 계산
            if scoreWidth > currentWidth + measureWidth {
                currentWidth += measureWidth
            } else {
                print("~~~~~~~~~~~~~~~~~~~~~~~~~~구분선~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                currentLine += 1
                currentWidth = measureWidth + firstMeasureOffset // 첫마디 보정값 적용
            }
            // 이전 마디의 currentTimes
            let previousTimes = score.parts.last?.measures.last?.currentTimes ?? [1: 0, 2: 0]
            
            currentMeasure = Measure(number: measureNumber, notes: [], currentTimes: previousTimes)  // 두 개의 스태프 관리
        }

        // 노트(note) 태그를 만났을 때
        if elementName == "note" {
            currentNote = Note(pitch: "", duration: 0, octave: 0, type: "", voice: 0, staff: 0, startTime: 0)
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
            if let duration = Int(trimmedString) {
                currentNote?.duration = duration
            }
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
        default:
            break
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
            currentMeasure?.addNote(note)
            currentNote = nil
        }
        
        if elementName == "measure", let measure = currentMeasure {
            print("현재 마디 포함 길이: \(currentWidth), 악보 전체 길이: \(scoreWidth)")
            print("현재 마디 번호: \(measure.number),현재 마디 줄: \(currentLine), 마디 포함 음수: \(measure.notes.count)")
            score.addMeasure(to: currentPartId!, measure: measure)
            currentMeasure = nil
            // 바라인이 들어가서 끝난 마디면 다음 마디부터 다음 라인 적용되게 만듦
            if isNextLine {
                print("||||||||||||||||||||||||")
                currentLine += 1
                currentWidth = 0
                isNextLine = false
            }
        }
        
        if elementName == "part" {
            currentPartId = nil // 파트가 끝났으므로 currentPartId를 nil로 설정
        }
        
        currentElement = ""
    }
}
