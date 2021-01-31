//
//  EditDetailsController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 27/1/21.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class EditDetailsController : UIViewController {
    
    
    
    
    var ItemProviders: [UIImage] = []
    
    
    var db: Firestore!
    
    let user = Auth.auth().currentUser
    
    //Get a UUID for the image
    let postId = UUID().uuidString
    
    var post:Post = Post()
    
    // How many image added in the database
    var count = 0
    var lengthOfImage:Int = 0 //The number of images in the array
    
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_locations: UITextField!
    @IBOutlet weak var txt_description: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        //Set up text field delgate
        txt_title.delegate = self
        txt_locations.delegate = self
        txt_description.delegate = self
        
        //Hide the loading bar when stopped
        loading.hidesWhenStopped = true
        
        //Init the length of image
        lengthOfImage = ItemProviders.count
        
        
    }
    
    @IBAction func uploadData(_ sender: Any) {
        
        self.view.endEditing(true)
        
        loading.startAnimating()
        
        //Change the text from String? to String
        guard let title = txt_title.text else {
            print("Empty title")
            return
        }
        
        guard let location = txt_locations.text else {
            print("Empty location")
            return
        }
        
        
        guard let description = txt_description.text else {
            print("Empty description")
            return
        }
        
        //Check if the text is empty
        if (description == "" && title == "" && location == "") {
            print("Empty text filed")
            return
        }
        
        //Check if the images is empty
        if ItemProviders.count <= 0 {
            print("No images")
            return
        }
        
        //Create the post object
        post = Post(title: title, decription: description, locations: location, images: [])
        
        //Upload the the info but not the imzage
        uploadPostInfo(post: post)
        
        //Upload the images
        uploadPostImages(images: ItemProviders)
        
        //Clearfiled upon uploading
        clearTextField()
    }
    
    /**
     Use firestore to upload the information into
     users/{id}/posts/{postID}
     */
    func uploadPostInfo(post p:Post){
        
        guard let id = user?.uid else {return}
        
        
        self.db.collection("users").document(id).collection("posts").document(postId).setData([
            "title": p.title,
            "locations": p.locations,
            "description": p.decription
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }
    }
    
    //To upload the images with the addImage helper
    func uploadPostImages(images img:[UIImage]){
        
        for image in img {
            
            //Add the image to firestoage
            self.addImages(image, self.postId)            
            
        }
    }
    
    
    
    
    func clearTextField()  {
        //Empty the text fields
        txt_title.text = ""
        txt_locations.text = ""
        txt_description.text = ""
        
        //Remove the array of images
        ItemProviders = []
    }
    
    /**
     When all the images is upload
     this function will be called
     */
    func completed() -> Void {
        self.count += 1
        
        if self.count >= self.lengthOfImage {
            self.loading.stopAnimating()
            let editController = self.navigationController?.viewControllers.first as! Editbackup
            editController.ItemProviders = []
            editController.imageview.image = UIImage(named: "FooterLogin")
            
            self.navigationController?.popViewController(animated: true)
            
            
        }
    }
    
    /**
     Add the images to firebase stoage
     into path users/{uid}/{postid}
     */
    func addImages(_ image:UIImage, _ postid:String) {
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        
        //Get a UUID for the image
        let uuid = UUID().uuidString
        
        //Get the user id
        guard let id = user?.uid else {return}
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child("users/\(id)/\(postId)/\(uuid).jpg")
        
        //Get the data
        guard let uploadData = image.pngData() else {return}
        
        
        
        
        // Upload the file to the path "images/rivers.jpg"
        imageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                
                
                guard let downloadURL = url else {
                    self.completed()
                    return
                }
                
                self.post.images.append(downloadURL.absoluteString)
                
                
                
                
                self.db.collection("users").document(id).collection("posts").document(self.postId).setData([
                    "images":FieldValue.arrayUnion([downloadURL.absoluteString])
                    
                ], merge: true) { err in
                    self.completed()
                    
                    if let err = err {
                        
                        print("Error adding document: \(err)")
                        
                    } else {
                        print("Document added with ID: \(id)")
                    }
                }
                
                print("Uploaded image: \(downloadURL)")
            }
            
            
        }
        
        
    }
    
    
    
}


extension EditDetailsController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
