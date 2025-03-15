//
//  ExerciseEntity+CoreDataProperties.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 14.03.2025.
//
//

import Foundation
import CoreData


extension ExerciseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseEntity> {
        return NSFetchRequest<ExerciseEntity>(entityName: "ExerciseEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var weight: Double
    @NSManaged public var reps: Int16
    @NSManaged public var day: TrainingDayEntity?

}

extension ExerciseEntity : Identifiable {

}
