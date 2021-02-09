//
//  SplashScreenController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 31/1/21.
//

import Foundation
import SwiftUI
import FirebaseAuth

class SplashScreenController : UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var isLogin:Bool = true
    var databaseLogin:Bool = true
    var usr:Login!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        if isLogin {
            //Sign in into the user
            Auth.auth().signIn(withEmail: usr.email, password: usr.password) { (authResult, error) in
                
                
                //Check if there is error
                guard let user = authResult?.user, error == nil else {
                    print(error!.localizedDescription)
                    self.alert(title: "Error", message: error!.localizedDescription)
                    
                    
                    return
                }
                
                print("\(self.usr.email) loginned")
                
                //Get the user
                DatabaseManager.shared.getUser(userID: user.uid) { (user) in
                    //Save the user to constant
                    Constants.currentUser = user
                    
            
                    
                    DatabaseManager.shared.getPosts(users: [Constants.currentUser!.UID]) { (posts) in
                        Constants.posts = posts
                        
                        
                        //Stop the indicator when the data is recevied
                        self.activityIndicator.stopAnimating()
                        
                        if !self.databaseLogin {
                            //Save data of the user
                            let userData = UserDataController()
                            userData.saveUser(email: self.usr.email, password: self.usr.password)
                        }
                        
                        //Move to the next storyboard
                        let storyboard = UIStoryboard(name: "Content", bundle: nil) // File name of the story board
                        let vc = storyboard.instantiateViewController(identifier: "Content") as UIViewController // name must set as the identifer in stroyboard
                        vc.modalPresentationStyle = .fullScreen //
                        self.present(vc, animated: true, completion: nil)
                    }
                    
     
                    

                }
                
                

            }
        } else {
            
            //Create a new user
            Auth.auth().createUser(withEmail: usr.email, password: usr.password) { (authResult, error) in
                //Check if there is error
                guard let user = authResult?.user, error == nil else {
                    print(error!.localizedDescription)
                    self.alert(title: "Error", message: error!.localizedDescription)
                    return
                }
                
                print("\(user.email!) created")
                
                //Insert User deatils
                DatabaseManager.shared.insertUser(userID: user.uid, userName: self.usr.userName!) { (isSuccess) in
                    self.activityIndicator.stopAnimating()
                    if isSuccess {
                        
                        let U:User = User(id: user.uid, userName: self.usr.userName!)
                        
                        U.email = self.usr.email
                        U.email = self.usr.password
                        
                        Constants.currentUser = U
                        
                        //Save data of the user
                        let userData = UserDataController()
                        userData.saveUser(email: self.usr.email, password: self.usr.password)
                        
                        //Move to the next storyboard
                        let storyboard = UIStoryboard(name: "Content", bundle: nil) // File name of the story board
                        let vc = storyboard.instantiateViewController(identifier: "Content") as UIViewController // name must set as the identifer in stroyboard
                        vc.modalPresentationStyle = .fullScreen //
                        self.present(vc, animated: true, completion: nil)
                        
                    } else {
                        print("Failed to store data")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                
            }
            
        }
        
    }
    
    
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
            self.dismiss(animated: true, completion: nil)
        }))
        
        
        self.present(alert, animated: true, completion: nil)

    }
    
}


class Login {
    
    var email: String
    var password:String
    var userName:String?
    
    
    init(email:String, password:String) {
        self.email = email
        self.password = password
    }
}
