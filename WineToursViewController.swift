//
//  WineToursViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import CoreData


class WineToursViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let wineTourCellIdentifier: String = "WineTourCell"
    var downtownCluster = [NSManagedObject]()
    var sodoCluster = [NSManagedObject]()
    var mtCluster = [NSManagedObject]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataManager = DataManager.sharedInstance
        dataManager.separateClusters()
        downtownCluster = dataManager.getDowntownCluster()
        mtCluster = dataManager.getMtCluster()
        sodoCluster = dataManager.getSoDoCluster()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
            case 0:
                return downtownCluster.count
            case 1:
                return mtCluster.count
            case 2:
                return sodoCluster.count
            default:
                return -1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
            case 0:
                return "Downtown Cluster"
            case 1:
                return "Mt. to Lake Cluster"
            case 2:
                return "SoDo Cluster"
            default:
                return "Default Cluster"
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return wineTourCellAtIndexPath(indexPath)
    }
    
    func wineTourCellAtIndexPath(indexPath: NSIndexPath) -> WineTourCell {
        let wineTourCell = tableView.dequeueReusableCellWithIdentifier(wineTourCellIdentifier) as! WineTourCell
        setContentForCell(wineTourCell, indexPath: indexPath)
        return wineTourCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func setContentForCell(cell:WineTourCell, indexPath:NSIndexPath) {
        
        var entity : NSManagedObject
        
        if indexPath.section == 0 {
            entity = downtownCluster[indexPath.row]
        }
        else if indexPath.section == 1 {
            entity = mtCluster[indexPath.row]
        }
        else {
            entity = sodoCluster[indexPath.row]
        }
        
        var name = entity.valueForKey("name") as? String
        var fakeDistance: String = "0 miles"
        
        cell.nameLabel.text = name
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.distanceLabel.text = fakeDistance
        cell.distanceLabel.adjustsFontSizeToFitWidth = true
        
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    }
    
    
}