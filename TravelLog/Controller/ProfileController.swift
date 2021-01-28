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
        
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        
        
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        //Get the posts
        DatabaseManager.shared.getPosts(postID: "2C110B33-A249-4FBE-A3F5-C38567B566A8", userID: UID!) { (posts) in
            for post in posts{
                print(post.title)
                
            }
            
            self.posts = posts
            
            self.collectionView.reloadData()
        }
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
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
    
    
}

extension ProfileController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let ItemProviders = results.map(\.itemProvider)
        
        if ItemProviders[0].canLoadObject(ofClass: UIImage.self){
            ItemProviders[0].loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage else {return}
                    self.imageView.image = image
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
        
        if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    cell.configure(with: image)
                }
            }
        
        
        
        return cell
    }
}

//Can specify the padding and width
extension ProfileController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}



