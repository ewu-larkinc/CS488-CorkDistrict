//
//  AccomodationsViewController.swift
//  CorkDistrict
//
//


import Foundation
import UIKit
import CoreData

class AccomodationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var accommodations = [NSManagedObject]()
    let basicCellIdentifier = "BasicCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataManager = DataManager.sharedInstance
        accommodations = dataManager.getAccommodations()
        
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "restBackground"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let dvc = segue.destinationViewController as DetailViewController
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let accommodation = accommodations[indexPath.row]
            dvc.currentSelection = accommodation
        }
        
    }
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accommodations.count
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
        
        let accommodation = accommodations[indexPath.row]
        let imageData = accommodation.valueForKey("imageData") as? NSData
        let cellImage = UIImage(data: imageData!)
        
        var city = accommodation.valueForKey("city") as? String
        var zip = accommodation.valueForKey("zipcode") as? String
        var name = accommodation.valueForKey("name") as? String
        var phone = accommodation.valueForKey("phone") as? String
        var address = accommodation.valueForKey("address") as? String
        var website = accommodation.valueForKey("website") as? String
        var state = "WA"
        
        city = city?.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        cell.cellImage.image = cellImage
        cell.titleLabel.text = name
        cell.addressLabel.text = address
        cell.phoneLabel.text = phone
        cell.websiteLabel.text = website
        cell.cityLabel.text = city! + ", " + state + " " + zip!
        cell.cityLabel.sizeToFit()
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.addressLabel.textColor = UIColor.whiteColor()
        cell.cityLabel.textColor = UIColor.whiteColor()
        cell.phoneLabel.textColor = UIColor.whiteColor()
        cell.websiteLabel.textColor = UIColor.whiteColor()

        cell.cellImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    }

    
}
