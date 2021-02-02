//
//  User.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 29/1/21.
//

import Foundation

class User{
    
    var name:String
    var profileLink:String?
    var UID:String
    var following:[String] = []
    var follower:[String] = []
    var post: [Post] = []
    var email:String?
    var password:String?

    
    init(id uid:String, userName name:String) {
        self.name = name
        self.UID = uid
    }
    
    init() {
        self.name = "Unable to find"
        self.UID = "jdskjnjkdhjk"
    }
    
    init(id uid:String, userName name:String, dp profileLink:String) {
        self.name = name
        self.profileLink = profileLink
        self.UID = uid
    }
}
