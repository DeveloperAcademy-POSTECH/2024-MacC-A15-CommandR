//
//  CoreDataStack.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RhythmTokTok")
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

// MARK: dummy data
//
//func createDummyScoreEntities() {
//    let context = CoreDataStack.shared.context
//
//    // Example dummy data
//    let dummyScores = [
//        ["id": UUID().uuidString, "title": "Score 1", "bpm": 120, "soundOption": "melodyBeat", "isHapticOn": true],
//        ["id": UUID().uuidString, "title": "Score 2", "bpm": 90, "soundOption": "melody", "isHapticOn": false],
//        ["id": UUID().uuidString, "title": "Score 3", "bpm": 140, "soundOption": "beat", "isHapticOn": true],
//        ["id": UUID().uuidString, "title": "Score 4", "bpm": 100, "soundOption": "mute", "isHapticOn": false]
//    ]
//    
//    for scoreData in dummyScores {
//        let score = ScoreEntity(context: context)
//        score.id = scoreData["id"] as? String
//        score.title = scoreData["title"] as? String
//        score.bpm = scoreData["bpm"] as? Int64 ?? 60
//        score.soundOption = scoreData["soundOption"] as! String
//        score.isHapticOn = scoreData["isHapticOn"] as? Bool ?? false
//        score.createdAt = Date()
//        
//        // Add dummy notes if needed
//        let note1 = NoteEntity(context: context)
//        note1.id = UUID().uuidString
//        // Add other note properties if they exist
//        
//        let note2 = NoteEntity(context: context)
//        note2.id = UUID().uuidString
//        // Add other note properties if they exist
//        score.addToNotes(NSOrderedSet(array: [note1, note2]))
//    }
//    
//    do {
//        try context.save()
//        print("Dummy ScoreEntity data saved successfully.")
//    } catch {
//        print("Failed to save dummy data: \(error)")
//    }
//}
