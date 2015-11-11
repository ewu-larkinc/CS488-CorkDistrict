//
//  MainMenuViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/16/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

enum MenuOptions : String {
    case Tour = "Wine Tours"
    case Map = "MapView"
    case Wineries = "Wineries"
    case Restaurants = "Restaurants"
    case Accommodations = "Accommodations"
    case Alaska = "Alaska Wine Pass"
    case Packages = "Packages"
}

class MainMenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func longPressDetected(sender: AnyObject) {
        
        let alertView = UIAlertController(title: "Credits", message: "This masterpiece was hand-crafted by an EWU Senior Project team in 2015 (Team members: Chris Larkin, Kyle Bondo, Justin Cargile, Nate Pilgrim, and Zac Bowman).", preferredStyle: .Alert)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    let cellIdentifier = "MenuCell"
    let ListSegueIdentifier = "ListEntitiesSegue"
    let MapSegueIdentifier = "MapViewSegue"
    let TourSegueIdentifier = "wineTourSegue"
    let notificationKey = "updateLoadingScreen"
    
    let listSize = 7
    var selectedRow: Int?
    var selectedEntityType: String?
    
    override func viewDidLoad() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Gurmukhi MN", size: 18.0)!], forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        let data = CorkDistrictData.sharedInstance
        data.resetSelectedEntityType()
        data.resetCurrentURL()
        data.resetCurrentTour()
    }
    
    func getSelectedRow() -> Int? {
        return selectedRow
    }
    
    func resetSelectedRow() {
        selectedRow = nil
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        switch (indexPath.row) {
            
        case 0:
            cell.textLabel!.text = MenuOptions.Tour.rawValue
        case 1:
            cell.textLabel!.text = MenuOptions.Map.rawValue
        case 2:
            cell.textLabel!.text = MenuOptions.Wineries.rawValue
        case 3:
            cell.textLabel!.text = MenuOptions.Restaurants.rawValue
        case 4:
            cell.textLabel!.text = MenuOptions.Accommodations.rawValue
        case 5:
            cell.textLabel!.text = MenuOptions.Alaska.rawValue
        case 6:
            cell.textLabel!.text = MenuOptions.Packages.rawValue
            let longPressDetector = UILongPressGestureRecognizer(target: cell, action: "longPressDetected")
            
            longPressDetector.minimumPressDuration = 5.0
            longPressDetector.delaysTouchesBegan = true
            longPressDetector.delegate = cell
            cell.addGestureRecognizer(longPressDetector)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSize
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = CorkDistrictData.sharedInstance
        
        switch (indexPath.row) {
            
        case 0:
            performSegueWithIdentifier(TourSegueIdentifier, sender: self)
        case 1:
            performSegueWithIdentifier(MapSegueIdentifier, sender: self)
        case 2:
            data.setSelectedEntityType(LocationType.Winery)
            performSegueWithIdentifier(ListSegueIdentifier, sender: self)
        case 3:
            data.setSelectedEntityType(LocationType.Restaurant)
            performSegueWithIdentifier(ListSegueIdentifier, sender: self)
        case 4:
            data.setSelectedEntityType(LocationType.Accommodation)
            performSegueWithIdentifier(ListSegueIdentifier, sender: self)
        case 5:
            //alaska
            data.setCurrentURL("http://www.visitspokane.com/cork-district/winepass/")
            performSegueWithIdentifier("AlaskaWinePassSegue", sender: self)
            break
        case 6:
            data.setSelectedEntityType(LocationType.Package)
            performSegueWithIdentifier(ListSegueIdentifier, sender: self)
            break
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}