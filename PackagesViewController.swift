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
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "packagesBackground"))
        
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
        
        let tempWineries: [NSManagedObject] = dataManager.getWineries()
        
        for package in packages {
            
            
            if let tempNodeID = package.valueForKey("relatedNodeID") as? String {
                
                var nodeIDS = tempNodeID.componentsSeparatedByString(",")
                var finalNodeID: String
                
                if (nodeIDS.count > 1) {
                    println("Current Package has 2 ASSOCIATED ENTITIES")
                    var nodeID1 = nodeIDS[0].toInt()
                    println("First nodeID: \(nodeID1)")
                    var nodeID2 = nodeIDS[1].toInt()
                    println("Second nodeID: \(nodeID2)")
                    
                    var entity1 = dataManager.getEntity(nodeID1!)
                    
                    var entity2 = dataManager.getEntity(nodeID2!)
                    println("index1: \(nodeID1)")
                    println("index2: \(nodeID2)")
                    
                    if let testEntity1 = entity1.valueForKey("name") as? String {
                        if testEntity1 != "blank" {
                            println("associated winery1 is: ")
                            println(testEntity1)
                        }
                        
                        if let testEntity2 = entity2.valueForKey("name") as? String {
                            if testEntity2 != "blank" {
                                println("associated winery2 is: ")
                                println(testEntity2)
                            }
                            
                            var finalTitle = testEntity1 + ", " + testEntity2
                            package.setValue(finalTitle, forKey: "relatedEntityName")
                      
                    
                    /*if (index1 > 0) {
                        println("associated winery1 is: ")
                        if let title = winery1.valueForKey("name") as? String {
                            println(title)
                            
                            
                            if let title2 = winery2.valueForKey("name") as? String {
                                println("associated winery2 is: ")
                                println(title2)
                                var finalTitle = title + ", " + title2
                                package.setValue(title, forKey: "relatedEntityName")
                            }
                        }
                        
                    }*/
                        }  }
                } else {
                    println("Current package has 1 ASSOCIATED ENTITY")
                    var nodeID1 = nodeIDS[0].toInt()
                    println("First nodeID: \(nodeID1)")
                    var entity1 = dataManager.getEntity(nodeID1!)
                    println("index1: \(nodeID1)")
                    
                    if let testEntity1 = entity1.valueForKey("name") as? String {
                        if testEntity1 != "blank" {
                            println("associated winery1 is: ")
                            println(testEntity1)
                        }
                        
                        var finalTitle = testEntity1
                        package.setValue(finalTitle, forKey: "relatedEntityName")
                    }
                }
                
                
                
                /*var nodeID = tempNodeID.toInt()!
                println("searching for nodeID: \(nodeID)")
                var index = dataManager.getEntityIndex(nodeID)
                let theWinery = tempWineries[index]
                
                if (index >= 0) {
                    println("associated winery is: ")
                    if let title = tempWineries[index].valueForKey("name") as? String {
                        println(title)
                        package.setValue(title, forKey: "relatedEntityName")
                    }
                    
                }*/
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

    func stripHtml(urlObject: String) -> String {

        //println("testing... entitiyImageString is \(urlObject)")
        let entityImageStringArray = urlObject.componentsSeparatedByString("Optional(")
        var entityImageString = entityImageStringArray[1].stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return entityImageString
        //return entityImageString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> PackageCell {
        
        let packageCell = tableView.dequeueReusableCellWithIdentifier(packageCellIdentifier) as! PackageCell
        setContentForCell(packageCell, indexPath: indexPath)
        return packageCell
    }
    
    func setContentForCell(cell:PackageCell, indexPath:NSIndexPath) {
        
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
        println("Testing in packages - Node_ID: \(nodeId)")
        
        cell.titleLabel.text = package.valueForKey("name") as? String
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        //cell.titleLabel.sizeToFit()
        
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.entityTitleLabel.text = package.valueForKey("relatedEntityName") as? String
        cell.dateLabel.text = startDate + " - " + endDate
        cell.costLabel.text = "$" + cost!
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