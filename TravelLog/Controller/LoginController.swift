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
        
        let userDefault =  UserDefaults.init(suiteName: "group.sg.mad2.TravelLog")!

        
        
        let e:String? = userDefault.string(forKey: "email")
        let p:String? = userDefault.string(forKey: "password")
        
        if let email = e, let password = p {
            txt_email.text = email
            txt_password.text = password
            self.loginClicked(txt_email)
        } else {
            txt_email.text = "jeyavishnu@gmail.com"
            txt_password.text = "Test123"
        }
        
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        
        //Get the text values
        guard let email:String =  txt_email.text, email != "" else {
            alert(title: "Empty Text", message: "The email text box is empty")
            return
        }
        
        guard let password:String = txt_password.text, password != "" else {
            alert(title: "Empty Text", message: "The password text box is empty")
            return
        }
        
        
        
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
    
    
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        
        
        self.present(alert, animated: true, completion: nil)

    }
    
}

