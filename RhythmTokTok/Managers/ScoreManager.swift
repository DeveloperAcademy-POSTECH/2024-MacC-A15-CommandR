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
    
    // Entity - Model 매핑
    // TODO: - 기본값 관리 필요
    func addScoreWithNotes(scoreData: Score) {
        let score = ScoreEntity(context: context)
        score.id = UUID().uuidString
        score.createdAt = Date()
        score.title = scoreData.title
        score.bpm = Int64(scoreData.bpm)
        score.isHapticOn = true
        score.isScoreDeleted = false
        score.soundOption = SoundSetting.default.rawValue
        score.divisions = Int64(scoreData.divisions)
        
        // Note를 담을 Ordered Set 생성
        let notesSet = NSMutableOrderedSet()
        
        // 줄 번호 키값도 순회하게 만듦
        scoreData.parts.forEach { part in
            part.measures.forEach { (lineNumber, measures) in
                measures.forEach { measure in
                    measure.notes.forEach { note in
                        let noteEntity = createNoteEntity(from: note, partId: part.id, lineNumber: lineNumber, measureNumber: measure.number, score: score)
                        notesSet.add(noteEntity)
                    }
                }
            }
        }
        
        // ScoreEntity의 notes 관계에 노트 추가
        score.notes = notesSet
        
        // 저장
        context.perform {
            do {
                try self.context.save()
                print("Score with notes saved!")
            } catch {
                ErrorHandler.handleError(error: error)
                print("Failed to save score with notes: \(error)")
            }
        }
    }
    
    // NoteEntity 초기화 함수
    func createNoteEntity(from note: Note, partId: String, lineNumber: Int, measureNumber: Int, score: ScoreEntity) -> NoteEntity {
        let noteEntity = NoteEntity(context: context)
        noteEntity.id = UUID().uuidString  // 고유 ID
        noteEntity.pitch = note.pitch
        noteEntity.duration = Int64(note.duration)
        noteEntity.octave = Int16(note.octave)
        noteEntity.type = note.type
        noteEntity.voice = Int16(note.voice)
        noteEntity.staff = Int64(note.staff)
        noteEntity.startTime = Int64(note.startTime)
        noteEntity.isRest = note.isRest
        noteEntity.accidental = Int64(note.accidental.rawValue)  // Enum에서 Int로 변환
        noteEntity.tieType = note.tieType
        
        noteEntity.part = partId  // 파트 설정
        noteEntity.lineNumber = Int64(lineNumber)  // Measure 번호 설정
        noteEntity.measureNumber = Int64(measureNumber)  // Measure 번호 설정
        noteEntity.score = score  // Score와 연결
        return noteEntity
    }
}
