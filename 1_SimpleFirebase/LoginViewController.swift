//
//  LoginViewController.swift
//  1_SimpleFirebase
//
//  Created by Alex Koh on 06/09/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        loginUser()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if there is any user logged in
        if Auth.auth().currentUser != nil {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {return}
            
            //skip straight to homepage
            present(vc, animated: true, completion: nil)
        }
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loginUser() {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        if self.emailTextField.text == "" {
            self.createErrorVC("Empty empty fill", "Please input valid email")
            return
        } else if self.passwordTextField.text == "" {
            self.createErrorVC("Password empty fill", "Please enter valid password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let validError = error {
                print(validError.localizedDescription)
                self.createErrorVC("Error", validError.localizedDescription)
            }
            
            //if user is valid, we perform the following code
            if let user = user {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {return}
                
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        
        
    }
}














