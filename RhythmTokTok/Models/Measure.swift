//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

// 마디 정보 구조체
struct Measure {
    var number: Int // 마디번호
    var notes: [Note]
    var currentTimes: [Int: Int]  // 스태프별로 현재 시간을 관리
    var startTime: Int = 0 // 높은음자리표 마디 시작틱
    var beats: Int = 0
    var beatType: Int = 0
    
    // 특정 스태프에 음표 추가
    mutating func addNote(_ note: Note) {
        var updatedNote = note
        var staff = note.staff // 높은음자리표 낮은음자리표 구분 (높은음자리표 : 1, 낮은음자리표 : 2)
        // 해당 스태프의 현재 시간을 가져옴 (없으면 0)
        var currentStaffTime = currentTimes[staff] ?? 0
        updatedNote.startTime = currentStaffTime

        // 음표를 추가
        notes.append(updatedNote)

        // 해당 스태프의 시간을 음표의 duration만큼 증가
        currentTimes[staff] = currentStaffTime + note.duration
    }
    
    // TODO: 일단 1번째 staff 만 forward, backup 적용되게 했습니다. 나중에 voice값에 따라 startTime을 관리하게 해야됩니다
    mutating func backupNoteTime(duration: Int, staff: Int) {
        let currentStaffTime = currentTimes[staff] ?? 0
        
        currentTimes[staff] = currentStaffTime - duration
    }
    
    mutating func forwardNoteTime(duration: Int, staff: Int) {
        let currentStaffTime = currentTimes[staff] ?? 0
        
        currentTimes[staff] = currentStaffTime + duration
    }
}
