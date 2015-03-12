//
//  RestaurantsViewController.swift
//  CorkDistrict
//


import Foundation
import UIKit
import CoreData

class RestaurantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var restaurants = [NSManagedObject]()
    
    @IBAction func returnToHomePage(AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataManager = DataManager.sharedInstance
        restaurants = dataManager.getWineries()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let basicCellIdentifier = "BasicCell"
        let basicCell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as BasicCell
        setContentForCell(basicCell, indexPath: indexPath)
        return basicCell
    }
    
    func setContentForCell(cell:BasicCell, indexPath:NSIndexPath) {
        let restaurant = restaurants[indexPath.row]
        cell.titleLabel.text = restaurant.valueForKey("name") as? String
        cell.addressLabel.text = restaurant.valueForKey("address") as? String
        
        var city = restaurant.valueForKey("city") as? String
        city = city?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var state = "WA"
        var zip = restaurant.valueForKey("zipcode") as? String
        
        cell.cityLabel.text = city! + ", " + state + " " + zip!
        cell.cityLabel.sizeToFit()
        
        cell.phoneLabel.text = restaurant.valueForKey("phone") as? String
        
        let imageData = restaurant.valueForKey("imageData") as? NSData
        let myImage = UIImage(data: imageData!)
        cell.cellImage.image = myImage
        cell.cellImage.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    
    
}
