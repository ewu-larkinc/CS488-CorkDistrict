//
//  ParkingViewController.swift
//  TheCorkDistrict
//
//

import Foundation
import UIKit
import CoreData

class ParkingViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    let parkingCellIdentifier = "ParkingCell"
    var parking = [NSManagedObject]()
    
    //# MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataManager = DataManager.sharedInstance
        parking = dataManager.getParking()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "parkingBackground"))
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
        return parking.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return parkingCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func parkingCellAtIndexPath(indexPath:NSIndexPath) -> ParkingCell {
        
        let parkingCell = tableView.dequeueReusableCellWithIdentifier(parkingCellIdentifier) as! ParkingCell
        setContentForCell(parkingCell, indexPath: indexPath)
        return parkingCell
    }
    
    func setContentForCell(cell:ParkingCell, indexPath:NSIndexPath) {
        
        let parkingLot = parking[indexPath.row]
        cell.titleLabel.text = parkingLot.valueForKey("name") as? String
        cell.addressLabel.text = parkingLot.valueForKey("address") as? String
        
        var cityText = parkingLot.valueForKey("city") as? String
        var zipText = parkingLot.valueForKey("zipcode") as? String
        cell.cityLabel.text = cityText! + ", WA " + zipText!
        cell.phoneLabel.text = parkingLot.valueForKey("phone") as? String
        
    }

    
}
