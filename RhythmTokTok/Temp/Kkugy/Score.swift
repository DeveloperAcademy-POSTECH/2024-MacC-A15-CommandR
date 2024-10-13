//
//  Score.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/12/24.
//

// 악보를 관리하는 객체
class Score {
    var parts: [Part] = []
    var divisions: Int = 1  // 사음음표 기준 틱 값
    
    // 파트 추가
    func addPart(_ part: Part) {
        parts.append(part)
    }
    
    // 특정 파트에 마디 추가
    func addMeasure(to partID: String, measure: Measure) {
        if let partIndex = parts.firstIndex(where: { $0.id == partID }) {
            parts[partIndex].measures.append(measure)
        }
    }
    
    // backup 처리: 시간을 되돌림
    func applyBackup(to partID: String, measureNumber: Int, staff: Int, backupDuration: Int) {
        if let partIndex = parts.firstIndex(where: { $0.id == partID }) {
            if let measureIndex = parts[partIndex].measures.firstIndex(where: { $0.number == measureNumber }) {
                // 해당 스태프의 현재 시간을 되돌림
                parts[partIndex].measures[measureIndex].currentTimes[staff]? -= backupDuration
            }
        }
    }
}
