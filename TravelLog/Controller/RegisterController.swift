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
        
        
        //Hide the password
        txt_password.isSecureTextEntry = true
        txt_cPassword.isSecureTextEntry = true
        
    }

    @IBAction func signUpClicked(_ sender: Any) {
        print("Clicked")
        //Get the text values
        guard let email:String =  txt_email.text, email != "" else {
            alert(title: "Empty Text", message: "The email text box is empty")
            return
        }
        guard let password:String = txt_password.text, password != "" else {
            alert(title: "Empty Text", message: "The password text box is empty")
            return
        }
        
        guard let Cpassword:String = txt_cPassword.text, Cpassword != "" else {
            alert(title: "Empty Text", message: "The confirm password text box is empty")
            return
        }
        
        guard let userName:String = txt_name.text, userName != "" else {
            alert(title: "Empty Text", message: "The user name text box is empty")
            return
        }
        
        //Check if the password the same
        if password == Cpassword {
            //Move to the next storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // File name of the story board
            let vc = storyboard.instantiateViewController(identifier: "Splash") as SplashScreenController // name must set as the identifer in stroyboard
            
            vc.usr = Login(email: email, password: password)
            vc.usr.userName = userName
            
            
            vc.isLogin = false
            
            vc.modalPresentationStyle = .fullScreen //
            self.present(vc, animated: true, completion: nil)
            
  
        } else {
            alert(title: "Password Error", message: "Password and confirm password must be the same")
            print("Is not the same password")
        }
        
        
      

    }
    
    @IBAction func loginClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // File name of the story board
        let vc = storyboard.instantiateViewController(identifier: "login") as UIViewController // name must set as the identifer in stroyboard
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

