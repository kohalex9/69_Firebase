//
//  ProfileViewController.swift
//  1_SimpleFirebase
//
//  Created by Alex Koh on 07/09/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {

    var selectedStudent: Student?
    var ref: DatabaseReference!
    var imageUrl: String = ""

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.isUserInteractionEnabled = false //keyboard will not come out when the user tappes on the keyboard
        }
    }
    @IBOutlet weak var ageTextField: UITextField! {
        didSet {
            ageTextField.isUserInteractionEnabled = false //keyboard will not come out when the user tappes on the keyboard
        }
    }
    @IBOutlet weak var editBtn: UIButton! {
        didSet {
            editBtn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let name = selectedStudent?.name,
            let age = selectedStudent?.age,
            let urlImage = selectedStudent?.imageUrl else {
                return
        }
        
        nameTextField.text = name
        ageTextField.text = "\(age)"
        loadImage(urlString: urlImage)
    }
    
    func loadImage(urlString: String) {
        //1.url
        //2.session
        //3.task
        //4.start
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    self.profilePicImageView.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }
    
    func updateProfilePicEnable() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func editBtnTapped() {
        if editBtn.titleLabel?.text == "Edit" {
            ageTextField.isUserInteractionEnabled = true
            nameTextField.isUserInteractionEnabled = true
            updateProfilePicEnable() //Enable user to change profile pic
            editBtn.setTitle("Done", for: .normal)
        } else {
            ageTextField.isUserInteractionEnabled = false
            nameTextField.isUserInteractionEnabled = false
            
            ref = Database.database().reference()
            
            //get the id of the specific student
            guard let id = selectedStudent?.ID,
                    let name = nameTextField.text,
                    let age = ageTextField.text,
                    let ageInt = Int(age) else {return}
            
            let post : [String:Any] = ["name": name, "age":ageInt, "imageUrl": imageUrl]
            
            //dig path to the student
        ref.child("students").child(id).updateChildValues(post)
            
            //
            
            editBtn.setTitle("Edit", for: .normal)
        }
        
        //navigationController?.popViewController(animated: true)
    }
    
    func uploadImageToStorage(_ image: UIImage) {
        let ref = Storage.storage().reference()
        
        let timeStamp = Date().timeIntervalSince1970
        
        //compress image so that the image isn't too big
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //metadata gives us the url to retrieve the data on the cloud
        
        ref.child("\(timeStamp).jpeg").putData(imageData, metadata: metaData) { (meta, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                self.imageUrl = downloadPath
                self.profilePicImageView.image = image
            }
        }
    }
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            //no matter what happens, this will get executed
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        uploadImageToStorage(image)
        
        
    }
}













