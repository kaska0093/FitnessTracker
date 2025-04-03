//
//  ExerciseEntity+CoreDataProperties.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 15.03.2025.
//
//

import Foundation
import CoreData


extension ExerciseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseEntity> {
        return NSFetchRequest<ExerciseEntity>(entityName: "ExerciseEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var trainigDay: TrainingDayEntity?
    @NSManaged public var sets: NSSet?

}

// MARK: Generated accessors for sets
extension ExerciseEntity {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: SetEntity)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: SetEntity)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

extension ExerciseEntity : Identifiable {

}
