//
//  PostTableViewCell.swift
//  TravelLog
//
//  Created by school on 29/1/21.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var usernameLable: UILabel!
    @IBOutlet var titleLable: UILabel!
    
    var feed: HomeFeed?
    
    // set cell identifier
    static let identifier = "PostTableViewCell"
    var currentImage:Int = 0
    
    static func nib() -> UINib{
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        currentImage = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //configure the cell for imformation to display
    func configure(with model: HomeFeed){
        
        currentImage = 0
        
        postImageView.isUserInteractionEnabled = true
        feed = model
        
        if let url = model.profileImg {
            self.profileImageView.loadURL(url: url)
        }
        self.titleLable.text = model.title
        self.usernameLable.text = model.username
        self.postImageView.sd_setImage(with: URL(string: model.postImages[0]), placeholderImage: UIImage(named: "FooterLogin"))
        
        //Setting up the gestue for right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.postImageView.addGestureRecognizer(swipeRight)
        
        //Setting up the gestue for left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.postImageView.addGestureRecognizer(swipeLeft)
        
        
        
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
        self.postImageView.sd_setImage(with: url)
        
    }
    
}

//load images base on given URL
extension UIImageView{
    func loadString(urlString : String) {
            guard let url = URL(string: urlString)else {
                return
            }
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
    
    func loadURL(url : URL) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
}
