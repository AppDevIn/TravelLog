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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var txtx_location: UITextField!
    @IBOutlet weak var txt_description: UITextView!
    @IBOutlet weak var dropDown: UIPickerView!
    
    var items:[CDPlace] = []
    
    var location:CDPlace?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context:NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        //Set up text field delgate
        txt_title.delegate = self
        txtx_location.delegate = self
        
        //Adding border to textview
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        txt_description.layer.borderWidth = 0.5
        txt_description.layer.borderColor = borderColor.cgColor
        txt_description.layer.cornerRadius = 5.0
        
        //Text view delgate
        txt_description.text = "Description"
        txt_description.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        txt_description.delegate = self
        
        
        
        
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
        
        if items != [] {
            dropDown.dataSource = self
            dropDown.delegate = self
            location = items[0] // Default vale
        } else {
            txtx_location.isHidden = false
            dropDown.isHidden = true
        }
        
    }
    
    @IBAction func uploadData(_ sender: Any) {
        
        self.view.endEditing(true)
        
        
        
        //Change the text from String? to String
        guard let title = txt_title.text, title != "" else {
            print("Empty title")
            alert(title: "Empty Text", message: "The title text box is empty")
            return
        }
        
        
        guard let description = txt_description.text, description != "" else {
            print("Empty description")
            alert(title: "Empty Text", message: "The description text box is empty")
            return
        }
        
        
        if !txtx_location.isHidden {
            guard let loc = txtx_location.text, loc != "" else {
                print("No location")
                alert(title: "Empty Text", message: "The location text bos is empty")
                return
            }
        }
        
        //Create the post object
        post = Post(title: title, decription: description, locations: location?.name ?? txtx_location.text!, images: [], postID: postId)
        
        //Start animating
        loading.startAnimating()
        
        //Upload the the info but not the imzage
        uploadPostInfo(post: post, place: location)
        
        //Upload the images
        uploadPostImages(images: ItemProviders)
        
        //Clearfiled upon uploading
        clearTextField()
    }
    
    /**
     Use firestore to upload the information into
     users/{id}/posts/{postID}
     */
    func uploadPostInfo(post p:Post, place: CDPlace?){
        
        guard let id = user?.uid else {return}
        
        self.db.collection("users").document(id).collection("posts").document(postId).setData([
            "title": p.title,
            "locations": p.locations,
            "description": p.decription,
            "date": Date(),
            "coordinate": place != nil ? [place?.lat, place?.lng] : []
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.postId)")
            }
        }
        
        self.db.collection("posts").document(postId).setData([
            "title": p.title,
            "locations": p.locations,
            "description": p.decription,
            "date": Date(),
            "uid":id,
            "coordinate": place != nil ? [place?.lat, place?.lng] : [],
            "userRef": db.document("users/\(id)")
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.postId)")
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
            Constants.posts.append(HomeFeed(post: post, user: Constants.currentUser!))
            let editController = self.navigationController?.viewControllers.first as! Editbackup
//            editController.images = []
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
                    
                    
                    if let err = err {
                        self.completed()
                        print("Error adding document: \(err)")
                        
                    } else {
                        print("Document added with ID: \(id)")
                    }
                }
                
                self.db.collection("posts").document(self.postId).setData([
                    "images":FieldValue.arrayUnion([downloadURL.absoluteString])
                    
                ], merge: true) { err in
                    
                    
                    if let err = err {
                        
                        print("Error adding document: \(err)")
                        
                    } else {
                        print("Document added with ID: \(id)")
                        self.completed()
                    }
                }
                
                print("Uploaded image: \(downloadURL)")
            }
            
            
        }
        
        
    }
    
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
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
        
        self.location = items[row]
        
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

extension EditDetailsController : UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Description" {
            txt_description.text = ""
            txt_description.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 0 {
            textView.text = "Description"
            textView.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            textView.resignFirstResponder()
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.count == 0 {
            textView.text = "Description"
            textView.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            textView.resignFirstResponder()
        }
        
        return true
    }
}

