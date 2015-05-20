//
//  PackagesViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import CoreData

class PackagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let packageCellIdentifier = "PackageCell"
    var packages = [NSManagedObject]()
    
    //# MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "packagesBackground"))
        
        let dataManager = DataManager.sharedInstance
        packages = dataManager.getPackages()
        gatherAssociatedEntityInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func gatherAssociatedEntityInfo() {
        let dataManager = DataManager.sharedInstance
        
        
        for package in packages {
            
            if let tempNodeID = package.valueForKey("relatedNodeID") as? String {
                println("nodeIDS before separation is: \(tempNodeID)")
                var nodeIDS = tempNodeID.componentsSeparatedByString(",")
                var finalNodeID: String
                
                if (nodeIDS.count > 1) {
                    var nodeID1 = nodeIDS[0].toInt()
                    var nodeID2 = nodeIDS[1].toInt()
                    
                    var entity1 = dataManager.getEntity(nodeID1!)
                    var entity2 = dataManager.getEntity(nodeID2!)
                    
                    if let testEntity1 = entity1.valueForKey("name") as? String {
                        
                        if let testEntity2 = entity2.valueForKey("name") as? String {
                            
                            var finalTitle = testEntity1 + ", " + testEntity2
                            package.setValue(finalTitle, forKey: "relatedEntityName")
                        }
                    }
                }
                else {
                    
                    var nodeID1 = nodeIDS[0].toInt()
                    var entity1 = dataManager.getEntity(nodeID1!)
                    
                    if let testEntity1 = entity1.valueForKey("name") as? String {
                        
                        var finalTitle = testEntity1
                        package.setValue(finalTitle, forKey: "relatedEntityName")
                    }
                }
            }
            
                
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            appDelegate.saveContext()
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
        }
        
    }
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let urlString = packages[indexPath.row].valueForKey("website") as? String {
            
            var URLString : String
            if urlString.rangeOfString("http://") == nil {
                URLString = "http://" + urlString
            }
            else {
                URLString = urlString
            }
            let entityURL = NSURL(string: URLString)
            UIApplication.sharedApplication().openURL(entityURL!)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> PackageCell {
        
        let packageCell = tableView.dequeueReusableCellWithIdentifier(packageCellIdentifier) as! PackageCell
        setContentForCell(packageCell, indexPath: indexPath)
        return packageCell
    }
    
    func setContentForCell(cell:PackageCell, indexPath:NSIndexPath) {
        
        let maxStringLength = 24;
        let package = packages[indexPath.row]
        let imageData = package.valueForKey("imageData") as? NSData
        let myImage = UIImage(data: imageData!)
        var cost = package.valueForKey("cost") as? String
        var startDay = package.valueForKey("startDay") as? String
        var startMonth = package.valueForKey("StartMonth") as? String
        var startYear = package.valueForKey("startYear") as? String
        var endDay = package.valueForKey("endDay") as? String
        var endMonth = package.valueForKey("endMonth") as? String
        var endYear = package.valueForKey("endYear") as? String
        var startDate = startMonth! + " " + startDay! + ", " + startYear!
        var endDate = endMonth! + " " + endDay! + ", " + endYear!
        var nodeId = package.valueForKey("relatedNodeID") as? String
        var titleText = package.valueForKey("name") as? String
        
        
        /*if let tempTitle = package.valueForKey("name") as? String {
            if count(tempTitle) > maxStringLength {
                let index: String.Index = advance(tempTitle.startIndex, maxStringLength)
                titleText = tempTitle.substringToIndex(index)
                cell.titleLabel.text = titleText
            }
            else {
                cell.titleLabel.text = tempTitle
            }
        }*/
        
        cell.titleLabel.text = titleText
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        
        cell.entityTitleLabel.text = package.valueForKey("relatedEntityName") as? String
        cell.dateLabel.text = startDate + " - " + endDate
        cell.costLabel.text = cost!
        cell.cellImage.image = myImage
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.dateLabel.textColor = UIColor.whiteColor()
        cell.costLabel.textColor = UIColor.whiteColor()
        cell.entityTitleLabel.textColor = UIColor.whiteColor()

        cell.cellImage.contentMode = UIViewContentMode.ScaleToFill
    }

    
    
}