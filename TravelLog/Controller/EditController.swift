//
//  EditController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 25/1/21.
//

import Foundation
import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class EditController : UIViewController {
    
    
    
    
    var ItemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
    var db: Firestore!
    
    let user = Auth.auth().currentUser
    
    //Get a UUID for the image
    let postId = UUID().uuidString
    
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageview.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.imageview.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.imageview.addGestureRecognizer(swipeLeft)
        
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        
        addInfo()
        
        
    }
    
    var currentImage:Int = 0
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer?) -> Void {
        
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                print("left")
                if currentImage == ItemProviders.count - 1 {
                    currentImage = 0
                    
                }else{
                    currentImage += 1
                }
                
                if ItemProviders[self.currentImage].canLoadObject(ofClass: UIImage.self){
                    ItemProviders[currentImage].loadObject(ofClass: UIImage.self) { (image, error) in
                        
                        
                        DispatchQueue.main.async {
                            guard let image = image as? UIImage else {return}
                            self.addImages(image,self.postId)
                            self.imageview.image = image
                        }
                        
                    }
                    
                }
                
                
            case UISwipeGestureRecognizer.Direction.right:
                    print("right")
                if currentImage == 0 {
                    currentImage = ItemProviders.count - 1
                }else{
                    currentImage -= 1
                }
                if ItemProviders[self.currentImage].canLoadObject(ofClass: UIImage.self){
                    ItemProviders[currentImage].loadObject(ofClass: UIImage.self) { (image, error) in
                        
                        DispatchQueue.main.async {
                            guard let image = image as? UIImage else {return}
                            self.imageview.image = image
                        }
                        
                    }
                    
                }
                
            default:
                break
            }
        }
    }
    
    func addInfo(){
    
        guard let id = user?.uid else {return}
        
        
        
        self.db.collection("users").document(id).collection("posts").document(postId).setData([
            "title": "God Jorney",
            "locations": "Heavean",
            "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Arcu ac tortor dignissim convallis aenean et tortor at risus. At lectus urna duis convallis. Nulla aliquet porttitor lacus luctus accumsan tortor posuere ac. Adipiscing enim eu turpis egestas pretium aenean pharetra magna."
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }
    }
    
    func addImages(_ image:UIImage, _ postid:String){
        
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
              // Uh-oh, an error occurred!
              return
            }
            
            self.db.collection("users").document(id).collection("posts").document(self.postId).setData([
                "images":[downloadURL.absoluteString]
                
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
    
    @IBAction func presentPicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func displayNextImage() {
        
        if let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageview.image
            
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                
                DispatchQueue.main.async {
                    guard let image = image as? UIImage, self.imageview.image == previousImage else {return}
                    self.imageview.image = image
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        displayNextImage()
    }
    
    
}

extension EditController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        ItemProviders = results.map(\.itemProvider)
        iterator = ItemProviders.makeIterator()
        displayNextImage()
    }
}
