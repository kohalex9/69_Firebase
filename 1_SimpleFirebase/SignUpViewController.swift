//
//  SignUpViewController.swift
//  1_SimpleFirebase
//
//  Created by Alex Koh on 06/09/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    var profilePicUrl: String = ""
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var ref: DatabaseReference!
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        signUpUser()
    }
    
    @IBAction func uploadBtnTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func signUpUser() {
        guard let email = emailTextField.text,
                let password = passwordTextField.text,
                let confirmPassword = confirmPasswordTextField.text else {return}
        
        if profileImageView.image == nil {
            createErrorVC("Missing image", "A profile image must be picked")
            return
        }
        
        if password != confirmPassword {
            createErrorVC("Password Error", "Password does not match")
            return
        } else if email == "" || password == "" {
            createErrorVC("Missing input field", "Input field must be filled")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.createErrorVC("Error", error.localizedDescription)
            }
            
            if let validUser = user {
                let ref = Database.database().reference()
                
                let randomAge = Int(arc4random_uniform(30) + 1)
                
                let post: [String:Any] = ["age":randomAge, "name":email, "imageUrl" : self.profilePicUrl]
                
                //validUser.uid is the random id given by Firebase at authentication
                ref.child("students").child(validUser.uid).setValue(post) //option one
                //ref.child("students").childByAutoId() //option two
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func uploadToStorage(_ image: UIImage) {
        let ref = Storage.storage().reference()
        
        let timeStamp = Date().timeIntervalSince1970
        
        //compress the image so that the image isn't too big
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
    
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //metadata - gives us the url to retrieve the data on the cloud
        
        ref.child("\(timeStamp).jpeg").putData(imageData, metadata: metaData) { (meta, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                self.profilePicUrl = downloadPath
                self.profileImageView.image = image
            }
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            //no matter what happens, this code will run
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info [UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        uploadToStorage(image)
        
    }
    
}

















