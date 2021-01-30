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
    }
    
    func loadData(){
        DatabaseManager.shared.getUser(userID: userID!) { (user) in
            //get the ID of the accounts the user is following
            Constants.currentUser = user
            self.user = user
            print(self.user?.following ?? "")
            
            //get all the account post that the user is following
            for x in self.user!.following{
                DatabaseManager.shared.getUser(userID: x) { (User) in
                    self.following = User
                    print(self.following?.post ?? "")
                    
                    // get the posts
                    DatabaseManager.shared.getPosts(userID: self.following!.UID) { (Post) in
                        self.posts = Post
                        
                        //adding HomeFeed object base on the amount of post the user have
                        for i in self.posts{
                            self.feed.append(HomeFeed(postImages: "https://media.vogue.in/wp-content/uploads/2018/04/Your-ultimate-guide-to-Tokyo-Japan1.jpg", porfileImg: (self.following?.profileLink)!, username: self.following!.name, title: i.title, description: i.decription, locations: i.locations))
                        }
                        print(self.feed)
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject ){
        loadData()
        self.refreshControl.endRefreshing()
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
        destVC.post = feed[tableview.indexPathForSelectedRow!.row]
    }
    
}


