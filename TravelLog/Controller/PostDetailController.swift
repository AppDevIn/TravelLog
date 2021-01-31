//
//  PostDetail.swift
//  TravelLog
//
//  Created by school on 30/1/21.
//

import Foundation
import UIKit
import SDWebImage

class PostDetailController: UIViewController {
    
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postBody: UITextView!
    var feed:HomeFeed?
    var post: Post!
    
    
    var currentImage:Int = 0
    
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
        
        self.postImg.isUserInteractionEnabled = true
        
        //Setting up the gestue for right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.postImg.addGestureRecognizer(swipeRight)
        
        //Setting up the gestue for left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.postImg.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer?) -> Void {
        
        print("Swipped")

        if (feed?.postImages.count)! <= 0 {
            print("No images")
            return
        }

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {


            //Check which directiuon is being swipped
            switch swipeGesture.direction {
            //Swipped Left
            case UISwipeGestureRecognizer.Direction.left:

                // Add the current Image interger to go front
                if currentImage == (feed?.postImages.count)! - 1 { currentImage = 0 }
                else { currentImage += 1 }

                displayImages(i: currentImage)

            //Swipped Right
            case UISwipeGestureRecognizer.Direction.right:

                // Minus the current Image interger to go back
                if currentImage == 0 { currentImage = (feed?.postImages.count)! - 1 }
                else { currentImage -= 1 }

                displayImages(i: currentImage)
            default:
                break
            }
        }
    }
    
    
    func displayImages(i index:Int){
        
        //Cover string to URL
        let url:URL = NSURL(string: feed?.postImages[index] as! String )! as URL
        self.postImg.sd_setImage(with: url, placeholderImage: UIImage(named: "FooterLogin"))
        
    }
    
    
    
    
}


