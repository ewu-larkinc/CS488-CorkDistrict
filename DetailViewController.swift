//
//  DetailViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import CoreData
import QuartzCore

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let titleRowHeight : CGFloat = 75.0
    let imageRowHeight : CGFloat = 300.0
    let defaultRowHeight : CGFloat = 60.0
    let imageViewMargin = 17.0 as CGFloat
    var currentSelection : NSManagedObject!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    //# MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "detailBackground"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //# MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func loadDetailView(id: Int)
    {
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell") as! UITableViewCell
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        cell.textLabel?.text = ""
        cell.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel?.text = currentSelection.valueForKey("name") as? String
            case 1:
                let city = currentSelection.valueForKey("city") as? String
                let zipcode = currentSelection.valueForKey("zipcode") as? String
                var addressLine = currentSelection.valueForKey("address") as? String
                var cityLine = "\n" + city! + ", WA " + zipcode!
                cell.textLabel?.text = addressLine! + cityLine
            case 2:
                cell.textLabel?.text = currentSelection.valueForKey("phone") as? String
            case 3:
                let imageData = currentSelection.valueForKey("imageData") as? NSData
                let mainImage = UIImage(data: imageData!)
                let newImageView = UIImageView(frame: CGRectMake((imageViewMargin),cell.frame.origin.y,(tableView.frame.width-(imageViewMargin*2)), imageRowHeight))
            
                newImageView.layer.borderColor = UIColor.whiteColor().CGColor
                newImageView.layer.borderWidth = 2.0
                newImageView.image = mainImage
                cell.addSubview(newImageView)
            case 4:
                cell.textLabel?.text = currentSelection.valueForKey("about") as? String
                cell.textLabel?.textAlignment = NSTextAlignment.Justified
            default:
                break
        }

        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 2) {
            var tempNum = currentSelection.valueForKey("phone") as! NSString
            var tempNumStr = tempNum.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://#\(tempNumStr)")!)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.row) {
            case 1:
                return titleRowHeight
            case 3:
                return imageRowHeight
            case 4:
                var tempStr = currentSelection.valueForKey("about") as! String
                var size = getSizeForText(tempStr)
                return size
            default:
                return defaultRowHeight
        }
    }
    
    func getSizeForText(cellText: String) -> CGFloat {
        var length = CGFloat(count(cellText.utf16))
        var rowSize : CGFloat = (length/13.0)*12.0
        return rowSize
    }
    
}