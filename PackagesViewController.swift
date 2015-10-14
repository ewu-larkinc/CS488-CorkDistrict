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
    
                var nodeIDS = tempNodeID.componentsSeparatedByString(",")
                //var finalNodeID: String
                
                if (nodeIDS.count > 1) {
                    let nodeID1 = Int(nodeIDS[0])
                    let nodeID2 = Int(nodeIDS[1])
                    
                    let entity1 = dataManager.getEntityByNodeId(nodeID1!)
                    let entity2 = dataManager.getEntityByNodeId(nodeID2!)
                    
                    if let testEntity1 = entity1.valueForKey("name") as? String {
                        
                        if let testEntity2 = entity2.valueForKey("name") as? String {
                            
                            let finalTitle = testEntity1 + ", " + testEntity2
                            package.setValue(finalTitle, forKey: "relatedEntityName")
                        }
                    }
                }
                else {
                    
                    let nodeID1 = Int(nodeIDS[0])
                    let entity1 = dataManager.getEntityByNodeId(nodeID1!)
                    
                    if let testEntity1 = entity1.valueForKey("name") as? String {
                        
                        let finalTitle = testEntity1
                        package.setValue(finalTitle, forKey: "relatedEntityName")
                    }
                }
            }
            
                
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            appDelegate.saveContext()
            
            do {
                try managedContext.save()
            } catch {
                print("Could not save \(error)")
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
        
        //let maxStringLength = 24;
        let package = packages[indexPath.row]
        let imageData = package.valueForKey("imageData") as? NSData
        let myImage = UIImage(data: imageData!)
        let cost = package.valueForKey("cost") as? String
        let startDay = package.valueForKey("startDay") as? String
        let startMonth = package.valueForKey("StartMonth") as? String
        let startYear = package.valueForKey("startYear") as? String
        let endDay = package.valueForKey("endDay") as? String
        let endMonth = package.valueForKey("endMonth") as? String
        let endYear = package.valueForKey("endYear") as? String
        let startDate = startMonth! + " " + startDay! + ", " + startYear!
        let endDate = endMonth! + " " + endDay! + ", " + endYear!
        //var nodeId = package.valueForKey("relatedNodeID") as? String
        let titleText = package.valueForKey("name") as? String
        
        
        cell.titleLabel.text = titleText
        cell.entityTitleLabel.text = package.valueForKey("relatedEntityName") as? String
        cell.dateLabel.text = startDate + " - " + endDate
        cell.costLabel.text = cost!
        cell.cellImage.image = myImage
        
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.entityTitleLabel.adjustsFontSizeToFitWidth = true
        cell.dateLabel.adjustsFontSizeToFitWidth = true
        cell.costLabel.adjustsFontSizeToFitWidth = true
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.dateLabel.textColor = UIColor.whiteColor()
        cell.costLabel.textColor = UIColor.whiteColor()
        cell.entityTitleLabel.textColor = UIColor.whiteColor()

        cell.cellImage.contentMode = UIViewContentMode.ScaleToFill
    }

    
    
}