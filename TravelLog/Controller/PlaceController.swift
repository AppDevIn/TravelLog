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
    
    
    func AddPlace()  {
        
        
    }
    
}
