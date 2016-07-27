//
//  favorites.swift
//  FS-Tabbed
//
//  Created by Abhijith Sreekar on 9/2/16.
//  Copyright © 2016 Abhijith Sreekar. All rights reserved.
//

import Foundation

class favorites{
    
    let title: String
    let comments: String
    let imageURL : String
   
    init(title:String, comments:String, imageURL:String){
        self.title = title
        self.comments = comments
        self.imageURL = imageURL
    }
}