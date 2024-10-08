//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation

// MusicXML 파싱 클래스
class MusicXMLParser: NSObject, XMLParserDelegate {
    
    var measures: [Measure] = []
    private var currentMeasure: Measure?
    private var currentNote: Note?
    private var currentElement: String = ""
    private var currentVoice: String = "" // 현재 `voice` 값 저장
    private var isInTargetPart: Bool = false // 파싱 중인 대상 `part` 여부 확인
    private var targetPartId: String? // 파싱할 `part`의 `id` 값
    
    private var xmlData: Data?
    private var continuation: CheckedContinuation<[Measure], Never>?
    
    // `async` 메서드로 비동기 파싱 수행
    func parseMusicXML(from xmlData: Data) async -> [Measure] {
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
        print("Parsing finished. Total measures: \(measures.count)")
        continuation?.resume(returning: measures)
        continuation = nil
    }
    
    // 나머지 파싱 로직은 기존과 동일하게 유지
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        // 첫 번째 `part`의 `id` 값 확인 및 저장
        if elementName == "part", targetPartId == nil, let partId = attributeDict["id"] {
            targetPartId = partId
            isInTargetPart = true
        } else if elementName == "part", attributeDict["id"] != targetPartId {
            // 이후 다른 `part`가 나올 경우 파싱 중지
            isInTargetPart = false
        }
        
        // 대상 `part` 내에서만 파싱 진행
        if isInTargetPart {
            if elementName == "measure" {
                currentMeasure = Measure(notes: [])
            }
            
            if elementName == "note" {
                currentNote = Note(pitch: "", duration: 0)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInTargetPart else { return }
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentElement == "step", let _ = currentNote {
            currentNote?.pitch = trimmedString
        } else if currentElement == "octave", let _ = currentNote {
            currentNote?.pitch += trimmedString
        }
        
        if currentElement == "duration", let _ = currentNote, let duration = Int(trimmedString) {
            currentNote?.duration = duration
        }
        
        // 현재 `voice` 정보 업데이트
        if currentElement == "voice" {
            currentVoice = trimmedString
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard isInTargetPart else { return }
        
        if elementName == "note", let note = currentNote {
            currentMeasure?.notes.append(note)
            currentNote = nil
        }
        
        if elementName == "measure", let measure = currentMeasure {
            measures.append(measure)
            currentMeasure = nil
        }
        
        if elementName == "part" {
            isInTargetPart = false // `part` 종료 시 플래그 리셋
        }
        
        currentElement = ""
    }
}
