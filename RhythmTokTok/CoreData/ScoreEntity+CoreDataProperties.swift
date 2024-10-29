//
//  ScoreEntity+CoreDataProperties.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/28/24.
//
//

import Foundation
import CoreData

extension ScoreEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScoreEntity> {
        return NSFetchRequest<ScoreEntity>(entityName: "ScoreEntity")
    }

    @NSManaged public var bpm: Int64
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var isHapticOn: Bool
    @NSManaged public var soundType: String?
    @NSManaged public var notes: NSOrderedSet?

}

// MARK: Generated accessors for notes
extension ScoreEntity {

    @objc(insertObject:inNotesAtIndex:)
    @NSManaged public func insertIntoNotes(_ value: NoteEntity, at idx: Int)

    @objc(removeObjectFromNotesAtIndex:)
    @NSManaged public func removeFromNotes(at idx: Int)

    @objc(insertNotes:atIndexes:)
    @NSManaged public func insertIntoNotes(_ values: [NoteEntity], at indexes: NSIndexSet)

    @objc(removeNotesAtIndexes:)
    @NSManaged public func removeFromNotes(at indexes: NSIndexSet)

    @objc(replaceObjectInNotesAtIndex:withObject:)
    @NSManaged public func replaceNotes(at idx: Int, with value: NoteEntity)

    @objc(replaceNotesAtIndexes:withNotes:)
    @NSManaged public func replaceNotes(at indexes: NSIndexSet, with values: [NoteEntity])

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: NoteEntity)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: NoteEntity)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSOrderedSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSOrderedSet)

}

extension ScoreEntity : Identifiable {

}
