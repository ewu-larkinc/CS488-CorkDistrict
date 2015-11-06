//
//  DetailTableViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/18/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum CorkDistrictKey: String {
    case Phone = "phone"
    case Title = "title"
    case Address = "address"
    case Zipcode = "zipcode"
    case Description = "about"
    case Image = "imageData"
    case City = "city"
}

class DetailTableViewController: UITableViewController {
    
    static let TABLE_VIEW_SIZE = 6
    var currentEntity: CorkDistrictEntity?
    let basicCellId = "BasicDetailCell"
    let imageCellId = "ImageDetailCell"
    
    
    override func viewDidLoad() {
        if let curEnt = currentEntity {
            navigationController?.navigationItem.leftBarButtonItem?.title = curEnt.typePlural
            
        }
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "detailBackground"))
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.clipsToBounds = false
        
        let data = CorkDistrictData.sharedInstance
        if let entity = data.getSelectedEntity() {
            currentEntity = entity
        }
        self.title = "Details"
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat
        
        switch (indexPath.row) {
            
        case 1:
            height = 80.0
        case 3:
            height = 280.0
        case 4:
            height = getSizeForText((currentEntity?.description)!)
        default:
            height = 60.0
            
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 1 {
            performSegueWithIdentifier("showRouteSegue", sender: self)
        } else if indexPath.row == 2 {
            if let entity = currentEntity {
                let url:NSURL = NSURL(string: entity.phone)!
                UIApplication.sharedApplication().openURL(url)
            }
            
        } else if indexPath.row == 5 {
            print("VISIT WEBSITE SELECTED")
            let data = CorkDistrictData.sharedInstance
            
            if let item = currentEntity {
                
                if let url = item.webAddress {
                    let urlString = "http://" + url
                    data.setCurrentURL(urlString)
                }
            }
            performSegueWithIdentifier("detailToEmbeddedSegue", sender: self)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(basicCellId) as UITableViewCell!
        
        cell.prepareForReuse()
        
            switch (indexPath.row) {
                case 0:
                    //let cell = tableView.dequeueReusableCellWithIdentifier(basicCellId) as UITableViewCell!
                    cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                    cell.textLabel!.text = currentEntity?.title
                return cell
                case 1:
                    //let cell = tableView.dequeueReusableCellWithIdentifier(basicCellId) as UITableViewCell!
                    let address = currentEntity!.address
                    let cityState = currentEntity!.city
                    let zip = currentEntity!.zip
                    let cityStateZip = cityState + ", WA " + zip
                    cell.textLabel!.text = address + "\n" + cityStateZip
                    cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                return cell
                case 2:
                    //let cell = tableView.dequeueReusableCellWithIdentifier(basicCellId) as UITableViewCell!
                    cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                    cell.textLabel!.text = currentEntity!.phone
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                return cell
                case 3:
                    let cell2 = prepareImageDetailCell(tableView, entity: currentEntity!) as ImageDetailCell
                    cell2.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                    cell2.imgView.image = currentEntity?.image
                    cell2.imgView.layer.borderColor = UIColor.whiteColor().CGColor
                    cell2.imgView.layer.borderWidth = 0.5
                    return cell2
                case 4:
                    //let cell = tableView.dequeueReusableCellWithIdentifier(basicCellId) as UITableViewCell!
                    cell.textLabel!.text = currentEntity!.description
                    cell.textLabel?.sizeToFit()
                    cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                    return cell
                default:
                    //let cell = tableView.dequeueReusableCellWithIdentifier(basicCellId) as UITableViewCell!
                    cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell.textLabel?.text = "Visit Website"
                    return cell
            }
        
    }
    
    func prepareImageDetailCell(tableView: UITableView, entity: CorkDistrictEntity) -> ImageDetailCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(imageCellId) as! ImageDetailCell
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.imgView.image = currentEntity?.image
        cell.imgView.layer.borderColor = UIColor.whiteColor().CGColor
        cell.imgView.layer.borderWidth = 0.5
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DetailTableViewController.TABLE_VIEW_SIZE
    }
    
    func getSizeForText(cellText: String) -> CGFloat {
        let length = CGFloat(cellText.characters.count)
        let rowSize : CGFloat = (length/13.0)*12.0
        return rowSize + 13
    }
    
    func removeOddCharacters(string: String) -> String {
        
        let term1 = "&quot;"
        let term2 = "&#039;"
        let term3 = "&amp;"
        let term4 = "/"
        
        var tempString = string.stringByReplacingOccurrencesOfString(term1, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        tempString = tempString.stringByReplacingOccurrencesOfString(term2, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        tempString = tempString.stringByReplacingOccurrencesOfString(term4, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return tempString.stringByReplacingOccurrencesOfString(term3, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}