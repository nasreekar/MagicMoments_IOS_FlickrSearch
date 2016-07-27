//
//  SearchResultCell.swift
//  FlickrSearch
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    
    func setupWithPhoto(flickrPhoto: FlickrPhoto) {
        resultTitleLabel.text = flickrPhoto.title
        let data = NSData(contentsOfURL: flickrPhoto.photoUrl)
        resultImageView.image = UIImage(data: data!)
    }
    
}
