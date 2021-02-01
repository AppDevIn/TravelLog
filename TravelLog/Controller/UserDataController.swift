//
//  UserDataController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 1/2/21.
//

import Foundation
import UIKit
import CoreData

class UserDataController {
    var appDelegate:AppDelegate
    let context:NSManagedObjectContext
    
    init() {
        //Refering to the container
        appDelegate  = (UIApplication.shared.delegate) as! AppDelegate
        
        //Create a contect for this container
        context = appDelegate.persistentContainer.viewContext
    }
    
    
    func saveUser(email:String, password:String)  {
        
        //Create the object
        let cdUser = CDUser(context: context)
        cdUser.email = email
        cdUser.password = password
        
        //Save the data
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func retrieveUser() -> CDUser? {
          
        
        do {
            let result = try context.fetch(CDUser.fetchRequest())
            
            if let data = result[0] as? CDUser {
                return data
            } else {return nil}
            
            
            
        } catch {
            print(error)
            return nil
            
        }

    }
    
    func deleteUser() {
          
        
        do {
            let result = try context.fetch(CDUser.fetchRequest())
            
            
            
            if let data = result[0] as? CDUser {
                
                context.delete(data)
                try context.save()
                
            } else {return }
            
            
        } catch {
            print(error)
            
            
        }

    }
}
