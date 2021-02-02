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
    
    func insertUser(userID UID:String, userName name:String, completionHandler: @escaping (Bool) -> Void) {
        let docRef = db.collection("users").document(UID)
        
        docRef.setData([
            "name": name,
            "caseSearch": getArrayOfName(name:name)
        ]) { (err) in
            guard let _ = err else {
                completionHandler(true)
                return
            }
            
            completionHandler(false)
            
        }
        
        
    }
    
    private func getArrayOfName(name:String) -> [String]{
        var temp:String = ""
        var arr:[String] = []
        
        for n in name{
            temp += String(n).lowercased()
            arr.append(temp)
        }
        
        return arr
    }
    
    func getUser(userID UID:String, completionBlock: @escaping (User) -> Void) {
        let docRef = db.collection("users").document(UID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                
                guard let name = data["name"] else {
                    return
                }
                
                let user:User = User(id: UID, userName: name as! String)
                
                
                if let profileLink = data["profileLink"] {
                    //Cover string to URL
                    user.profileLink = profileLink as! String
                    
                }
                
                //If got following
                if let following = data["following"] {
                    user.following = following as! [String]
                }
                
                //If got followers
                if let follower = data["follower"] {
                    user.follower = follower as! [String]
                }
                
                
                
                
                
                completionBlock(user)
                
            } else {
                print("Document does not exist")
            }
        }
        
        
    }
    
    func updateUser(userID UID:String, completionBlock: @escaping (User) -> Void) {
        
        let docRef = db.collection("users").document(UID)
        
        
        docRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {return}
            
            guard let name = data["name"] else {
                return
            }
            
            let user:User = User(id: UID, userName: name as! String)
            
            
            if let profileLink = data["profileLink"] {
                //Cover string to URL
                user.profileLink = profileLink as! String
                
            }
            //If got following
            if let following = data["following"] {
                user.following = following as! [String]
            }
            
            //If got followers
            if let follower = data["follower"] {
                user.follower = follower as! [String]
            }
            
            
            completionBlock(user)
            
            
        }
        
    }
    
    func setProfileImage(userID UID:String, profileLink link:String) {
        let docRef = db.collection("users").document(UID)
        
        docRef.setData([
            "profileLink": link
        ], merge: true)
        
    }
    
    
    func getPosts(userID UID:String, success: @escaping (Post) -> Void )  {
        
        
        let docRef = db.collection("users").document(UID).collection("posts").order(by: "date", descending: true)
        
        
        
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    
                    if let img = data["images"] {
                        let post = Post(title: data["title"]! as! String, decription: data["description"]! as! String, locations: data["locations"]! as! String, images: img as! [String])
                        success(post)
                    }
                }                
            }
        }
        
    }
    
    func getPosts(users:[String], success: @escaping ([HomeFeed]) -> Void )  {
        var posts:[HomeFeed] = []
        
        let docRef = db.collection("posts").whereField("uid", in: users).order(by: "date", descending: true)
        
        
        var userDict = [String:DocumentReference]()
        
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    if let img = data["images"] {
                        let post = HomeFeed(title: data["title"]! as! String, decription: data["description"]! as! String, locations: data["locations"]! as! String, images: img as! [String])
                        
                        post.user = User()
                        post.user?.UID = data["uid"] as! String
                        
                        
                        //Check if the lat and lng exist
                        if let coor = data["coordinate"] {
                            
                            let d = coor as! [Double]
                            post.setLocation(lat: d[0] , lng: d[1] )

                            
                        }
                        
                        posts.append(post)
                        
                        
                        
                        userDict[data["uid"] as! String] = data["userRef"] as! DocumentReference
                    }
                    
                    
                }
                
                for key in userDict.keys {
                    userDict[key]?.getDocument(completion: { (document, error) in
                        if let document = document, document.exists {
                            guard let userData = document.data() else {return}
                            
                            
                            guard let name = userData["name"] else {
                                return
                            }
                            
                            let user:User = User(id: key, userName: name as! String)
                            
                            
                            if let profileLink = userData["profileLink"] {
                                //Cover string to URL
                                user.profileLink = (profileLink as! String)
                                
                            }
                            
                            //If got following
                            if let following = userData["following"] {
                                user.following = following as! [String]
                            }
                            
                            //If got followers
                            if let follower = userData["follower"] {
                                user.follower = follower as! [String]
                            }
                            
                            
                         
                            
                            for post in posts {
                                if post.user?.UID == key {
                                    post.user = user
                                }
                            }
                            
                            success(posts)
                            
                            
                            
                            
                        }
                    })
                }
                
                
                
                
                
                
                
                
                
                
                
                
            }
        }
        
    }
    
