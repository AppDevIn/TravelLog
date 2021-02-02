//
//  MyCollectionViewCell.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 28/1/21.
//

import UIKit
import SDWebImage

class MyCollectionViewCell: UICollectionViewCell {
    
    static let identifier =  "MyCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }
    
    public func configure(url:URL){
        self.imageView.sd_setImage(with: URL(string: url.absoluteString))
    }
    
    public func configure(with image:UIImage){
        imageView.image = image
    }
    
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
    
}
