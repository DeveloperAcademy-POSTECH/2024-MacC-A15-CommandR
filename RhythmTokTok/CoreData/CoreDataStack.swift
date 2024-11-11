//
//  CoreDataStack.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import CoreData

class CoreDataStack {
    // Core Data persistent container 설정 (영구 저장용 컨테이너)
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Score")
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Core Data 저장 함수
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                ErrorHandler.handleError(error: nserror)
            }
        }
        
    }
    // MARK: - CRUD Operations for ScoreSettingEntity
    
    // Create
    func createScore(title: String, bpm: Int, soundOption: String, isHapticOn: Bool) {
        let newSetting = ScoreEntity(context: context)
        newSetting.title = title
        newSetting.bpm = Int64(bpm)
        newSetting.soundOption = soundOption
        newSetting.isHapticOn = isHapticOn
        saveContext()
    }
    
    // Read (Fetch a specific setting by title)
    func fetchScore(id: String) -> ScoreEntity? {
        let request: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Failed to fetch setting: \(error)")
            return nil
        }
    }
    
    // Read (Fetch all settings)
    func fetchAllScore() -> [ScoreEntity] {
        let request: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch all settings: \(error)")
            return []
        }
    }
    
    // Update
    func updateScoreSetting(id: String, title: String, bpm: Int, soundOption: String, isHapticOn: Bool) {
        if let setting = fetchScore(id: id) {
            setting.bpm = Int64(bpm)
            setting.soundOption = soundOption
            setting.isHapticOn = isHapticOn
            saveContext()
        }
    }
    
    // Delete
    func deleteScore(id: String) {
        if let setting = fetchScore(id: id) {
            context.delete(setting)
            saveContext()
        }
    }
}

// MARK: dummy data

func createDummyScoreEntities() {
    let context = CoreDataStack.shared.context

    // Example dummy data
    let dummyScores = [
        ["id": UUID().uuidString, "title": "Score 1", "bpm": 120, "soundOption": "melodyBeat", "isHapticOn": true],
        ["id": UUID().uuidString, "title": "Score 2", "bpm": 90, "soundOption": "melody", "isHapticOn": false],
        ["id": UUID().uuidString, "title": "Score 3", "bpm": 140, "soundOption": "beat", "isHapticOn": true],
        ["id": UUID().uuidString, "title": "Score 4", "bpm": 100, "soundOption": "mute", "isHapticOn": false]
    ]
    
    for scoreData in dummyScores {
        let score = ScoreEntity(context: context)
        score.id = scoreData["id"] as? String
        score.title = scoreData["title"] as? String
        score.bpm = scoreData["bpm"] as? Int64 ?? 60
        score.soundOption = scoreData["soundOption"] as? String
        score.isHapticOn = scoreData["isHapticOn"] as? Bool ?? false
        score.createdAt = Date()
        
        // Add dummy notes if needed
        let note1 = NoteEntity(context: context)
        note1.id = UUID().uuidString
        // Add other note properties if they exist
        
        let note2 = NoteEntity(context: context)
        note2.id = UUID().uuidString
        // Add other note properties if they exist
        score.addToNotes(NSOrderedSet(array: [note1, note2]))
    }
    
    do {
        try context.save()
        print("Dummy ScoreEntity data saved successfully.")
    } catch {
        print("Failed to save dummy data: \(error)")
    }
}
