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
    
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        txt_password.isSecureTextEntry = true
        
        txt_email.text = "jeyavishnu@gmail.com"
        txt_password.text = "Test123"
        
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        
        //Get the text values
        guard let email:String =  txt_email.text else { return }
        guard let password:String = txt_password.text else { return }
        
        
        
        //Move to the next storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // File name of the story board
        let vc = storyboard.instantiateViewController(identifier: "Splash") as SplashScreenController // name must set as the identifer in stroyboard
        vc.usr = Login(email: email, password: password)
        
        vc.isLogin = true
        
        vc.modalPresentationStyle = .fullScreen //
        self.present(vc, animated: true, completion: nil)
        

    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // File name of the story board
        let vc = storyboard.instantiateViewController(identifier: "register") as UIViewController // name must set as the identifer in stroyboard
        vc.modalPresentationStyle = .fullScreen //
        present(vc, animated: true, completion: nil)
    }
    
}

