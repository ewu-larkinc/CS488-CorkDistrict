//
//  ViewController.swift
//  CorkDistrict
//
//

import UIKit

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "menuBackground"))
        let background = UIImage(named: "menuBackground")
        
        //THIS ALLOWS THE BACKGROUND IMAGE TO SCROLL WITH THE TABLE CELLS - NEED A TALLER VERSION OF THE IMAGE
        //self.tableView.backgroundColor = UIColor(patternImage: background!)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

