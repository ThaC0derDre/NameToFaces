//
//  Person.swift
//  NameToFaces
//
//  Created by Andres Gutierrez on 2/7/22.
//

import UIKit

class Person: NSObject {

    var name: String
    var image: String
    init(name: String, image: String) {
        self.name   = name
        self.image  = image
    }
}
