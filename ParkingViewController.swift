//
//  ParkingViewController.swift
//  TheCorkDistrict
//
//

import Foundation
import UIKit
import CoreData

class ParkingViewController : UIViewController {
    
    @IBOutlet weak var winePassButton: UIImageView!
    
    @IBAction func launchWinePassURL(AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.visitspokane.com/cork-district/winepass")!)
    }
    
    let parkingCellIdentifier = "ParkingCell"
    var parking = [NSManagedObject]()
    
    //# MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    

    
}
