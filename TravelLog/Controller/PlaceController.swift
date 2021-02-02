//
//  PlaceController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 1/2/21.
//

import Foundation
import UIKit
import CoreData

class PlaceController {
    var appDelegate:AppDelegate
    let context:NSManagedObjectContext
    
    init() {
        //Refering to the container
        appDelegate  = (UIApplication.shared.delegate) as! AppDelegate
        
        //Create a contect for this container
        context = appDelegate.persistentContainer.viewContext
    }
    
    
    func AddPlace(_ visit: CLVisit, description: String) -> Bool {
        
        var samelocation:Bool = false
        
        do {
            let result = try context.fetch(CDPlace.fetchRequest())
   
            for data in result as! [CDPlace]{
                
                if description == data.name! {
                    samelocation = true
                    
                }
             
            }
            
            
        } catch {
            print(error)
            
            
        }
        
        guard !samelocation else {
            samelocation = false
            return false
        }
        
        let plcae = CDPlace(context: context)
        plcae.name = description
        plcae.departure = visit.departureDate
        plcae.lat = visit.coordinate.latitude
        plcae.lng = visit.coordinate.longitude
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return true
    }
    
}
