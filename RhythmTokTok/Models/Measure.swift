//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

// 마디 정보 구조체
struct Measure {
    let number: Int
    var notes: [Note]
    var currentTimes: [Int: Int]  // 스태프별로 현재 시간을 관리
    var startTime: Int = 0 // 높은음자리표 마디 시작틱
    var beats: Int = 0
    var beatType: Int = 0
    
    // 특정 스태프에 음표 추가
    mutating func addNote(_ note: Note) {
        var updatedNote = note
        let staff = note.staff // 높은음자리표 낮은음자리표 구분 (높은음자리표 : 1, 낮은음자리표 : 2)
        // 해당 스태프의 현재 시간을 가져옴 (없으면 0)
        let currentStaffTime = currentTimes[staff] ?? 0
//        print("업데이트 [\(staff)]노트 시간 \(currentStaffTime)")
        updatedNote.startTime = currentStaffTime

        // 음표를 추가
        notes.append(updatedNote)

        // 해당 스태프의 시간을 음표의 duration만큼 증가
        currentTimes[staff] = currentStaffTime + note.duration
    }
}
