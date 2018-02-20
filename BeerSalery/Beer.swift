//
//  Beer.swift
//  BeerSalery
//
//  Created by Dani Lihardja on 2/20/18.
//  Copyright © 2018 Prince Hendrie. All rights reserved.
//

import Foundation

class Beer {
    var id: Int
    var name: String
    var description: String
    var image: String
    
    init(id: Int,
         name: String,
         description: String,
         image : String) {
        
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        
    }
}
