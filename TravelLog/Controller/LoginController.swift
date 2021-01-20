//
//  LoginController.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 20/1/21.
//

import Foundation
import UIKit


class LoginController : UIViewController {
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        txt_password.isSecureTextEntry = true
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email:String =  txt_email.text else { return }
        guard let password:String = txt_password.text else { return }
        
        print("Email " + email)
        print("Password " + password)
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
    }
    
}

