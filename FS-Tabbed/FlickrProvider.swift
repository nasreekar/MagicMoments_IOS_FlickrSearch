//
//  FlickrAPI.swift
//  FlickrSearch
//

import Foundation

class FlickrProvider {

    typealias FlickrResponse = (NSError?, [FlickrPhoto]?) -> Void
    
    struct Keys {
        static let flickrKey = "dadc4d753d59b07703a62588b0c57c69"
    }
    
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    class func fetchPhotosForSearchText(searchText: String, onCompletion: FlickrResponse) -> Void {
        
        let escapedSearchText: String = searchText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Keys.flickrKey)&tags=\(escapedSearchText)&format=json&nojsoncallback=1"
        let url: NSURL = NSURL(string: urlString)!
        let searchTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photos: \(error)")
                onCompletion(error, nil)
                return
            }
            
            let resultsDictionary:NSDictionary = (try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
            if let statusCode = resultsDictionary["code"] as? Int {
                if statusCode == Errors.invalidAccessErrorCode {
                    let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                    onCompletion(invalidAccessError, nil)
                    return
                }
            }

            let photosContainer = resultsDictionary.objectForKey("photos") as! NSDictionary
            let photosArray = photosContainer.objectForKey("photo") as! NSArray

            let flickrPhotos: [FlickrPhoto] = photosArray.map {
                photoDictionary in
                
                let photoId = photoDictionary["id"] as? String ?? ""
                let farm = photoDictionary["farm"] as? Int ?? 0
                let secret = photoDictionary["secret"] as? String ?? ""
                let server = photoDictionary["server"] as? String ?? ""
                let title = photoDictionary["title"] as? String ?? ""
                
                let flickrPhoto = FlickrPhoto(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                print(flickrPhoto)
                return flickrPhoto
               
            }
            
            onCompletion(nil, flickrPhotos)
        })
        searchTask.resume()
    }
    
    
    class func fetchPhotosRecommended(onCompletion: FlickrResponse) -> Void {
        
        
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=e42b9d3554ff96280461757e49991e7b&format=json&nojsoncallback=1&auth_token=72157671513545516-5b5b05a0cd50afe6&api_sig=c11eab30366d23ca7ec7b59d0e6aeb39"
        let url: NSURL = NSURL(string: urlString)!
        let searchTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photos: \(error)")
                onCompletion(error, nil)
                return
            }
            
            let resultsDictionary:NSDictionary = (try!NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            
            if let statusCode = resultsDictionary["code"] as? Int {
                if statusCode == Errors.invalidAccessErrorCode {
                    let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                    onCompletion(invalidAccessError, nil)
                    return
                }
            }
            
            let photosContainer = resultsDictionary.objectForKey("photos") as! NSDictionary
            let photosArray = photosContainer.objectForKey("photo") as! NSArray
            
            let flickrPhotos: [FlickrPhoto] = photosArray.map {
                photoDictionary in
                
                let photoId = photoDictionary["id"] as? String ?? ""
                let farm = photoDictionary["farm"] as? Int ?? 0
                let secret = photoDictionary["secret"] as? String ?? ""
                let server = photoDictionary["server"] as? String ?? ""
                let title = photoDictionary["title"] as? String ?? ""
                
                let flickrPhoto = FlickrPhoto(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                print(flickrPhoto)
                return flickrPhoto
                
            }
            
            onCompletion(nil, flickrPhotos)
        })
        searchTask.resume()
    }
    
    
}
