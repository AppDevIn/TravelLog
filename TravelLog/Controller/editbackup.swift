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

class Editbackup : UIViewController {
    
    
    var selectedAssets = [PHAsset]()
    var images = [UIImage]()
    
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        view.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 720)
        collectionView.backgroundColor = UIColor(named: "White")
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
            
            images = []
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
            
        }
        
        print("complete photo array \(self.images)")
    }
    
    
}


extension Editbackup: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("delete tapped image")
        images.remove(at: indexPath.row)
        selectedAssets.remove(at: indexPath.row)
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

//layout.itemSize = CGSize(width: (view.frame.size.width/3)-3, height: (view.frame.size.width/3)-3)
//layout.minimumLineSpacing = 2
//layout.minimumInteritemSpacing = 2
//layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
// margin between each cell
extension Editbackup: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width/3)-3, height: (view.frame.size.width/3)-3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }


}




//extension Editbackup : PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        dismiss(animated: true)
//
//        ItemProviders = results.map(\.itemProvider)
//
//        displayImages(i: 0)
//    }4
//}
