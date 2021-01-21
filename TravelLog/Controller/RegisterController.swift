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
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        
    }

    @IBAction func signUpClicked(_ sender: Any) {
        
        //Get the text values
        guard let email:String =  txt_email.text else { return }
        guard let password:String = txt_password.text else { return }
        guard let Cpassword:String = txt_cPassword.text else { return }
        
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
                
                //Move to the next storyboard
                let storyboard = UIStoryboard(name: "Content", bundle: nil) // File name of the story board
                let vc = storyboard.instantiateViewController(identifier: "Content") as UIViewController // name must set as the identifer in stroyboard
                vc.modalPresentationStyle = .fullScreen //
                self.present(vc, animated: true, completion: nil)
                
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

