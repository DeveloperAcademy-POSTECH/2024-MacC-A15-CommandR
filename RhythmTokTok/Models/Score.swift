//
//  Score.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/12/24.
//

// 악보를 관리하는 객체
class Score {
    var title: String = ""
    var bpm: Int = UserSettingData.shared.getBPM()
    var parts: [Part] = []
    var divisions: Int = 1  // 사음음표 기준 틱 값
    
    // 파트 추가
    func addPart(_ part: Part) {
        parts.append(part)
    }
    
    // 특정 파트에 마디 추가
    func addMeasure(to partID: String, measure: Measure, lineNumber: Int) {
        if let partIndex = parts.firstIndex(where: { $0.id == partID }) {
            // 만약 해당 lineNumber에 저장된 값이 없다면 빈 배열을 초기화
            if parts[partIndex].measures[lineNumber] != nil {
                // 이미 해당 라인에 값이 존재할 경우, 해당 배열에 추가
                parts[partIndex].measures[lineNumber]?.append(measure)
            } else {
                // 해당 라인에 값이 없을 경우 새로운 배열로 초기화하고 추가
                parts[partIndex].measures[lineNumber] = [measure]
            }
        }
    }
}
