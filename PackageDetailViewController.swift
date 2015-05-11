//
//  PackageDetailViewController.swift
//  TheCorkDistrict
//
//

import Foundation
import UIKit
import CoreData


class PackageDetailViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let titleRowHeight : CGFloat = 80.0
    let imageRowHeight : CGFloat = 300.0
    let defaultRowHeight : CGFloat = 60.0
    var currentSelection : NSManagedObject!
    var relatedEntityName : String!
    var relatedEntityAddress : String!
    var relatedEntityPhone : String!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        
        let dataManager = DataManager.sharedInstance
        
        let names = currentSelection.valueForKey("relatedEntityName") as? String
        
        if let nameArray = splitStringByComma(names!) {
            let name1 = nameArray[0]
            println("Name 1 is \(name1)")
            let name2 = nameArray[1]
            println("Name 2 is \(name2)")
            
            relatedEntityName = name1 + ", " + name2
            let entity1 = dataManager.getEntity(name1)
            let entity2 = dataManager.getEntity(name2)
        }
        else {
            println("Name is \(names)")
            relatedEntityName = names
            let entity = dataManager.getEntity(names!)
            relatedEntityAddress = entity.valueForKey("address") as? String
            relatedEntityPhone = entity.valueForKey("phone") as? String
        }
        
        gatherAssociatedEntityInfo(names!)
    }
    
    func gatherAssociatedEntityInfo(entityName: String) {
        
    }
    
    func splitStringByComma(name: String) -> [String]? {
        
        //println("testing... entitiyImageString is \(urlObject)")
        let entityImageStringArray = name.componentsSeparatedByString(",")
        return entityImageStringArray
    }
    
    //# MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell") as! UITableViewCell
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        cell.textLabel?.text = ""
        
        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = currentSelection.valueForKey("name") as? String
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            
            /*let titleLabel = UILabel(frame: CGRectMake(15.0,0.0,350.0,82.0))
            titleLabel.font = UIFont(name: "STHeitiTC-Light", size: 36.0)
            titleLabel.textAlignment = NSTextAlignment.Left
            titleLabel.text = currentSelection.valueForKey("name") as? String
            titleLabel.adjustsFontSizeToFitWidth = true
            cell.addSubview(titleLabel)*/
            break
        case 1:
            cell.textLabel?.text = currentSelection.valueForKey("cost") as? String
            break
        case 2:
            cell.textLabel?.text = currentSelection.valueForKey("relatedEntityTitle") as? String
            break
        case 3:
            cell.textLabel?.text = currentSelection.valueForKey("validDates") as? String
            break
        case 4:
            let imageData = currentSelection.valueForKey("imageData") as? NSData
            let mainImage = UIImage(data: imageData!)
            let newImageView = UIImageView(frame: CGRectMake(15.0,10.0,345.0,280.0))
            newImageView.image = mainImage
            cell.addSubview(newImageView)
            break
        case 5:
            cell.textLabel?.text = currentSelection.valueForKey("phone") as? String
            break
        case 6:
            cell.textLabel?.text = currentSelection.valueForKey("relatedEntityAddress") as? String
            break
        case 7:
            let city = currentSelection.valueForKey("relatedEntityCity") as? String
            let zipcode = currentSelection.valueForKey("relatedEntityZipcode") as? String
            cell.textLabel?.text = city! + " " + zipcode!
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 3) {
            var tempNum = currentSelection.valueForKey("phone") as! NSString
            var tempNumStr = tempNum.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(tempNumStr)")!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.row) {
        case 0:
            return titleRowHeight
        case 4:
            return imageRowHeight
        case 5:
            var tempStr = currentSelection.valueForKey("about") as! String
            var size = getSizeForText(tempStr)
            return size
        default:
            return defaultRowHeight
        }
    }
    
    func getSizeForText(cellText: String) -> CGFloat {
        var length = CGFloat(count(cellText.utf16))
        var rowSize : CGFloat = (length/13.0)*12.0
        return rowSize
    }
    
}