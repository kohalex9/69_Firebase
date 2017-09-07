//
//  Student.swift
//  1_SimpleFirebase
//
//  Created by Alex Koh on 06/09/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import Foundation

class Student {
    var name: String = ""
    var age: Int = 0
    var ID: String = ""
    var email: String = ""
    var imageUrl: String = ""
    
    init(name: String, age: Int, ID: String, email: String, imageUrl: String) {
        self.name = name
        self.age = age
        self.ID = ID
        self.email = email
        self.imageUrl = imageUrl
    }
}
