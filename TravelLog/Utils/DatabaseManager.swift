//
//  DatabaseManager.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 28/1/21.
//

import Foundation
import FirebaseFirestore


class DatabaseManager{
    
    var db: Firestore!
    static let shared:DatabaseManager = DatabaseManager()
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func insertUser(userID UID:String, userName name:String) {
        let docRef = db.collection("users").document(UID)
        
        docRef.setData([
            "name": link
        ])
        
    }
    
    func setProfileImage(userID UID:String, profileLink link:String) {
        let docRef = db.collection("users").document(UID)
        
        docRef.setData([
            "profileLink": link
        ])
        
    }
    
    func getProfileImage(userID UID:String, completionBlock: @escaping (URL) -> Void) {
        let docRef = db.collection("users").document(UID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                
                guard let profileLink = data["profileLink"] else {
                    return
                }
                
                //Cover string to URL
                let url:URL = NSURL(string: profileLink as! String )! as URL
                
                completionBlock(url)
                
            } else {
                print("Document does not exist")
            }
        }

        
    }
    
    func getPosts(userID UID:String, success: @escaping ([Post]) -> Void )  {
        var posts:[Post] = []
        
        let docRef = db.collection("users").document(UID).collection("posts")
        
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let post = Post(title: data["title"]! as! String, decription: data["description"]! as! String, locations: data["locations"]! as! String, images: data["images"]! as! [String])
                    posts.append(post)
                }
                
                success(posts)
                
                
            }
        }
        
        
        
    }
    
}
