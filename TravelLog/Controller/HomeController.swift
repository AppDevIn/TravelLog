//
//  HomeController.swift
//  TravelLog
//
//  Created by school on 29/1/21.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth



class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet var tableview: UITableView!
    
    var feed:[HomeFeed] = []
    
    let db = Firestore.firestore()
    let userID = Constants.currentUser?.UID
    
    var user: User?
    var following: User?
    var posts:[Post] = []
    
    var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // register cell
        tableview.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        tableview.delegate = self
        tableview.dataSource = self
        
        //load items from firebase to tableview
        loadData()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableview.refreshControl = refreshControl
        
        
        DatabaseManager.shared.updateUser(userID: Constants.currentUser!.UID) { (user) in
            
            Constants.currentUser!.name = user.name
            Constants.currentUser!.profileLink = user.profileLink
            Constants.currentUser!.follower = user.follower
            Constants.currentUser!.following = user.following
            
            
        }
        
        
    }
    
    func loadData(){
        guard let following = Constants.currentUser?.following, following != [] else {return}
        
        DatabaseManager.shared.getPosts(users: following) { (post) in
            
            self.feed.append(post)
            
            print(self.feed)
            self.tableview.reloadData()
        }
        

    }
    
    @objc func refresh(_ sender: AnyObject ){
        
        guard let following = Constants.currentUser?.following, following != [] else {return}
        
        DatabaseManager.shared.getPosts(users: following) { (post) in
            
            self.feed.append(post)
            
            print(self.feed)
            self.tableview.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(with: feed[indexPath.row])
        return cell
    }
    
    //set image to fit cell fram size
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 + 40 + view.frame.size.width
    }
    
    //perform segue when cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detail", sender: self)
    }
    
    //pass current selected HomeFeed object to next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! PostDetailController
        destVC.feed = feed[tableview.indexPathForSelectedRow!.row]
    }
    
}


