//
//  LoginController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 20/1/21.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginController : UIViewController {
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        txt_password.isSecureTextEntry = true
        
        txt_email.text = "jeyavishnu@gmail.com"
        txt_password.text = "Test123"
        
        //Hide the activity indictor when stopped
        activityIndicator.hidesWhenStopped = true
        
        
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        
        //Get the text values
        guard let email:String =  txt_email.text else { return }
        guard let password:String = txt_password.text else { return }
        
        //Start the indicator when started
        self.activityIndicator.startAnimating()
        
        
        //Sign in into the user
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            
            //Check if there is error
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            print("\(user.email!) loginned")
            
            //Get the user
            DatabaseManager.shared.getUser(userID: user.uid) { (user) in
                //Save the user to constant
                Constants.currentUser = user
                
                //Stop the indicator when the data is recevied
                self.activityIndicator.stopAnimating()
                
                //Move to the next storyboard
                let storyboard = UIStoryboard(name: "Content", bundle: nil) // File name of the story board
                let vc = storyboard.instantiateViewController(identifier: "Content") as UIViewController // name must set as the identifer in stroyboard
                vc.modalPresentationStyle = .fullScreen //
                self.present(vc, animated: true, completion: nil)
            }
            
            

        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // File name of the story board
        let vc = storyboard.instantiateViewController(identifier: "register") as UIViewController // name must set as the identifer in stroyboard
        vc.modalPresentationStyle = .fullScreen //
        present(vc, animated: true, completion: nil)
    }
    
}

