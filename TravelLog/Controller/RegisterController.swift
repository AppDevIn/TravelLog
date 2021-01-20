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
        guard let email:String =  txt_email.text else { return }
        guard let password:String = txt_password.text else { return }
        guard let Cpassword:String = txt_cPassword.text else { return }
        
        print("Email " + email)
        print("Password " + password)
        print("Password " + Cpassword)
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            print("\(user.email!) login")
        }
    }
    
    @IBAction func loginClicked(_ sender: Any) {
    }
}

