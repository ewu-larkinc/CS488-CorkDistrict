//
//  AlaskaWinePassViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 5/12/15.
//  Copyright (c) 2015 Chris Larkin. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

let winePassURL = NSURL(string: "http://www.visitspokane.com/cork-district/winepass")


class AlaskaWinePassViewController : UIViewController {
    @IBOutlet weak var winePassButton: UIButton!
    
    @IBAction func winePassButtonPress(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(winePassURL!)
    }
    
    
    override func viewDidLoad() {
        winePassButton.layer.shadowColor = UIColor.blackColor().CGColor
        winePassButton.layer.shadowOpacity = 0.1
        winePassButton.layer.shadowRadius = 5
        winePassButton.layer.shadowOffset = CGSizeMake(5,5)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
    }
    
}
