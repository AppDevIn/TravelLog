//
//  EditController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 25/1/21.
//

import Foundation
import UIKit
import PhotosUI
import BSImagePicker
import Photos
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class Editbackup : UIViewController{
    
    
    var selectedAssets = [PHAsset]()
    var images = [UIImage]()
    @IBOutlet weak var btn_next: UIButton!
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
    }
    
    @IBAction func camera(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    //The is add the naviagtion button function
    @IBAction func presentPicker(_ sender: Any) {
        initimage()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check if that is the seque using an identifier
        
        //Move to EditDeatailController
        if segue.identifier == "addDeatils" {
            let destination = segue.destination as! EditDetailsController
            destination.ItemProviders = self.images
            
        }
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        
        if images.count > 0 {
            performSegue(withIdentifier: "addDeatils", sender: nil)
        } else {
            alert(title: "Empty Images", message: "Please add images through the camera Icon or the photos")
        }
    }
    
    
    func initimage(){
        
        let imagePicker = ImagePickerController()
        
        presentImagePicker(imagePicker, select: { (asset: PHAsset) -> Void in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
            
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets:[PHAsset]) -> Void in
            // User canceled selection.
        }, finish: { (assets: [PHAsset]) -> Void in
            // User finished selection assets.
            
            for i in 0..<assets.count{
                self.selectedAssets.append(assets[i])
            }
            self.convertAssetsToImg()
            
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    
    
    func convertAssetsToImg() -> Void {
        
        if selectedAssets.count != 0{
            
            for i in 0..<selectedAssets.count{
                
                // reciving request to convert assets to images
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: .zero, contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in thumbnail = result!
                })
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                if images.contains(newImage!){
                    print("image exist")
                }
                else{
                    self.images.append(newImage! as UIImage)
                    
                }
            }
            
            selectedAssets = []
            
            //The button is enabled if there is images
            btn_next.isEnabled = (images.count >= 0)
            
            
        }
        
        print("complete photo array \(self.images)")
    }
    
    
    
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}







extension Editbackup: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("delete tapped image")
        images.remove(at: indexPath.row)
        
        print(images)
        print(selectedAssets)
        self.collectionView.reloadData()
    }
}

extension Editbackup: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.configure(with: images[indexPath.row])
        
        return cell
    }
}

// margin between each cell
extension Editbackup: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}

extension Editbackup: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        images.append(image)
        collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)

    }
}
