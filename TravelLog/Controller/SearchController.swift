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
        
        tabelView.dataSource = self
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
        cell.textLabel!.text = "test cell"
        
        return cell
    }
    
    //Allow the given to e
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
