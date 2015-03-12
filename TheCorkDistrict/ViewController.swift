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
        
        let dataManager = DataManager.sharedInstance
        dataManager.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

