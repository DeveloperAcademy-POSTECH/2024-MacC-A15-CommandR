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
    
    // pitch 값을 MIDI 노트 번호로 변환하는 함수
    func pitchNoteNumber() -> Int {
        let pitchMap: [String: Int] = [
            "C4": 60, "C#4": 61, "D4": 62, "D#4": 63, "E4": 64,
            "F4": 65, "F#4": 66, "G4": 67, "G#4": 68, "A4": 69,
            "A#4": 70, "B4": 71, "C5": 72
        ]
        
        return pitchMap[pitch] ?? 60 // 디폴트 값은 C4 (MIDI 노트 60)
    }
}
