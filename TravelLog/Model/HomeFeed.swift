//
//  File.swift
//  TravelLog
//
//  Created by school on 29/1/21.
//

import Foundation
import UIKit


struct HomeFeed {
    
    var postImages: [String]
    var profileImg: URL?
    var username: String
    var UID: String
    var title:  String
    var description: String
    var locations: String
    
    
    init() {
        postImages = []
        username = ""
        profileImg = NSURL(string: "")! as URL
        title = ""
        UID = ""
        description = ""
        locations = ""
        
    }
    
    init(UID uid: String, postImages post:[String], username name:String, title t: String, description desc: String, locations location: String) {
        self.postImages = post
        self.UID = uid
        self.username = name
        self.title = t
        self.description = desc
        self.locations = location
    }
   
    
}


