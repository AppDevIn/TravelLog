//
//  CDPlace+CoreDataProperties.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 31/1/21.
//
//

import Foundation
import CoreData


extension CDPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPlace> {
        return NSFetchRequest<CDPlace>(entityName: "CDPlace")
    }

    @NSManaged public var name: String?
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var departure: Date?

}

extension CDPlace : Identifiable {

}
