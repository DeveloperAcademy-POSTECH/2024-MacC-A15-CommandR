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
    // 줄 계산을 위한 값
    private var isPageLayout: Bool = false
    private var scoreWidth: Double = 0 // 악보 가로 길이
    private var scoreHeight: Double = 0 // 악보 세로 높이
    private var leftMargin: Double = 0 // 왼쪽 여백
    private var rightMargin: Double = 0 // 왼쪽 여백
    private var topMargin: Double = 0 // 왼쪽 여백
    private var bottomMargin: Double = 0 // 왼쪽 여백
    private var currentWidth: Int = 0 // 현재 계산된 줄 길이
    
    private var currentPartId: String? // 파싱할 `part`의 `id` 값
    private var xmlData: Data?
    private var continuation: CheckedContinuation<Score, Never>?  // Score 타입으로 변경

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
        
        if elementName == "page-layout" {
            isPageLayout = true
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
           let measureNumber = Int(measureNumberString) {
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
        // Divisions 값 파싱
        if currentElement == "divisions", let divisionValue = Int(trimmedString) {
            score.divisions = divisionValue // Score에 divisions 값 저장
        }
        
        if currentElement == "step", currentNote != nil {
            currentNote?.pitch = trimmedString
        }
        
        if currentElement == "octave", currentNote != nil, let octave = Int(trimmedString) {
            currentNote?.octave = octave
        }
        
        if currentElement == "duration", currentNote != nil, let duration = Int(trimmedString) {
            currentNote?.duration = duration
        }
        
        if currentElement == "voice", let voice = Int(trimmedString), var note = currentNote {
            note.voice = voice
            currentNote = note
        }
        
        if currentElement == "type", currentNote != nil {
            currentNote?.type = trimmedString
        }
        
        if currentElement == "staff", let staff = Int(trimmedString), var note = currentNote {
            note.staff = staff
            currentNote = note
        }
        
        if currentElement == "alter", let alter = Int(trimmedString), var note = currentNote {
            if alter == 1 {
                note.accidental = .sharp
            } else if alter == -1 {
                note.accidental = .flat
            }
            currentNote = note
        }
         
        if let currentScale = Double(trimmedString), isPageLayout {
            
            switch currentElement {
            case "page-height":
                print("height \(currentScale)")
                scoreHeight = currentScale
            case "page-width":
                print("width \(currentScale)")
                scoreWidth = currentScale
            case "left-margin":
                print("Lmargin")
                leftMargin = currentScale
            case "right-margin":
                print("Rmargin")
                rightMargin = currentScale
            case "top-margin":
                print("Tmargin")
                topMargin = currentScale
            case "bottom-margin":
                print("Bmargin")
                bottomMargin = currentScale
            default:
                break
            }
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
        
        if elementName == "note", let note = currentNote, currentMeasure != nil {
            // 마디에 음표 추가
            currentMeasure?.addNote(note)
            currentNote = nil
        }
        
        if elementName == "measure", let measure = currentMeasure {
            score.addMeasure(to: currentPartId!, measure: measure)
            currentMeasure = nil
        }
        
        if elementName == "part" {
            currentPartId = nil // 파트가 끝났으므로 currentPartId를 nil로 설정
        }
        
        currentElement = ""
    }
}
