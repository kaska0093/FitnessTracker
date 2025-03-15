//
//  ListOfExercises+CoreDataProperties.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 14.03.2025.
//
//

import Foundation
import CoreData


extension ListOfExercises {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListOfExercises> {
        return NSFetchRequest<ListOfExercises>(entityName: "ListOfExercises")
    }

    @NSManaged public var descriptions: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var order: Int16

}

extension ListOfExercises : Identifiable {

}
