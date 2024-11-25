//
//  Note.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

// 음표 정보 구조체
struct Note {
    var pitch: String
    var duration: Int
    var octave: Int
    var type: String
    var voice: Int
    var staff: Int
    var startTime: Int  // 음표가 재생되기 시작하는 시간
    var isRest: Bool = false
    var accidental: Accidental = .natural
    var tieType: String?
    
    // pitch 값을 MIDI 노트 번호로 변환하는 함수
    func pitchNoteNumber(with soundKey: Double) -> Int {
        let pitchBase: [String: Int] = [
            "C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11
        ]
        
        let baseNoteNumber = 60 // C4 기준
        guard let pitchOffset = pitchBase[pitch] else {
            return baseNoteNumber
        }
        
        var noteNumber = baseNoteNumber + (octave - 4) * 12 + pitchOffset
        
        // 플랫/샵 처리
        switch accidental {
        case .flat:
            noteNumber -= 1
        case .sharp:
            noteNumber += 1
        case .natural:
            break
        }
        
        // soundKey를 0.5 단위로 1씩 반영
        noteNumber += Int(soundKey * 2) // 0.5 단위는 1로, 1.0 단위는 2로 변환
        
        return noteNumber
    }
}
