//
//  RegisterController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 20/1/21.
//

import Foundation
import UIKit
import FirebaseAuth

class RegisterController : UIViewController {
    


    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var txt_cPassword: UITextField!
    @IBOutlet weak var txt_name: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        
    }

    @IBAction func signUpClicked(_ sender: Any) {
        print("Clicked")
        //Get the text values
        guard let email:String =  txt_email.text, email != "" else { return }
        guard let password:String = txt_password.text, password != "" else { return }
        guard let Cpassword:String = txt_cPassword.text, Cpassword != "" else { return }
        guard let userName:String = txt_name.text, userName != "" else { return }
        
        //Check if the password the same
        if password == Cpassword {
            
            //Create a new user
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                //Check if there is error
                guard let user = authResult?.user, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                print("\(user.email!) created")
                
                //Insert User deatils
                DatabaseManager.shared.insertUser(userID: user.uid, userName: userName) { (isSuccess) in
                    if isSuccess {
                        
                        Constants.currentUser = User(id: user.uid, userName: userName)
                        
                        //Move to the next storyboard
                        let storyboard = UIStoryboard(name: "Content", bundle: nil) // File name of the story board
                        let vc = storyboard.instantiateViewController(identifier: "Content") as UIViewController // name must set as the identifer in stroyboard
                        vc.modalPresentationStyle = .fullScreen //
                        self.present(vc, animated: true, completion: nil)
                        
                    } else {
                        print("Failed to store data")
                    }
                }
                
                
            }
        } else {
            print("Is not the same password")
        }
        
        
      

    }
    
    @IBAction func loginClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // File name of the story board
        let vc = storyboard.instantiateViewController(identifier: "login") as UIViewController // name must set as the identifer in stroyboard
        vc.modalPresentationStyle = .fullScreen //
        present(vc, animated: true, completion: nil)
    }
}

