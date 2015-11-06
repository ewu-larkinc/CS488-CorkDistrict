//
//  CorkDistrictEntityViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/16/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CorkDistrictEntityViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBAction func refreshTableView(sender: AnyObject) {
        
        let data = CorkDistrictData.sharedInstance
        
        if let type = data.getSelectedEntityType() {
            currentEntityType = type
            setDataForEntities()
        }
        
        tableView.reloadData()
    }
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var entities = [CorkDistrictEntity]()
    var packages = [CorkDistrictPackage]()
    var currentEntityType: LocationType?
    var titleText = String()
    let notificationKey = "reloadNotification"
    let reloadSelector = Selector("updateTableView:")
    
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: reloadSelector, name: notificationKey, object: nil)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.clipsToBounds = false
        
        let data = CorkDistrictData.sharedInstance
        
        if let type = data.getSelectedEntityType() {
            currentEntityType = type
            print("TESTING - current entity type being set to \(type) in CDEVC")
            titleText = data.getTextForEntityType(type)
            
            setDataForEntities()
            
            print("entities count is \(entities.count)")
            print("packages count is \(packages.count)")
            self.title = titleText
        }
        
        setBackgroundImage()
    }
    
    
    
    func getLocationTypeForString(type: String) -> LocationType {
        
        var locationType: LocationType
        
        switch (type) {
            
            case "Winery":
                locationType = LocationType.Winery
            case "Restaurant":
                locationType = LocationType.Restaurant
            case "Accommodation":
                locationType = LocationType.Accommodation
            default:
                locationType = LocationType.Parking
        }
        
        return locationType
    }
    
    func setDataForEntities() {
        let data = CorkDistrictData.sharedInstance
        
        if currentEntityType == LocationType.Winery {
            entities = data.getWineries()
        } else if currentEntityType == LocationType.Restaurant {
            entities = data.getRestaurants()
        } else if currentEntityType == LocationType.Accommodation {
            entities = data.getAccommodations()
        } else {
            packages = data.getPackages()
        }
    }
    
    func updateTableView(notification: NSNotification) {
        
        
    }
    
    
    
    func resetCurrentEntityType() {
        currentEntityType = nil
    }
    
    func setBackgroundImage() {
        var image: UIImage
        
        print("Current entity type in setBackgroundImage is \(currentEntityType)")
        
        switch (currentEntityType!) {
            case LocationType.Winery:
                image = UIImage(named: "wineBackground")!
            case LocationType.Restaurant:
                image = UIImage(named: "restBackground")!
            case LocationType.Accommodation:
                image = UIImage(named: "hotelBackground")!
            default:
                image = UIImage(named: "packagesBackground")!
        }
        
        //tableView.backgroundView = UIImageView(image: image)
        backgroundImage.image = image
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CorkDistrictEntityCell") as! CorkDistrictEntityCell
        
        if currentEntityType == LocationType.Package {
            let data = CorkDistrictData.sharedInstance
            let currentItem = packages[indexPath.row]
            
            cell.imgView.image = currentItem.image
            cell.imgView.layer.cornerRadius = 4.0
            cell.imgView.clipsToBounds = true
            cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            
            cell.titleLabel.text = currentItem.title
            let startDate = currentItem.startMonth + " " + currentItem.startDay + ", " + currentItem.startYear
            let endDate = currentItem.endMonth + " " + currentItem.endDay + ", " + currentItem.endYear
            
            print("Current related node ID is \(currentItem.relatedNodeID)")
            let relatedEntityTitle = data.getEntityByNodeID(currentItem.relatedNodeID)?.title
            
            cell.addressLabel.text = relatedEntityTitle
            cell.addressLine2Label.text = startDate + " - " + endDate
            cell.altLabel1.text = currentItem.cost
            
            cell.altLabel2.text = ""
            
            return cell
        } else {
        
            let currentItem = entities[indexPath.row]
        
            cell.imgView.image = currentItem.image
            cell.imgView.layer.cornerRadius = 4.0
            cell.imgView.clipsToBounds = true
            cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        
            cell.titleLabel.text = currentItem.title
            cell.addressLabel.text = currentItem.address
            cell.addressLine2Label.text = currentItem.phone
            
            if currentEntityType == LocationType.Winery {
                cell.altLabel1.text = currentItem.hours
                cell.altLabel2.text = currentItem.cardAccepted
                cell.altLabel2.textColor = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
                
            } else {
                cell.addressLine2Label.text = currentItem.city + ", WA " + currentItem.zip
                cell.altLabel1.text = currentItem.phone
                cell.altLabel2.text = currentItem.webAddress
            }
        
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if entities.count != 0 {
            return entities.count
        } else {
            return packages.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let data = CorkDistrictData.sharedInstance
        
        if currentEntityType == LocationType.Package {
            let url = "http://" + packages[indexPath.row].webAddress
            print("TESTING - Current Package Url = \(url)")
            data.setCurrentURL(url)
            performSegueWithIdentifier("embeddedWebSegue", sender: self)
        } else {
            if let type = currentEntityType {
                data.setSelectedEntityType(type)
                data.setSelectedEntity(entities[indexPath.row])
                performSegueWithIdentifier("detailSegue", sender: self)
            }
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "DetailSegue" {
            let dvc = segue.destinationViewController as! DetailTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                dvc.currentEntity = entities[indexPath.row]
            }
        }
        
    }*/
}