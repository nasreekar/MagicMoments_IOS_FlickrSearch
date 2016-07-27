//
//  custom.swift
//  Magic Moments
//
//  Created by Abhijith Sreekar on 11/2/16.
//  Copyright © 2016 Abhijith Sreekar. All rights reserved.
//

import Foundation
import UIKit


class custom : UITabBarController{
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait,UIInterfaceOrientationMask.PortraitUpsideDown]
    }
}
