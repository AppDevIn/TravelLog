//
//  ProfileController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 28/1/21.
//

import Foundation
import UIKit
import FirebaseAuth
import PhotosUI


class ProfileController:UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txt_name: UILabel!
    
    @IBOutlet weak var txt_following: UILabel!
    @IBOutlet weak var txt_follower: UILabel!
    @IBOutlet weak var btn_follow: UIBarButtonItem!
    
    var UID:String?
    var posts:[Post] = []
    var isCurrentUser:Bool = false
    
    var refreshControl = UIRefreshControl()
    var user:User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = UID  {} else {
            UID = Auth.auth().currentUser?.uid
            isCurrentUser = true
            
            if let user = Constants.currentUser {
                self.user = user
            }
            else {
                //If don't have user stored
                DatabaseManager.shared.getUser(userID: UID!) { (user) in
                    self.user = user
                }
            }
            
        }
        
        //Set the name
        self.txt_name.text = user.name
        
        //Set the profile
        if let url = user.profileLink {
            self.setUrlToImage(url: url, imageView: self.imageView)
        }
        
        
        //Set the follower and following
        self.txt_follower.text = "Follower: \(user.follower.count)"
        self.txt_following.text = "Following: \(user.following.count)"
        
        //Set the title
        self.btn_follow.title = user.follower.contains(self.UID!) ? "Unfollow" : "Follow"

        
        
        
        //Set up the refresh for the collection view
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        
        //Make a circular border the image view
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        
        //Register the custom cell
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView.collectionViewLayout = layout
        
        
        //Set up the delgate for the collectio view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        //Get the posts
        DatabaseManager.shared.getPosts(userID: UID!) { (posts) in
            self.posts = posts
            self.collectionView.reloadData()
        }



        
        
        if isCurrentUser {
            //Add tab gesture into imageview
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
            //Get the name of the user and profile
            self.txt_name.text = Constants.currentUser?.name
            self.setUrlToImage(url: (Constants.currentUser?.profileLink)!, imageView: self.imageView)
            
            //Hide the button
            if btn_follow.tintColor != UIColor.clear {
                var tintColorsOfBarButtons = [UIBarButtonItem: UIColor]()
                tintColorsOfBarButtons[btn_follow] = btn_follow.tintColor
                btn_follow.tintColor = UIColor.clear
                btn_follow.isEnabled = false
            }
            
        }
        
    }
    
    
    //Action that will be taken when the image is tapped
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        //Sett  up the PHPicker
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        //Open the PHPicker
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    
    //function to set the url into the image
    func setUrlToImage(url:URL, imageView:UIImageView){
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                imageView.image = image
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        
        //Get the posts
        DatabaseManager.shared.getPosts(userID: UID!) { (posts) in
            self.posts = posts
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    @IBAction func followUser(_ sender: Any) {
        
        
        if btn_follow.title == "Follow"{
            //Change button to text to unfollow
            btn_follow.title = "Unfollow"
            
            //Insert the UID into database
            let id = Auth.auth().currentUser?.uid
            DatabaseManager.shared.insertFollow(UID: id!, followerID: UID!)
        } else {
            //Change button to text to follow
            btn_follow.title = "Follow"
            
            //Remove the UID into database
            let id = Auth.auth().currentUser?.uid
            DatabaseManager.shared.removeFollow(UID: id!, followerID: UID!)
        }
        

        
    }
    
}


//The PHPicker delgate
extension ProfileController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let ItemProviders = results.map(\.itemProvider)
        
        //If Zero exit
        guard ItemProviders.count > 0 else {return}
        
        if ItemProviders[0].canLoadObject(ofClass: UIImage.self){
            ItemProviders[0].loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage else {return}
                    self.imageView.image = image
                    
                    StorageManager.shared.setProfilePic(image: image, UID: self.UID!) { (success) in
                        print(success ? "Image Uploaded" : "Image Fail to upload")
                    }
                }
                
            }
            
        }
        
        
    }
}



extension ProfileController:UICollectionViewDelegate{
    
    //When a cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
        
        print("Image Collection Tapped")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
    }
}

extension ProfileController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        //Cover string to URL
        let url:URL = NSURL(string: posts[indexPath.item].images[0])! as URL
        setUrlToImage(url: url, imageView: cell.imageView)
        
        
        
        return cell
    }
}

//Can specify the padding and width
extension ProfileController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}



