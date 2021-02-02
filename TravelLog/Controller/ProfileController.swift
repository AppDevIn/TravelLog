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
import SDWebImage


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
    
    var collectionViewSelectedCell = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = UID  {
        } else {
            UID = Auth.auth().currentUser?.uid
            isCurrentUser = true
            
            if let user = Constants.currentUser {
                self.user = user
                
            }
            else {
                
                DatabaseManager.shared.getUser(userID: UID!) { (user) in
                    self.user = user
                    
                    self.viewDidAppear(true)
                }
            }
            
        }
        
        //If don't have user stored
        //Set the title
        self.btn_follow.title = isCurrentUser ? "Logout" : ((Constants.currentUser?.following.contains(self.UID!))! ? "Unfollow" : "Follow")
        
        
        
        
        
        
        
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
        DatabaseManager.shared.getPosts(userID: UID!) { (post) in
            DispatchQueue.main.async {
                self.posts.append(post)
                self.collectionView.reloadData()
            }

        }

        
        
        
        
        if isCurrentUser {
            //Add tab gesture into imageview
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
            //Get the name of the user and profile
            self.txt_name.text = Constants.currentUser?.name
            
            //Check if the image is nil
            if let url = Constants.currentUser?.profileLink {
                self.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "FooterLogin"))
            }
            
            
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Set the title of the page to the name of the user
        self.title = isCurrentUser ? "Profile" : user.name
        
        //Set the name
        self.txt_name.text = user.name
        
        //Set the follower and following
        self.txt_follower.text = "Follower: \(user.follower.count)"
        self.txt_following.text = "Following: \(user.following.count)"
        
        //Set the profile
        if let url = user.profileLink {
            //Cover string to URL
            let url:URL = NSURL(string: url)! as URL
            self.setUrlToImage(url: url, imageView: self.imageView)
        }
        
        
        
    }
    
    
    //Action that will be taken when the image is tapped
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
            let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    
    //function to set the url into the image
    func setUrlToImage(url:URL, imageView:UIImageView){
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile"))
    }
    
    @objc func refresh(_ sender: AnyObject) {
        
        reloadData()
        
    }
    
    func reloadData() {
        
        self.posts = []
        self.collectionView.reloadData()
        //Get the posts
        DatabaseManager.shared.getPosts(userID: UID!) { (post) in
            self.posts.append(post)
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
        } else if btn_follow.title == "Logout" {
            
            //Delete the user
            let userController = UserDataController()
            userController.deleteUser()
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            //Change button to text to follow
            btn_follow.title = "Follow"
            
            //Remove the UID into database
            let id = Auth.auth().currentUser?.uid
            DatabaseManager.shared.removeFollow(UID: id!, followerID: UID!)
        }
        
        
        
    }
    
}



extension ProfileController:UICollectionViewDelegate{
    
    //When a cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("Image Collection Tapped")
        collectionViewSelectedCell = indexPath.row
        self.performSegue(withIdentifier: "detail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! PostDetailController
        let post: Post = posts[collectionViewSelectedCell]
        destVC.feed = HomeFeed(title: post.title, decription: post.decription, locations: post.locations, images: post.images, postID: post.postID)
        destVC.feed?.user = user
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
        cell.configure(url: url)
        
        
        
        return cell
    }
}

//Can specify the padding and width
extension ProfileController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}


extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
            imageView.image = image
            DispatchQueue.main.async {
                guard let image = image as? UIImage else {return}
                self.imageView.image = image
                
                StorageManager.shared.setProfilePic(image: image, UID: self.UID!) { (success) in
                    print(success ? "Image Uploaded" : "Image Fail to upload")
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


