//
//  SearchResult.swift
//  FlickrSearch
//

import Foundation
import UIKit

struct FlickrPhoto {
    
    let photoId: String
    let farm: Int
    let secret: String
    let server: String
    let title: String
    
    var photoUrl: NSURL {
        return NSURL(string: "http://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret).jpg")!
    }
    
}
