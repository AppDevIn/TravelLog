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

class EditController : UIViewController {
    
    
    
    
    var ItemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
    var db: Firestore!
    
    let user = Auth.auth().currentUser
    
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
        var ref: DocumentReference? = nil
        
        guard let id = user?.uid else {return}
        
        
        
        db.collection("users").document(id).setData([
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
