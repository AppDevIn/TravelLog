//
//  CDUser+CoreDataProperties.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 1/2/21.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var email: String?
    @NSManaged public var password: String?

}

extension CDUser : Identifiable {

}
