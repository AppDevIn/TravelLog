//
//  StorageManager.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 28/1/21.
//

import Foundation
import UIKit
import FirebaseStorage

class StorageManager{
    
    static let shared = StorageManager()
    
    // Get a reference to the storage service using the default Firebase App
    private let storage = Storage.storage()
    
    
    
    init() {}
    
    func setProfilePic(image img:UIImage, UID uid:String, completionBlock: @escaping (Bool) -> Void ){
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child("users/\(uid)/profile.jpg")
        
        //Get the data
        guard let uploadData = img.pngData() else {return}
        
        
        
        // Upload the file to the path "images/rivers.jpg"
        imageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            guard let _ = metadata else {
              completionBlock(false)
              return
            }
            
            completionBlock(true)
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {return}
                
                DatabaseManager.shared.setProfileImage(userID: uid, profileLink: downloadURL.absoluteString)
            }
            
            
            
            
        }
        
        
        
    }
}
