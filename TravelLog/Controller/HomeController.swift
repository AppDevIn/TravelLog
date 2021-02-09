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



class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyCustomCellDelegator{
    
    
    
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
        guard let following = Constants.currentUser?.following else {return}
        
        guard following.count != 0 else {
            self.feed = Constants.posts
            self.tableview.reloadData()
            return
            
        }
        
        DatabaseManager.shared.getPosts(users: following) { (posts) in
            DispatchQueue.main.async {
                self.feed = posts.count == 0 ? Constants.posts : posts
                self.tableview.reloadData()
            }
        }
        

    }
    
    @objc func refresh(_ sender: AnyObject ){
        
        self.feed = []
        self.tableview.reloadData()
        guard let following = Constants.currentUser?.following else {return}
        
        guard following.count != 0 else {
            self.feed = Constants.posts
            self.tableview.reloadData()
            self.refreshControl.endRefreshing()
            return
            
        }
        
        
        DatabaseManager.shared.getPosts(users: following) { (posts) in
            DispatchQueue.main.async {
                self.feed = posts.count == 0 ? Constants.posts : posts
                self.tableview.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func callSegueFromCell(myData dataobject: HomeFeed) {
        self.performSegue(withIdentifier: "postAuthor", sender: dataobject)
        print("self called")
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
        cell.delegate = self
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
        if segue.identifier == "detail"{
            let destVC = segue.destination as! PostDetailController
            destVC.feed = feed[tableview.indexPathForSelectedRow!.row]
        }
        if segue.identifier == "postAuthor"{
            let destvc = segue.destination as! ProfileController
            
            let post = sender as? HomeFeed
            
            destvc.UID = post?.user?.UID
            destvc.user = (post?.user)!
            
            print("segue activited")
        }
    }
    

    
}


