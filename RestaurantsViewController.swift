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
    let basicCellIdentifier = "BasicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataManager = DataManager.sharedInstance
        restaurants = dataManager.getRestaurants()
        
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "restBackground"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let dvc = segue.destinationViewController as DetailViewController
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let restaurant = restaurants[indexPath.row]
            dvc.currentSelection = restaurant
        }
        
    }
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
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
        let restaurant = restaurants[indexPath.row]
        cell.titleLabel.text = restaurant.valueForKey("name") as? String
        cell.addressLabel.text = restaurant.valueForKey("address") as? String
        
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        
        var city = restaurant.valueForKey("city") as? String
        city = city?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var state = "WA"
        var zip = restaurant.valueForKey("zipcode") as? String
        
        cell.cityLabel.text = city! + ", " + state + " " + zip!
        cell.cityLabel.sizeToFit()
        
        //TESTING//////////////////////////////////
        cell.cityLabel.removeConstraints(cell.cityLabel.constraints())
        
        cell.phoneLabel.text = restaurant.valueForKey("phone") as? String
        
        let imageData = restaurant.valueForKey("imageData") as? NSData
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
