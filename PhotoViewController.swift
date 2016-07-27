//
//  PhotoViewController.swift
//  FS-Tabbed
//
//  Created by Abhijith Sreekar on 8/2/16.
//  Copyright © 2016 Abhijith Sreekar. All rights reserved.
//

import UIKit
import Social
import MessageUI

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate,UITextFieldDelegate, UIScrollViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var comments: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var scrollView2: UIScrollView!
    
    var flickrPhoto: FlickrPhoto?
    
    var list : NSMutableArray! = []
    
    var favoritesDB:COpaquePointer = nil;
    
    var insertStatement : COpaquePointer = nil
    
    
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1,sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        comments.delegate = self
        registerForKeyboardNotifications()
        
        
        
        if flickrPhoto != nil {
            let data = NSData(contentsOfURL: flickrPhoto!.photoUrl)
            photoImageView.image = UIImage(data: data!)
        }
        label.text = flickrPhoto?.title
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        print(paths)
        
        let docsDir = paths + "/fsfavorites.sqlite"
        
        if (sqlite3_open(docsDir, &favoritesDB) == SQLITE_OK)
        {
            let sql = "CREATE TABLE IF NOT EXISTS FSFAVORITES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT,COMMENTS TEXT, IMAGEURL TEXT)"
            
            //let sql = "DROP TABLE FSFAVORITES"
            //let sql = "DROP TABLE FAVORITES"
            
            if(sqlite3_exec(favoritesDB, sql, nil, nil, nil) != SQLITE_OK){
                print("failed to create table")
                print(sqlite3_errmsg(favoritesDB));
            }
        }
        else
        {
            print("failed to open database")
            print(sqlite3_errmsg(favoritesDB))
        }
        
        prepareStatement();

    }
    
    func prepareStatement(){
        
        var sqlString : String
        
        sqlString = "INSERT INTO FSFAVORITES (title, comments, imageURL) VALUES (?, ? ,? )"
        let cSql = sqlString.cStringUsingEncoding(NSUTF8StringEncoding)
        sqlite3_prepare_v2(favoritesDB, cSql!, -1, &insertStatement,nil)
    
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
//
//    @IBAction func fbSender(sender: AnyObject) {
//        
//        if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
//            
//            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
//            
//            //controller.setInitialText("Test Post from FS-Tabbed Demo");
//            //controller.addURL(NSURL(string: "http://www.iss.nus.edu.sg"));
//            let data = NSData(contentsOfURL: flickrPhoto!.photoUrl)
//            controller.addImage(UIImage(data: data!));
//            self.presentViewController(controller, animated:true, completion:nil)
//            
//            
//            
//        } else {
//            // 3
//            print("no Facebook account found on device")
//        }
//
//    }
//    
//    @IBAction func twitterSender(sender: AnyObject) {
//        if(SLComposeViewController.isAvailableForServiceType(  SLServiceTypeTwitter)) {
//            let controller = SLComposeViewController(         forServiceType: SLServiceTypeTwitter)
//            
//            if (SLComposeViewController.isAvailableForServiceType(      SLServiceTypeTwitter)) {
//                
//                controller.setInitialText(        "This is a tweet from iOS CA: FS-Tabbed");
//                let data = NSData(contentsOfURL: flickrPhoto!.photoUrl)
//                controller.addImage(UIImage(data: data!));
//    
//                self.presentViewController(controller,          animated:true, completion:nil);
//            }
//        } else {
//            print("no twitter account found on device")
//        }
//    }
    
    
    @IBAction func save(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(photoImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
//    @IBAction func mailSender(sender: AnyObject) {
//        let emailTitle = "Flickr Image Share"
//        let messageBody = flickrPhoto?.title
//        let mc: MFMailComposeViewController = MFMailComposeViewController()
//        mc.mailComposeDelegate = self
//        mc.setSubject(emailTitle)
//        mc.setMessageBody("This is from IOS CA- FS TABBED" + "\n" + messageBody!, isHTML: false)
//        let data = NSData(contentsOfURL: flickrPhoto!.photoUrl)
//        mc.addAttachmentData(data!, mimeType: "image/png", fileName: "images.png")
//        self.presentViewController(mc, animated: true, completion: nil)
//    }
//    
//    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    @IBAction func favoriteSender(sender: AnyObject) {
        
        comments.resignFirstResponder()
        let title1 = (flickrPhoto?.title)! as NSString
        let comments1 = comments.text  as NSString?
        let imageURL1:NSURL = (flickrPhoto?.photoUrl)!
        let link : NSString = imageURL1.absoluteString
        
        sqlite3_bind_text(insertStatement, 1, title1.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 2, comments1!.UTF8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 3, link.UTF8String, -1, SQLITE_TRANSIENT)
        
        if(sqlite3_step(insertStatement) == SQLITE_DONE)
        {
            let alertPopUp : UIAlertController = UIAlertController(title: "Successful", message: "Favorites added successfully", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel){ action -> Void in }
            alertPopUp.addAction(cancelAction)
            self.presentViewController(alertPopUp, animated: true, completion: nil)
            print("favorites added succesfully")
            list.addObject(title1)
            
        }
        else
        {
            
            print("favorites addition failed")
            print("Error code: " , sqlite3_errcode(favoritesDB));
            let error = String.fromCString(sqlite3_errmsg(favoritesDB));
            print("Error msg: ", error)
        }
        sqlite3_reset(insertStatement)
        sqlite3_clear_bindings(insertStatement)
    }

    
    
    @IBAction func share(sender: AnyObject) {
        print("entered share")
        
        var actionSheetController = UIAlertController()
        actionSheetController = UIAlertController(title: "Share with", message: "", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add first option action
        let Facebook: UIAlertAction = UIAlertAction(title: "Facebook", style: .Default) { action -> Void in
            if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
                
                let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                //controller.setInitialText("Test Post from FS-Tabbed Demo");
                //controller.addURL(NSURL(string: "http://www.iss.nus.edu.sg"));
                let data = NSData(contentsOfURL: self.flickrPhoto!.photoUrl)
                controller.addImage(UIImage(data: data!));
                
                
                self.presentViewController(controller, animated:true, completion:nil);
                
            } else {
                // 3
                print("no Facebook account found on device")
            }
        }; actionSheetController.addAction(Facebook)
        
        let Twitter: UIAlertAction = UIAlertAction(title: "Twitter", style: .Default) { action -> Void in
            
            if(SLComposeViewController.isAvailableForServiceType(  SLServiceTypeTwitter)) {
                let controller = SLComposeViewController(         forServiceType: SLServiceTypeTwitter)
                
                if (SLComposeViewController.isAvailableForServiceType(      SLServiceTypeTwitter)) {
                    
                    controller.setInitialText(        "This is a tweet from iOS CA: FS-Tabbed");
                    let data = NSData(contentsOfURL: self.flickrPhoto!.photoUrl)
                    controller.addImage(UIImage(data: data!));
                    
                    self.presentViewController(controller,          animated:true, completion:nil);
                }
            } else {
                print("no twitter account found on device")
            }
        }; actionSheetController.addAction(Twitter)
        
        let Email: UIAlertAction = UIAlertAction(title: "Email", style: .Default) { action -> Void in
            
            let emailTitle = "Flickr Image Share"
            let messageBody = self.flickrPhoto?.title
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody("This is from IOS CA- FS TABBED" + "\n" + messageBody!, isHTML: false)
            let data = NSData(contentsOfURL: self.flickrPhoto!.photoUrl)
            mc.addAttachmentData(data!, mimeType: "image/png", fileName: "images.png")
            self.presentViewController(mc, animated: true, completion: nil)
        }
        actionSheetController.addAction(Email)
        
        func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(actionSheetController,animated:true, completion:nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        comments.resignFirstResponder()
        return true
    }
    
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView2.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView2.contentInset = contentInsets
        self.scrollView2.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = comments
        {
            if (!CGRectContainsPoint(aRect, activeFieldPresent.frame.origin))
            {
                self.scrollView2.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView2.contentInset = contentInsets
        self.scrollView2.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView2.scrollEnabled = false
        
    }
    }
