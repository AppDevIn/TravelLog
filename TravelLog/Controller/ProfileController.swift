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
    
    let UID = Auth.auth().currentUser?.uid;
    var posts:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        //Get the Profile picture
        DatabaseManager.shared.getProfileImage(userID: UID!) { (url) in
            self.setUrlToImage(url: url, imageView: self.imageView)
        }
        
        
        //Add tab gesture into imageview
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
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



