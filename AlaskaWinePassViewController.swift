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


class AlaskaWinePassViewController : UITableViewController {
    @IBOutlet weak var winePassButton: UIButton!
    
    @IBAction func winePassButtonPress(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(winePassURL!)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "greyWood")!)
        winePassButton.layer.shadowColor = UIColor.blackColor().CGColor
        winePassButton.layer.shadowOpacity = 0.8
        winePassButton.layer.shadowRadius = 5
        winePassButton.layer.shadowOffset = CGSizeMake(0,0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
    }
    
}
