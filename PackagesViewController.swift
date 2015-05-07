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
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "restBackground")!)
        
        let dataManager = DataManager.sharedInstance
        packages = dataManager.getPackages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
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
        var startDay = package.valueForKey("startDay") as? String
        var startMonth = package.valueForKey("StartMonth") as? String
        var startYear = package.valueForKey("startYear") as? String
        var endDay = package.valueForKey("endDay") as? String
        var endMonth = package.valueForKey("endMonth") as? String
        var endYear = package.valueForKey("endYear") as? String
        var startDate = startMonth! + " " + startDay! + " " + startYear!
        var endDate = endMonth! + " " + endDay! + " " + endYear!
        var nodeId = package.valueForKey("relatedNodeID") as? String
        println("Testing in packages - Node_ID: \(nodeId)")
        
        cell.titleLabel.text = package.valueForKey("name") as? String
        cell.entityTitleLabel.text = package.valueForKey("relatedEntityName") as? String
        cell.dateLabel.text = startDate + " - " + endDate
        cell.costLabel.text = package.valueForKey("cost") as? String
        cell.cellImage.image = myImage
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.cellImage.contentMode = UIViewContentMode.ScaleToFill
    }

    
    
}