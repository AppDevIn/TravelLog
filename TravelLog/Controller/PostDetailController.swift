//
//  PostDetail.swift
//  TravelLog
//
//  Created by school on 30/1/21.
//

import Foundation
import UIKit

class PostDetailController: UIViewController {
    
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postBody: UITextView!
    var feed:HomeFeed?
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (feed != nil) {
            self.postImg.loadString(urlString: feed!.postImages[0])
            self.postTitle.text = feed?.title
            self.postLocation.text = feed?.locations
            self.postBody.text = feed?.description
        }
        else{
            self.postImg.loadString(urlString: post.images[0])
            self.postTitle.text = post.title
            self.postLocation.text = post.locations
            self.postBody.text = post.decription
        }
        
    }
    
}


