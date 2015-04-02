//
//  ParkingViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 3/31/15.
//  Copyright (c) 2015 Chris Larkin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ParkingViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    let simpleCellIdentifier = "SimpleCell"
    var parking = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "restBackground")!)
        
        let dataManager = DataManager.sharedInstance
        parking = dataManager.getParking()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parking.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return simpleCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func simpleCellAtIndexPath(indexPath:NSIndexPath) -> SimpleCell {
        
        let simpleCell = tableView.dequeueReusableCellWithIdentifier(simpleCellIdentifier) as SimpleCell
        setContentForCell(simpleCell, indexPath: indexPath)
        return simpleCell
    }
    
    func setContentForCell(cell:SimpleCell, indexPath:NSIndexPath) {
        
        let parkingLot = parking[indexPath.row]
        cell.titleLabel.text = parkingLot.valueForKey("name") as? String
        cell.addressLabel.text = parkingLot.valueForKey("address") as? String
        
        var cityText = parkingLot.valueForKey("city") as? String
        var zipText = parkingLot.valueForKey("zipcode") as? String
        cell.cityLabel.text = cityText! + ", WA " + zipText!
        cell.phoneLabel.text = parkingLot.valueForKey("phone") as? String
        
    }

    
}