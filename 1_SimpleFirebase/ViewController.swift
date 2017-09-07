//
//  ViewController.swift
//  1_SimpleFirebase
//
//  Created by Alex Koh on 06/09/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    var students: [Student] = []

    @IBOutlet weak var studentTableView: UITableView! {
        didSet {
            studentTableView.dataSource = self
            studentTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create a logout button programatically
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(signOutUser))
        
        fetchStudents()
    }
    
    func signOutUser() {
        do  {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil) //
        } catch let error as NSError {
           print(error.localizedDescription)
        }
        
    }
    
    func fetchStudents() {
        ref = Database.database().reference()
        
        //observe child added works as a loop return child individually
        //return each member of "students" one by one
        ref.child("students").observe(.childAdded, with: { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            print("info: \(info)")
            print(snapshot)
            
            //cast snapshot value to correct DataType
            if let age = info["age"] as? Int,
                let name = info["name"] as? String,
                let imageUrl = info["imageUrl"] as? String {
                
                //create new student object
                let newStudent = Student(name: name, age: age, ID: snapshot.key, email: "", imageUrl: imageUrl)
                
                //append to student array
                self.students.append(newStudent) //add self because we are inside a block
                
                //inefficient way
                //self.studentTableView.reloadData()
                
                //efficient way!
                //insert individual rows as we retrieve individual item
                let index = self.students.count - 1
                let indexPath = IndexPath(row: index, section: 0)
                self.studentTableView.insertRows(at: [indexPath], with: .right)
            }
        })
        
        //Inefficient method 
        //walap the members under "students"
//        ref.child("students").observe(.value, with: { (snapshot) in
//            guard let info = snapshot.value as? [String:Any] else {return}
//            
//            print(info)
//        })
        
        //Observer 3
        ref.child("students").observe(.childRemoved, with: { (snapShot) in
            guard let info = snapShot.value as? [String:Any] else {return}
            
            let deletedID = snapShot.key
            
            print(info)
            
            //filters through students returns index(deletedIndex) where boolean condition is fulfilled
            if let deletedIndex = self.students.index(where: { (student) -> Bool in
                return student.ID == deletedID
            }) {
                //Implement everything in this bracket if the student.id == deletedID
                self.students.remove(at: deletedIndex)
                let index = self.students.count - 1
                let indexPath = IndexPath(row: index, section: 0)
                
                self.studentTableView.deleteRows(at: [indexPath], with: .fade)
            }
        })
        
        //Observer 4
        ref.child("students").observe(.childChanged, with: { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            
            guard let name = info["name"] as? String,
                let age = info["age"] as? Int,
                let imageUrl = info["imageUrl"] as? String else {return}

            if let matchedIndex = self.students.index(where: { (student) -> Bool in
                return student.ID == snapshot.key
            }) {
                let changedStudent = self.students[matchedIndex]
                changedStudent.age = age
                changedStudent.name = name
                changedStudent.imageUrl = imageUrl
                
                let indexPath = IndexPath(row: matchedIndex, section: 0)
                
                self.studentTableView.reloadRows(at: [indexPath], with: .none)
            }
            
        })
    }
    

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = studentTableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as? UserReviewTableViewCell else {return UITableViewCell()}
        
        let student = students[indexPath.row]
        
        cell.nameLabel?.text = student.name
        cell.ageLabel?.text = "\(student.age) years old"
        
        //The following codes load the image on each cell of the tableView
        guard let url = URL(string: student.imageUrl) else {return UITableViewCell()}
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                   cell.imageLabel.image = UIImage(data: data)
                }
            }
        }
        task.resume()

        
        return cell
    }
}



extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
        
        let selectedStudent = students[indexPath.row]
        
        destination.selectedStudent = selectedStudent
        
        navigationController?.pushViewController(destination, animated: true)
    }
}






