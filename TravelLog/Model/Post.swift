//
//  Post.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 26/1/21.
//

import Foundation
import UIKit

class Post{
    
    var images:[String]
    var title:  String
    var decription: String
    var locations:String
    
    init() {
        images = []
        title = ""
        decription = ""
        locations = ""
    }
    
    init(title t:String, decription des:String, locations loc:String, images imgs:[String]) {
        self.title = t
        self.decription = des
        self.locations = loc
        self.images = imgs
    }
    
    
}
