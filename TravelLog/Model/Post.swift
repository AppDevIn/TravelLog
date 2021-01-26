//
//  Post.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 26/1/21.
//

import Foundation
import UIKit

class Post{
    
    var images:[UIImage]
    var title:  String
    var decription: String
    var locations:String
    
    init(_ title:String, _ decription:String, _ locations:String, _ images:[UIImage]) {
        self.title = title
        self.decription = decription
        self.locations = locations
        self.images = images
    }
    
    
}
