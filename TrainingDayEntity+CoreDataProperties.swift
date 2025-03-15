//
//  TrainingDayEntity+CoreDataProperties.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 14.03.2025.
//
//

import Foundation
import CoreData


extension TrainingDayEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainingDayEntity> {
        return NSFetchRequest<TrainingDayEntity>(entityName: "TrainingDayEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var exercises: NSSet?

}

// MARK: Generated accessors for exercises
extension TrainingDayEntity {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: ExerciseEntity)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: ExerciseEntity)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension TrainingDayEntity : Identifiable {

}
