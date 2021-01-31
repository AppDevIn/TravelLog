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
    var post:HomeFeed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postImg.loadString(urlString: post!.postImages)
        self.postTitle.text = post?.title
        self.postLocation.text = post?.locations
        self.postBody.text = post?.description
        
    }
    
}


