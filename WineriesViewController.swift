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
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wineBackground")!)
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "wineBackground"))
        
        let dataManager = DataManager.sharedInstance
        
        //for testing only.....
        dataManager.loadData()
        
        wineries = dataManager.getWineries()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let basicCell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as BasicCell
        setContentForCell(basicCell, indexPath: indexPath)
        return basicCell
    }
    
    func setContentForCell(cell:BasicCell, indexPath:NSIndexPath) {
        let winery = wineries[indexPath.row]
        cell.titleLabel.text = winery.valueForKey("name") as? String
        cell.addressLabel.text = winery.valueForKey("address") as? String
        
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        
        var city = winery.valueForKey("city") as? String
        city = city?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var state = "WA"
        var zip = winery.valueForKey("zipcode") as? String
        
        cell.cityLabel.text = city! + ", " + state + " " + zip!
        cell.cityLabel.sizeToFit()
        
        cell.phoneLabel.text = winery.valueForKey("phone") as? String
        cell.websiteLabel.text = winery.valueForKey("website") as? String
        
        let imageData = winery.valueForKey("imageData") as? NSData
        let myImage = UIImage(data: imageData!)
        cell.cellImage.image = myImage
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.addressLabel.textColor = UIColor.whiteColor()
        cell.cityLabel.textColor = UIColor.whiteColor()
        cell.phoneLabel.textColor = UIColor.whiteColor()
        
        cell.cellImage.contentMode = UIViewContentMode.ScaleAspectFit
        
    }
    
}