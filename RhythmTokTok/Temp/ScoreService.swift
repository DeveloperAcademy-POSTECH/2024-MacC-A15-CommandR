//
//  ScoreService.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/28/24.
//
import CoreData

class ScoreService {
    let context = CoreDataStack.shared.context
    
    // 초기 데이터 삽입 여부를 확인하고, 없을 경우 데이터를 삽입
    func insertDummyDataIfNeeded() async {
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 { // swiftlint:disable:this empty_count
                if let filePaths = Bundle.main.urls(forResourcesWithExtension: "xml", subdirectory: "DummyScores") {
                    for fileURL in filePaths {
                        let fileName = fileURL.deletingPathExtension().lastPathComponent
                        let xmlData = try Data(contentsOf: fileURL)
                        let parser = MusicXMLParser()
                        let score = await parser.parseMusicXML(from: xmlData)
                        score.title = fileName
                        
                        addScoreWithNotes(scoreData: score)
                    }
                    // UserDefaults에 초기 데이터가 삽입되었음을 기록
                    UserDefaults.standard.set(true, forKey: "hasInsertedDummyData")
                } else {
                    ErrorHandler.handleError(error: "DummyScores 폴더 내 파일을 찾을 수 없습니다.")
                }
            }
        } catch {
            ErrorHandler.handleError(error: "데이터 삽입 중 오류 발생: \(error)")
        }
    }
    
//    // MARK: - Create
    // ScoreEntity 및 NoteEntity 추가 함수
    func addScoreWithNotes(scoreData: Score) {
        context.performAndWait { // Thread-safe Core Data 작업
            let score = ScoreEntity(context: self.context)
            score.id = UUID().uuidString
            score.createdAt = Date()
            score.title = scoreData.title
            score.bpm = Int64(scoreData.bpm)
            score.isHapticOn = true
            score.isScoreDeleted = false
            score.soundOption = SoundSetting.default.rawValue
            score.divisions = Int64(scoreData.divisions)

            // Note 관계 설정
            scoreData.parts.forEach { part in
                part.measures.forEach { (lineNumber, measures) in
                    measures.forEach { measure in
                        measure.notes.forEach { note in
                            self.createNoteEntity(
                                from: note,
                                partId: part.id,
                                lineNumber: lineNumber,
                                measureNumber: measure.number,
                                score: score
                            )
                        }
                    }
                }
            }

            // 저장
            do {
                try self.context.save()
                print("Score with notes saved!")
            } catch {
                ErrorHandler.handleError(error: "Failed to save score with notes: \(error)")
            }
        }
    }

    // NoteEntity 생성 및 관계 설정 함수
    func createNoteEntity(from note: Note, partId: String, lineNumber: Int, measureNumber: Int, score: ScoreEntity) {
        let noteEntity = NoteEntity(context: context)
        noteEntity.id = UUID().uuidString
        noteEntity.pitch = note.pitch
        noteEntity.duration = Int64(note.duration)
        noteEntity.octave = Int16(note.octave)
        noteEntity.type = note.type
        noteEntity.voice = Int16(note.voice)
        noteEntity.staff = Int64(note.staff)
        noteEntity.startTime = Int64(note.startTime)
        noteEntity.isRest = note.isRest
        noteEntity.accidental = Int64(note.accidental.rawValue)
        noteEntity.tieType = note.tieType
        
        noteEntity.part = partId
        noteEntity.lineNumber = Int64(lineNumber)
        noteEntity.measureNumber = Int64(measureNumber)
        
        // ScoreEntity와 NoteEntity 관계 설정
        score.addToNotes(noteEntity) // Core Data 메서드 사용
    }
    
    // MARK: - Read
    func fetchAllScores() -> [ScoreEntity] {
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            ErrorHandler.handleError(error: error)
            return []
        }
    }
    
    func fetchScoreById(id: String) -> ScoreEntity? {
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            ErrorHandler.handleError(error: error)
            return nil
        }
    }
    
    // MARK: - Update
    func updateScore(withId id: String, update: (ScoreEntity) -> Void) {
        if let scoreEntity = fetchScoreById(id: id) {
            update(scoreEntity)
            saveContext()
        } else {
            ErrorHandler.handleError(error: "No ScoreEntity found with id \(id).")
        }
    }
    
    // MARK: - Delete
    func deleteScore(score: ScoreEntity) {
        context.delete(score)
        saveContext()
    }
    
    // MARK: - Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
}