//
//    func getPosts(users:[String], success: @escaping (HomeFeed) -> Void )  {
//        var posts:[HomeFeed] = []
//
//        let docRef = db.collection("posts").whereField("uid", in: users).order(by: "date", descending: true)
//
//
//
//
//        docRef.getDocuments { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//
//                    let data = document.data()
//
//                    (data["userRef"] as! DocumentReference).getDocument { (document, error) in
//                        if let document = document, document.exists {
//                            guard let userData = document.data() else {return}
//
//
//                            if let img = data["images"] {
//                                let post = HomeFeed(title: data["title"]! as! String, decription: data["description"]! as! String, locations: data["locations"]! as! String, images: img as! [String])
//                                posts.append(post)
//
//
//                                guard let name = userData["name"] else {
//                                    return
//                                }
//
//                                let user:User = User(id: data["uid"] as! String, userName: name as! String)
//
//
//                                if let profileLink = userData["profileLink"] {
//                                    //Cover string to URL
//                                    user.profileLink = (profileLink as! String)
//
//                                }
//
//                                //If got following
//                                if let following = userData["following"] {
//                                    user.following = following as! [String]
//                                }
//
//                                //If got followers
//                                if let follower = userData["follower"] {
//                                    user.follower = follower as! [String]
//                                }
//
//
//                                //Check if the lat and lng exist
//                                if let coor = userData["coordinate"] {
//
//                                    let d = coor as! [Double]
//
//                                    post.setLocation(lat: d[0] , lng: d[1] )
//                                }
//
//
//
//                                success(post)
//                            }
//
//                        }
//                    }
//
//                }
//
//
//
//
//            }
//        }
//
//    }
//
    
    func searchUser(name prefix:String, completionBlock: @escaping ([User]) -> Void) {
        let docRef = db.collection("users")
        
        var users:[User] = []
        
        docRef.whereField("caseSearch", arrayContains: prefix.lowercased()).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let id = document.documentID
                    
                    
                    var user:User
                    if let name = data["name"], let profileLink = data["profileLink"] {
                        //Cover string to URL
                        let url:URL = NSURL(string: profileLink as! String )! as URL
                        
                        user = User(id: id, userName: name as! String, dp: profileLink as! String)
                    } else if let name = data["name"]{
                        user = User(id: id, userName: name as! String)
                    } else{
                        return
                    }
                    
                    //If got following
                    if let following = data["following"] {
                        user.following = following as! [String]
                    }
                    
                    //If got followers
                    if let follower = data["follower"] {
                        user.follower = follower as! [String]
                    }
                    
                    //Don't add the current user
                    if id != Constants.currentUser?.UID {
                        users.append(user)
                    }
                    
                    
                    
                }
                if users.count > 0 {completionBlock(users)}
                
            }
        }
    }
    
    func insertFollow(UID uid:String, followerID followerId: String)  {
        let userRef = db.collection("users").document(uid)
        let followingRef = db.collection("users").document(followerId)
        
        //Insert the person the user follwing
        userRef.setData([
            "following": FieldValue.arrayUnion([followerId])
        ], merge: true)
        
        //Let the follower know who is following
        followingRef.setData([
            "follower": FieldValue.arrayUnion([uid])
        ], merge: true)
    }
    
    func removeFollow(UID uid:String, followerID followerId: String)  {
        let userRef = db.collection("users").document(uid)
        let followingRef = db.collection("users").document(followerId)
        
        //Insert the person the user follwing
        userRef.setData([
            "following": FieldValue.arrayRemove([followerId])
        ], merge: true)
        
        //Let the follower know who is following
        followingRef.setData([
            "follower": FieldValue.arrayRemove([uid])
        ], merge: true)
    }
    
}

