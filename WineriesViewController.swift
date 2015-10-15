//
//  WineriesViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import CoreData
import MapKit

class WineriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var wineries = [NSManagedObject]()
    let entityCellIdentifier = "EntityCell"
    
    //# MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "wineBackground"))
        let dataManager = DataManager.sharedInstance
        wineries = dataManager.getWineries()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //#MARK: - Segue Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let dvc = segue.destinationViewController as! DetailViewController
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let winery = wineries[indexPath.row]
            dvc.currentSelection = winery
        }
        
    }
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wineries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return entityCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func entityCellAtIndexPath(indexPath:NSIndexPath) -> EntityCell {
        let entityCell = tableView.dequeueReusableCellWithIdentifier(entityCellIdentifier) as! EntityCell
        setContentForCell(entityCell, indexPath: indexPath)
        return entityCell
    }
    
    func setContentForCell(cell:EntityCell, indexPath:NSIndexPath) {
        
        let winery = wineries[indexPath.row]
        
        var city = winery.valueForKey("city") as? String
        city = city?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        cell.titleLabel.text = winery.valueForKey("name") as? String
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.addressLabel.text = winery.valueForKey("address") as? String
        
        let zip = winery.valueForKey("zipcode") as? String
        let state = "WA"
        cell.cityLabel.text = city! + ", " + state + " " + zip!
        cell.cityLabel.sizeToFit()
        cell.phoneLabel.text = winery.valueForKey("cardAccepted") as? String
        cell.websiteLabel.text = winery.valueForKey("hours") as? String
        
        let imageData = winery.valueForKey("imageData") as? NSData
        cell.cellImage.image = UIImage(data: imageData!)
        
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.addressLabel.textColor = UIColor.whiteColor()
        cell.cityLabel.textColor = UIColor.whiteColor()
        cell.phoneLabel.textColor = UIColor.whiteColor()
        cell.websiteLabel.textColor = UIColor.whiteColor()
        
        cell.cellImage.contentMode = UIViewContentMode.ScaleToFill
    }
    
}