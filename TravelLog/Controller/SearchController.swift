//
//  SearchController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 29/1/21.
//

import Foundation
import UIKit


class SearchController: UIViewController {
    
    var users:[User] = []
    
    @IBOutlet weak var tabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelView.delegate = self
        tabelView.dataSource = self
    }
    
    @IBAction func searching(_ sender: Any) {
        let textField = sender as! UITextField
        
        guard let value = textField.text else {return}
        
        DatabaseManager.shared.searchUser(name: value) { (users) in
            self.users = users
            self.tabelView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDatails", let indexPath = tabelView.indexPathForSelectedRow{
            let destination = segue.destination as! ProfileController
            let user:User = users[indexPath.item]
            destination.UID = user.UID
            destination.user = user
        }
    }
}


extension SearchController:UITableViewDataSource{
    //The number of section the table have
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    //The length of each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    //How each item look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get the cell based of the identifer
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        //Set the text based of the data
        cell.textLabel!.text = users[indexPath.item].name
        
        return cell
    }
    
    //Allow the given to e
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension SearchController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "userDatails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}
