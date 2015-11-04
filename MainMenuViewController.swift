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
    
    let cellIdentifier = "MenuCell"
    let ListSegueIdentifier = "ListEntitiesSegue"
    let MapSegueIdentifier = "MapViewSegue"
    let TourSegueIdentifier = "wineTourSegue"
    let notificationKey = "updateLoadingScreen"
    let activitySelector = Selector("stopLoadingAnimation:")
    
    let listSize = 7
    var selectedRow: Int?
    var selectedEntityType: String?
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: activitySelector, name: notificationKey, object: nil)
        
        //let data = CorkDistrictData.sharedInstance
        /*if data.hasDownloadFinished() {
            loadingView.hidden = true
        }*/
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        let data = CorkDistrictData.sharedInstance
        data.resetSelectedEntityType()
        data.resetCurrentURL()
        data.resetCurrentTour()
    }
    
    func stopLoadingAnimation(notification: NSNotification) {
        //loadingView.hidden = true
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