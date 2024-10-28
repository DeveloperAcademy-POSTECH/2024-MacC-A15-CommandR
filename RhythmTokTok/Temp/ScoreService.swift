//
//  ScoreService.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/28/24.
//
import CoreData

class ScoreService {
    let context = CoreDataStack.shared.context
    
    // MARK: - Create

    func createScore(id: String, title: String, bpm: Int64, createdAt: Date, isHapticOn: Bool, soundType: String?, notes: [NoteEntity]?) {
        let score = ScoreEntity(context: context)
        score.id = id
        score.title = title
        score.bpm = bpm
        score.createdAt = createdAt
        score.isHapticOn = isHapticOn
        score.soundType = soundType
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
    
    func updateScore(score: ScoreEntity, newTitle: String?, newBpm: Int64?, newIsHapticOn: Bool?, newSoundType: String?, newNotes: [NoteEntity]?) {
        score.title = newTitle ?? score.title
        score.bpm = newBpm ?? score.bpm
        score.isHapticOn = newIsHapticOn ?? score.isHapticOn
        score.soundType = newSoundType ?? score.soundType
        if let notesArray = newNotes {
            score.notes = NSOrderedSet(array: notesArray)
        }
        saveContext()
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
