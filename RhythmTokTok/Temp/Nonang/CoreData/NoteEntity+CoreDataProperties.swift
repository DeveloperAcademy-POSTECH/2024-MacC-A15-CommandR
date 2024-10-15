//
//  NoteEntity+CoreDataProperties.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var accidental: Int
    @NSManaged public var isRest: Bool
    @NSManaged public var startTime: Int
    @NSManaged public var staff: Int
    @NSManaged public var id: String?
    @NSManaged public var measure: Int
    @NSManaged public var part: Int
    @NSManaged public var duration: Int
    @NSManaged public var pitch: String?
    @NSManaged public var octave: Int
    @NSManaged public var type: String?
    @NSManaged public var voice: Int
    @NSManaged public var score: ScoreEntity?

}

extension NoteEntity : Identifiable {

}
