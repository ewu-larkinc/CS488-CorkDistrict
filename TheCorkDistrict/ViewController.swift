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
        
        
        self.navigationController?.providesPresentationContextTransitionStyle = true
        self.navigationController?.definesPresentationContext = true
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        
        //THIS ALLOWS THE BACKGROUND IMAGE TO SCROLL WITH THE TABLE CELLS - NEED A TALLER VERSION OF THE IMAGE
        //self.tableView.backgroundColor = UIColor(patternImage: background!)
        
        let dataManager = DataManager.sharedInstance
        dataManager.loadData()
        let testData = dataManager.getParking()
        
        if (testData.count == 0) {
            
            let loadingVC = LoadViewController(nibName: "LoadViewController", bundle: nil)
            //loadingVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            
            //error logged if I don't wait at least 1 second before calling the presentViewController method
            var timer = Timer(duration: 1.0, completionHandler: {
                self.navigationController?.presentViewController(loadingVC, animated: false, completion: nil)
            })
            
            timer.start()
        }
        
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

