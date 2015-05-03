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
        var startMonth = package.valueForKey("startMonth") as? String
        var endDay = package.valueForKey("endDay") as? String
        var endMonth = package.valueForKey("endMonth") as? String
        var startDate = startMonth! + " " + startDay!
        var endDate = endMonth! + " " + endDay!
        
        cell.titleLabel.text = package.valueForKey("name") as? String
        cell.entityTitleLabel.text = package.valueForKey("relatedEntityName") as? String
        cell.dateLabel.text = startDate + " - " + endDate
        cell.costLabel.text = package.valueForKey("cost") as? String
        cell.cellImage.image = myImage
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.cellImage.contentMode = UIViewContentMode.ScaleAspectFit
    }

    
    
}