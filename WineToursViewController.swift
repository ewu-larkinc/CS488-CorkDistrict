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
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "restBackground"))

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
        return 3
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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

        self.performSegueWithIdentifier("tourRoute", sender: self)

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let dvc = segue.destinationViewController as! TourMapViewController
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            if indexPath.row == 0 {
             //   println(downtownCluster)
                dvc.tour = downtownCluster
                dvc.currentCluster = 0
                
            } else if indexPath.row == 1 {
                
                dvc.tour = mtCluster
                dvc.currentCluster = 1
            }
            else {
                dvc.tour = sodoCluster
                dvc.currentCluster = 2
                
            }
        
        }
        
    }
    
    func setContentForCell(cell:WineTourCell, indexPath:NSIndexPath) {
        
        var mainText: String
        
        if indexPath.row == 0 {
            mainText = "Downtown Cluster"
        }
        else if indexPath.row == 1 {
            mainText = "Mt. Spokane Cluster"
        }
        else {
            mainText = "SoDo Cluster"
        }
        
        let fakeDistance: String = ""
        
        cell.nameLabel.text = mainText
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.nameLabel.textColor = UIColor.whiteColor()
        cell.distanceLabel.text = fakeDistance
        cell.distanceLabel.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    }
    
    
}