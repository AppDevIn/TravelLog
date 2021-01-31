//
//  PostTableViewCell.swift
//  TravelLog
//
//  Created by school on 29/1/21.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var usernameLable: UILabel!
    @IBOutlet var titleLable: UILabel!
    
    
    // set cell identifier
    static let identifier = "PostTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //configure the cell for imformation to display
    func configure(with model: HomeFeed){
        
        if let url = model.profileImg {
            self.profileImageView.loadURL(url: url)
        }
        self.titleLable.text = model.title
        self.usernameLable.text = model.username
        self.postImageView.sd_setImage(with: URL(string: model.postImages[0]), placeholderImage: UIImage(named: "FooterLogin"))
    }
    
}

//load images base on given URL
extension UIImageView{
    func loadString(urlString : String) {
            guard let url = URL(string: urlString)else {
                return
            }
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
    
    func loadURL(url : URL) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
}
