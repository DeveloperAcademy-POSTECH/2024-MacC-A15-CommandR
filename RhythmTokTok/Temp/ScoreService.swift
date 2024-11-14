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
                        
                        ScoreManager.shared.addScoreWithNotes(scoreData: score)
                    }
                    // UserDefaults에 초기 데이터가 삽입되었음을 기록
                    UserDefaults.standard.set(true, forKey: "hasInsertedDummyData")
                } else {
                    print("DummyScores 폴더 내 파일을 찾을 수 없습니다.")
                }
            }
        } catch {
            print("데이터 삽입 중 오류 발생: \(error)")
        }
    }
    
    // MARK: - Create
    func createScore(id: String, title: String, bpm: Int64, createdAt: Date, isHapticOn: Bool, soundOption: String, notes: [NoteEntity]?) {
        let score = ScoreEntity(context: context)
        score.id = id
        score.title = title
        score.bpm = bpm
        score.createdAt = createdAt
        score.isHapticOn = isHapticOn
        score.soundOption = soundOption
        if let notesArray = notes {
            score.notes = NSOrderedSet(array: notesArray)
        }
        saveContext()
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
            print("No ScoreEntity found with id \(id).")
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
