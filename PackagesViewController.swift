//
//  PackagesViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import CoreData

class PackagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let altCellIdentifier = "AltCell"
    var packages = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "restBackground")!)
        
        let dataManager = DataManager.sharedInstance
        packages = dataManager.getPackages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    //# MARK: - TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return basicCellAtIndexPath(indexPath)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> AltCell {
        
        let altCell = tableView.dequeueReusableCellWithIdentifier(altCellIdentifier) as AltCell
        setContentForCell(altCell, indexPath: indexPath)
        return altCell
    }
    
    func setContentForCell(cell:AltCell, indexPath:NSIndexPath) {
        
        let package = packages[indexPath.row]
        cell.titleLabel.text = package.valueForKey("name") as? String
        cell.entityTitleLabel.text = package.valueForKey("relatedEntity") as? String
        cell.dateLabel.text = package.valueForKey("validDates") as? String
        cell.costLabel.text = package.valueForKey("cost") as? String
        
        let imageData = package.valueForKey("imageData") as? NSData
        let myImage = UIImage(data: imageData!)
        cell.cellImage.image = myImage
        
        cell.cellImage.layer.cornerRadius = 4.0
        cell.cellImage.clipsToBounds = true
        
        cell.cellImage.contentMode = UIViewContentMode.ScaleAspectFit
    }

    
    
}