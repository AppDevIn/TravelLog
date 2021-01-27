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
    
    
    
    
    var ItemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
    var db: Firestore!
    
    let user = Auth.auth().currentUser
    
    //Get a UUID for the image
    let postId = UUID().uuidString
    
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_locations: UITextField!
    @IBOutlet weak var txt_description: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        
        txt_title.delegate = self
        txt_locations.delegate = self
        txt_description.delegate = self
        
        
    }
    
    @IBAction func uploadData(_ sender: Any) {
        
        self.view.endEditing(true)
        
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
        
        if (description == "" && title == "" && location == "") {
            print("Empty text filed")
            return
        }
        
        if ItemProviders.count <= 0 {
            print("No images")
            return
        }
        
        
        uploadPostInfo(titleOfPost: title, location: location, decriptionOfPost: description)
        
        uploadPostImages(images: ItemProviders)
        
        clearTextField()
    }
    
    func uploadPostInfo(titleOfPost title:String, location loc:String, decriptionOfPost decription:String){
    
        guard let id = user?.uid else {return}
        
        self.db.collection("users").document(id).collection("posts").document(postId).setData([
            "title": title,
            "locations": loc,
            "description": decription
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }
    }
    
    func uploadPostImages(images img:[NSItemProvider]){
        
        for i in 0..<img.count {
            if ItemProviders[i].canLoadObject(ofClass: UIImage.self){
                ItemProviders[i].loadObject(ofClass: UIImage.self) { (image, error) in
                    
                    guard let image = image as? UIImage else {return}
                    self.addImages(image,self.postId)
                    
                }
                
            }
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
              return
            }
            
            
            self.db.collection("users").document(id).collection("posts").document(self.postId).setData([
                "images":FieldValue.arrayUnion([downloadURL.absoluteString])
                    
            ], merge: true) { err in
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
