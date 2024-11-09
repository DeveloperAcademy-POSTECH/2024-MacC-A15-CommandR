//
//  NoteEntity+CoreDataProperties.swift
//  RhythmTokTok
//
//  Created by 백록담 on 11/9/24.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var accidental: Int64
    @NSManaged public var duration: Int64
    @NSManaged public var id: String?
    @NSManaged public var isRest: Bool
    @NSManaged public var measure: Int64
    @NSManaged public var octave: Int16
    @NSManaged public var part: String?
    @NSManaged public var pitch: String?
    @NSManaged public var staff: Int64
    @NSManaged public var startTime: Int64
    @NSManaged public var type: String?
    @NSManaged public var voice: Int16
    @NSManaged public var score: ScoreEntity?

}

extension NoteEntity : Identifiable {

}
