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
        let container = NSPersistentContainer(name: "RhythmTokTok")
        
        //프로퍼티 변경시에 자동 반영 해준다고 함
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
    
}
