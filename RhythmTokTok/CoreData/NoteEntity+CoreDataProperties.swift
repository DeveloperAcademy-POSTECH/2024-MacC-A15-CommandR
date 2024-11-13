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
    @NSManaged public var id: String? // 구분값
    
    // Note와 동일한 값
    @NSManaged public var pitch: String?
    @NSManaged public var duration: Int64
    @NSManaged public var octave: Int16
    @NSManaged public var type: String?
    @NSManaged public var voice: Int16
    @NSManaged public var staff: Int64
    @NSManaged public var startTime: Int64
    @NSManaged public var isRest: Bool
    @NSManaged public var accidental: Int64
    @NSManaged public var tieType: String?
    
    // Part의 ID
    @NSManaged public var part: String?
    // Part의 Measure의 key
    @NSManaged public var lineNumber: Int64
    
    // Measure의 number
    @NSManaged public var measureNumber: Int64
    
    @NSManaged public var score: ScoreEntity?

}

extension NoteEntity : Identifiable {

}
