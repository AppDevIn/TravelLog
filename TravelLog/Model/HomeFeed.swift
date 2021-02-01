//
//  File.swift
//  TravelLog
//
//  Created by school on 29/1/21.
//

import Foundation
import UIKit


class HomeFeed {
    
    var postImages: [String]
    var profileImg: URL?
    var username: String
    var title:  String
    var description: String
    var locations: String
    var lat: Double?
    var lng: Double?
    
    init() {
        postImages = []
        username = ""
        profileImg = NSURL(string: "")! as URL
        title = ""
        description = ""
        locations = ""
        
    }
    
    init(postImages post:[String], username name:String, title t: String, description desc: String, locations location: String) {
        self.postImages = post
        
        self.username = name
        self.title = t
        self.description = desc
        self.locations = location
    }
   
    
    func setLocation(lat:Double, lng:Double) {
        self.lat = lat
        self.lng = lng
    }
    
}


