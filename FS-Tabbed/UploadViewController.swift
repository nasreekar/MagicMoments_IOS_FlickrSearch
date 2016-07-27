//
//  UploadViewController.swift
//  FS-Tabbed
//
//  Created by Abhijith Sreekar on 10/2/16.
//  Copyright © 2016 Abhijith Sreekar. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class UploadViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.userInteractionEnabled = true
        let reset = UILongPressGestureRecognizer(target: self, action: "reset:")
        reset.minimumPressDuration = 1.0
        reset.delegate = self
        imageView.addGestureRecognizer(reset)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func choose(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
                    
        }
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true,completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        let activityItem  = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = activityItem
        
        self.dismissViewControllerAnimated(true,completion: nil)
        
        
    }
    
    func reset(sender:UILongPressGestureRecognizer)
    {
        imageView.image = nil
    }
    
    @IBAction func share(sender: AnyObject) {
        
        
        if((imageView.image) == nil)
        {
            let ac = UIAlertController(title: "Error!!!", message: "No Image selected", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)

        }
        else{
        let image = imageView.image!
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.excludedActivityTypes = [UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
            UIActivityTypePostToWeibo,
            UIActivityTypeMessage, UIActivityTypeMail,
            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        
        self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func capture(sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    }

