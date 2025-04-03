//
//  SetEntity+CoreDataProperties.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 31.03.2025.
//
//

import Foundation
import CoreData


extension SetEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SetEntity> {
        return NSFetchRequest<SetEntity>(entityName: "SetEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Double
    @NSManaged public var index: Int16
    @NSManaged public var exercise: ExerciseEntity?

}

extension SetEntity : Identifiable {

}
