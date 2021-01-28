//
//  User.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 29/1/21.
//

import Foundation

class User{
    
    var name:String
    var profileLink:URL?
    
    init(userName name:String) {
        self.name = name
    }
    
    init(userName name:String, dp profileLink:URL) {
        self.name = name
        self.profileLink = profileLink
    }
}
