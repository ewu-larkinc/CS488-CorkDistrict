//
//  WineriesViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import CoreData

class WineriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var wineries = [NSManagedObject]()
    let basicCellIdentifier = "BasicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "wineBackground"))
        
        let dataManager = DataManager.sharedInstance
        wineries = dataManager.getWineries()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let dvc = segue.destinationViewController as DetailViewController
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let winery = wineries[indexPath.row]
            dvc.currentSelection = winery
        }
        
    }
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wineries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let basicCell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as BasicCell
        setContentForCell(basicCell, indexPath: indexPath)
        return basicCell
    }
    
    func setContentForCell(cell:BasicCell, indexPath:NSIndexPath) {
        
        let winery = wineries[indexPath.row]
        let imageData = winery.valueForKey("imageData") as? NSData
        let cellImage = UIImage(data: imageData!)
        
        var name = winery.valueForKey("name") as? String
        var address = winery.valueForKey("address") as? String
        var city = winery.valueForKey("city") as? String
        var website = winery.valueForKey("website") as? String
        var phone = winery.valueForKey("phone") as? String
        var zip = winery.valueForKey("zipcode") as? String
        var state = "WA"
        
        city = city?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        //for testing only.........................................
        //let testResults = [NSManagedObject]()
        /*let dataManager = DataManager.sharedInstance
        if let testResults = dataManager.getWineryByTitle(name!) {
            var testWeb = testResults[0].valueForKey("website") as? String
            println("title: \(name), website found: \(testWeb)")
        }*/
        
        
        cell.titleLabel.text = name
        cell.addressLabel.text = address
        cell.cityLabel.text = city! + ", " + state + " " + zip!
        cell.cityLabel.sizeToFit()
        cell.phoneLabel.text = phone
        cell.websiteLabel.text = website
        cell.cellImage.image = cellImage
        
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.addressLabel.textColor = UIColor.whiteColor()
        cell.cityLabel.textColor = UIColor.whiteColor()
        cell.phoneLabel.textColor = UIColor.whiteColor()
        cell.websiteLabel.textColor = UIColor.whiteColor()
        
        cell.cellImage.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
}