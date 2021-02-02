//
//  File.swift
//  TravelLog
//
//  Created by school on 29/1/21.
//

import Foundation
import UIKit


class HomeFeed: Post {
    
    
    var user:User?
    
    
    override init(title t: String, decription des: String, locations loc: String, images imgs: [String], postID: String) {
        super.init(title: t, decription: des, locations: loc, images: imgs, postID: postID)
    }
    
    init(post:Post) {
        super.init(title: post.title, decription: post.decription, locations: post.locations, images: post.images, postID: post.postID)
        
        if let lat = post.lat, let lng = post.lng {
            setLocation(lat: lat, lng: lng)
        }
    }
    

    init(post:Post, user:User) {
        super.init(title: post.title, decription: post.decription, locations: post.locations, images: post.images, postID: post.postID)
        
        self.user = user
        
        if let lat = post.lat, let lng = post.lng {
            setLocation(lat: lat, lng: lng)
        }
    }
    
}


