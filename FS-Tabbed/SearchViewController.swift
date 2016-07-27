//
//  ViewController.swift
//  FlickrSearch
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var photos: [FlickrPhoto] = []
    
    // MARK: - Actions
    
    @IBAction func resetSearch(sender: AnyObject) {
        photos.removeAll(keepCapacity: false);
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewDidLoad()
        //tableView.reloadData()
        self.title = "Flickr Search"
    }
    
    override func viewDidLoad() {
        FlickrProvider.fetchPhotosRecommended({ (error: NSError?, flickrPhotos: [FlickrPhoto]?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error == nil {
                self.photos = flickrPhotos!
            } else {
                self.photos = []
                if (error!.code == FlickrProvider.Errors.invalidAccessErrorCode) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showErrorAlert()
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //self.title = searchText
                self.tableView.reloadData()
            })
    }) 
    }

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 90.0
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let searchResultCellIdentifier = "SearchResultCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(searchResultCellIdentifier, forIndexPath: indexPath) as? SearchResultCell
        cell!.setupWithPhoto(photos[indexPath.row])
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("PhotoSegue", sender: self)
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("abc")
        print(searchBar.text!)
        searchBar.resignFirstResponder()
        performSearchWithText(searchBar.text!)
    }
    
    // MARK - Segue 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoSegue" {
            let photoViewController = segue.destinationViewController as! PhotoViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            photoViewController.flickrPhoto = photos[selectedIndexPath!.row]
        }
    }

    // MARK: - Private
    
    private func performSearchWithText(searchText: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        FlickrProvider.fetchPhotosForSearchText(searchText, onCompletion: { (error: NSError?, flickrPhotos: [FlickrPhoto]?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error == nil {
                self.photos = flickrPhotos!
            } else {
                self.photos = []
                if (error!.code == FlickrProvider.Errors.invalidAccessErrorCode) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.showErrorAlert()
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.title = searchText
                self.tableView.reloadData()
            })
        })
    }
//}
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Search Error", message: "Invalid API Key", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default) { (action) in
            
        }
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true) {
            
        }
    }
    
}
