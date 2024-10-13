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
        let pitchBase: [String: Int] = [
            "C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4,
            "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9,
            "A#": 10, "B": 11
        ]
        
        // MIDI 노트 번호는 C4 = 60을 기준으로, 옥타브마다 12씩 차이남
        let baseNoteNumber = 60 // C4의 MIDI 번호
        guard let pitchOffset = pitchBase[pitch] else {
            return baseNoteNumber // pitch가 없으면 C4로 기본값 반환
        }
        
        // 옥타브에 따른 노트 번호 계산
        return baseNoteNumber + (octave - 4) * 12 + pitchOffset
    }
}
