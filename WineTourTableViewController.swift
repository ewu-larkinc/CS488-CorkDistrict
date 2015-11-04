//
//  WineTourTableViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/31/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit


class WineTourTableViewController: UITableViewController {
    
    let segueIdentifier = "tourToRoutingSegue"
    
    override func viewDidLoad() {
        tableView.backgroundView = UIImageView(image: UIImage(named: "restBackground"))
        let data = CorkDistrictData.sharedInstance
        data.assignTourClusters()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.clipsToBounds = false
        let data = CorkDistrictData.sharedInstance
        data.resetCurrentTour()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var type: WineTourType
        
        switch (indexPath.row) {
        case 0:
            type = WineTourType.Downtown
        case 1:
            type = WineTourType.MtSpokane
        default:
            type = WineTourType.Sodo
        }
        
        let data = CorkDistrictData.sharedInstance
        data.setCurrentTour(type)
        performSegueWithIdentifier(segueIdentifier, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)    
    }
    
}
