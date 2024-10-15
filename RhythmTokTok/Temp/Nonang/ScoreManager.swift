//
//  ScoreManager.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import CoreData

class ScoreManager {
    
    static let shared = ScoreManager()
    
    let context = CoreDataStack.shared.context
    
    //Entity - Model 매핑
    func addScoreWithNotes(scoreData: Score) {
        
        // 새로운 ScoreEntity 생성
        let score = ScoreEntity(context: context)
        score.id = UUID().uuidString
        score.createdAt = Date()
        score.title = scoreData.title
        score.bpm = scoreData.bpm
        
        // Note를 담을 Ordered Set 생성
        let notesSet = NSMutableOrderedSet()
        
        // ScoreData의 모든 Note를 순회하여 Entity로 변환
        scoreData.parts.flatMap { $0.measures }.flatMap { $0.notes }.forEach { note in
            let noteEntity = createNoteEntity(from: note, measureNumber: note.startTime, score: score)
            notesSet.add(noteEntity)
        }
        
        // ScoreEntity의 notes 관계에 노트 추가
        score.notes = notesSet
        
        // 저장
        do {
            try context.save()
            print("Score with notes saved!")
        } catch {
            ErrorHandler.handleError(error: error)
            print("Failed to save score with notes: \(error)")
        }
    }
    
    // NoteEntity 초기화 함수
    func createNoteEntity(from note: Note, measureNumber: Int, score: ScoreEntity) -> NoteEntity {
        let noteEntity = NoteEntity(context: context)
        noteEntity.id = UUID().uuidString  // 고유 ID
        noteEntity.score = score  // Score와 연결
        noteEntity.measure = measureNumber  // Measure 번호 설정
        noteEntity.startTime = note.startTime
        noteEntity.staff = note.staff
        noteEntity.accidental = note.accidental.rawValue  // Enum에서 Int로 변환
        noteEntity.isRest = note.isRest
        noteEntity.duration = note.duration
        noteEntity.pitch = note.pitch
        noteEntity.octave = note.octave
        noteEntity.type = note.type
        noteEntity.voice = note.voice
        return noteEntity
    }
    
}

