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
    var currentImage:Int = 0
    
    @IBOutlet weak var imageview: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allow the user to interact the images for gestures
        self.imageview.isUserInteractionEnabled = true
        
        //Setting up the gestue for right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.imageview.addGestureRecognizer(swipeRight)
        
        //Setting up the gestue for left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.imageview.addGestureRecognizer(swipeLeft)
        
        
        
    }
    
    /**
        This is to display the images based on the index to
        i is the index
     */
    func displayImages(i index:Int){
        
        if ItemProviders[index].canLoadObject(ofClass: UIImage.self){
            ItemProviders[index].loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage else {return}
                    self.imageview.image = image
                }
                
            }
            
        }
        
    }
    
    /**
     This function is to respond to getsure a
     gesture is the to know which diretcion is being swipped
     
     Code for left and right only
     */
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer?) -> Void {
        
        if ItemProviders.count <= 0 {
            print("No images")
            return
        }
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            //Check which directiuon is being swipped
            switch swipeGesture.direction {
            //Swipped Left
            case UISwipeGestureRecognizer.Direction.left:
                
                // Add the current Image interger to go front
                if currentImage == ItemProviders.count - 1 { currentImage = 0 }
                else { currentImage += 1 }
                
                displayImages(i: currentImage)
            
            //Swipped Right
            case UISwipeGestureRecognizer.Direction.right:
                
                // Minus the current Image interger to go back
                if currentImage == 0 { currentImage = ItemProviders.count - 1 }
                else { currentImage -= 1 }
                
                displayImages(i: currentImage)
            default:
                break
            }
        }
    }
    
    //The is add the naviagtion button function
    @IBAction func presentPicker(_ sender: Any) {
        
        //Sett  up the PHPicker
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        //Open the PHPicker
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check if that is the seque using an identifier
        
        //Move to EditDeatailController
        if segue.identifier == "addDeatils" {
            let destination = segue.destination as! EditDetailsController
            destination.ItemProviders = self.ItemProviders

        }
    }
    
    
}

extension EditController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        ItemProviders = results.map(\.itemProvider)
        
        displayImages(i: 0)
    }
}
