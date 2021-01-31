//
//  EditDetailsController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 27/1/21.
//

import Foundation
import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class EditDetailsController : UIViewController {
    
    var appDelegate:AppDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    
    
    var ItemProviders: [NSItemProvider] = []
    
    
    var db: Firestore!
    
    let user = Auth.auth().currentUser
    
    //Get a UUID for the image
    let postId = UUID().uuidString
    
    var post:Post = Post()
    
    // How many image added in the database
    var count = 0
    var lengthOfImage:Int = 0 //The number of images in the array
    
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_description: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var txtx_location: UITextField!
    @IBOutlet weak var dropDown: UIPickerView!
    
    var items:[CDPlace] = []
    
    var location:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        //Set up text field delgate
        txt_title.delegate = self
        txt_description.delegate = self
        txtx_location.delegate = self
        
        //Hide the loading bar when stopped
        loading.hidesWhenStopped = true
        
        //Init the length of image
        lengthOfImage = ItemProviders.count
        
        
        
        
        do {
            let result = try context.fetch(CDPlace.fetchRequest())
            var list:[CDPlace] = []
            
            let now = Date()
            
            
            
            for data in result as! [CDPlace]{
                
                let elapsedTime = now.timeIntervalSince(data.departure!)
                
                // convert from seconds to hours, rounding down to the nearest hour
                let hours = floor(elapsedTime / 60 / 60)
                
                if(hours > 24){
                    context.delete(data)
                    try context.save()
                } else {list.append(data)}
                
            }
            items = list
            
            
        } catch {
            print(error)
            
            
        }
        
        if false {
            dropDown.dataSource = self
            dropDown.delegate = self
        } else {
            txtx_location.isHidden = false
            dropDown.isHidden = true
        }
        
    }
    
    @IBAction func uploadData(_ sender: Any) {
        
        self.view.endEditing(true)
        
        
        
        //Change the text from String? to String
        guard let title = txt_title.text else {
            print("Empty title")
            return
        }
        
        
        guard let description = txt_description.text else {
            print("Empty description")
            return
        }
        
        //Check if the text is empty
        if (description == "" && title == "") {
            print("Empty text filed")
            return
        }
        
        //Check if the images is empty
        if ItemProviders.count <= 0 {
            print("No images")
            return
        }
        
        guard !txtx_location.isHidden, let loc = txtx_location.text, loc != "" else {
            print("No location")
            return
        }
        
        //Create the post object
        post = Post(title: title, decription: description, locations: location, images: [])
        
        //Start animating
        loading.startAnimating()
        
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
    func uploadPostImages(images img:[NSItemProvider]){
        
        for i in 0..<img.count {
            if ItemProviders[i].canLoadObject(ofClass: UIImage.self){
                ItemProviders[i].loadObject(ofClass: UIImage.self) { (image, error) in
                    
                    //Convert to UIImage
                    guard let image = image as? UIImage else {return}
                    
                    //Add the image to firestoage
                    self.addImages(image, self.postId)
                    
                }
                
            }
        }
    }
    
    
    
    
    func clearTextField()  {
        //Empty the text fields
        txt_title.text = ""
        dropDown.selectedRow(inComponent: 0)
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
            let editController = self.navigationController?.viewControllers.first as! EditController
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

//MARK: -TextField Delegate
extension EditDetailsController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

//MARK: -UIPicker Delegate and Datasource
extension EditDetailsController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return items[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.location = items[row].name!
        
    }
    
}

extension EditDetailsController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    
}


