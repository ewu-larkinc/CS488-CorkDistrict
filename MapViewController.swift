//
//  MapViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBAction func returnToHomePage(AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    //let geocoder = CLGeocoder()
    
    let locationManager = CLLocationManager()
    
    var wineries = [NSManagedObject]()
    var restaurants = [NSManagedObject]()
    var hotels = [NSManagedObject]()
    var parking = [NSManagedObject]()
    var showWineries: Bool = false
    var pins = [MKPointAnnotation]()
    var winePins = [MKPointAnnotation]()
    var currentPin = Int()
    var currentType = NSString()
    
    @IBOutlet var theMapView: MKMapView!
    
    @IBOutlet var wineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hi
        // Do any additional setup after loading the view, typically from a nib.
        var lat: CLLocationDegrees = 47.66
        var long: CLLocationDegrees = -117.2999
        
        var latDelta: CLLocationDegrees = 0.5
        var longDelta: CLLocationDegrees = 0.5
        
        
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)

        //CoreData
        let dataManager = DataManager.sharedInstance
        wineries = dataManager.getWineries()
        restaurants = dataManager.getRestaurants()
        
        let util = MapUtilities()
        util.mapView = theMapView
        //util.distanceRequired = true
        
        
        //util.sortByDistance()
        
        //request user location
        locationManager.requestWhenInUseAuthorization()
        //  if locationManager.
        self.theMapView.showsUserLocation = true
        var wineriesTemp = [NSManagedObject]()
        wineriesTemp.append(wineries[1]);
        
       // util.getDirections(wineriesTemp, start: wineries[2]);
        
        util.placePinsOnMap(wineries, type: "winery")
        util.placePinsOnMap(restaurants, type: "rest")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    @IBAction func filterWineries(AnyObject) {
        if(showWineries){
            //MapUtilities.placePinsOnMap(wineries, type: "winery")
            showWineries = false
            wineButton.alpha = 1.0
        }
        else {
            removeWineries()
            showWineries = true
            wineButton.alpha = 0.5
        }
    }
    func removeWineries() {
        for var i = 0; i < wineries.count; i++ {
            theMapView.removeAnnotation(pins[i])
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            if(annotation.subtitle == "winery") {
                anView.image = UIImage(named:"Wine_Icon")
                self.currentType = "wine"
            }
            if(annotation.subtitle == "rest") {
                anView.image = UIImage(named:"Food_Icon")
                self.currentType = "rest"

            }
            if(annotation.subtitle == "hotel") {
                anView.image = UIImage(named:"Hotel_Icon")
                self.currentType = "hotel"

            }
            if(annotation.subtitle == "park") {
                anView.image = UIImage(named:"Park_Icon")
                self.currentType = "park"

            }
            anView.canShowCallout = false
            
        }
        else {
            anView.annotation = annotation
            
        }
    
        return anView
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        println("rendererForOverlay");
        
        if (overlay is MKPolyline) {
            var pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5);
            pr.lineWidth = 5;
            return pr;
        }
        
        
        return nil
    }
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
//......Determines what kind of pin was touched...........................................................//
        //var temp = NSManagedObject()
        currentPin = view.annotation.title!.toInt()!
        var temp = wineries[view.annotation.title!.toInt()!]

        if(view.annotation.subtitle == "winery") {
            temp = wineries[view.annotation.title!.toInt()!]
            self.currentType = "wine"
        }
        else if(view.annotation.subtitle == "rest") {
            temp = restaurants[view.annotation.title!.toInt()!]
            self.currentType = "rest"
        }
        else if(view.annotation.subtitle == "hotel") {
            temp = hotels[view.annotation.title!.toInt()!]
            self.currentType = "hotel"
        }
        else if(view.annotation.subtitle == "park") {
            
            temp = parking[view.annotation.title!.toInt()!]
            self.currentType = "park"
        }
        
//......Create a alertView when pin is clicked...........................................................//
        var alertView = UIAlertController(title: temp.valueForKey("name") as? String, message: temp.valueForKey("address") as? String, preferredStyle: .Alert)
        
        var imageView = UIImageView(frame: CGRectMake(10, 15, 50, 50))
        
        let imageData = temp.valueForKey("imageData") as? NSData
        
        imageView.image = UIImage(data: imageData!)
        
        alertView.view.addSubview(imageView)
        
        let callAction = UIAlertAction(title: "Call", style: .Default, handler: {
            action in
            let alertMessage = UIAlertController(title: "Are you sure?", message: "Are you sure you want to call this winery?", preferredStyle: .Alert)
            let callFinalAction = UIAlertAction(title: "Call", style: .Default, handler: {
                action in
                var pNumber = "tel://"
                pNumber += (temp.valueForKey("phone")as? String)!
                var url:NSURL? = NSURL(string: pNumber)
                UIApplication.sharedApplication().openURL(url!)
            })
            alertMessage.addAction(callFinalAction)
            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
            
            
            println(temp.valueForKey("phone") as? String)
        })
        
        let detailAction = UIAlertAction(title: "Details", style: .Default, handler: {
            action in
            //print("Hi")
            let detailVC = DetailViewController()
            
            self.performSegueWithIdentifier("mapDetail", sender: self)
           // DetailViewController.tableView(UITableView.new(), 5)

            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            action in
        })
        
        alertView.addAction(callAction)
        alertView.addAction(detailAction)
        alertView.addAction(cancelAction)
        
        
        
        self.presentViewController(alertView, animated: true, completion: nil)
        
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        
        
        var detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
        
        var selectedItem: NSManagedObject = wineries[currentPin] as NSManagedObject
        
        
        if(currentType == "wine")
        {
            selectedItem = wineries[currentPin] as NSManagedObject
            detailVC.currentSelection = selectedItem

            
        }
        else if(currentType == "rest")
        {
            selectedItem = restaurants[currentPin] as NSManagedObject
            detailVC.currentSelection = selectedItem

        }
        else if(currentType == "hotel")
        {
            selectedItem = hotels[currentPin] as NSManagedObject
            detailVC.currentSelection = selectedItem


        }
        else if(currentType == "park")
        {
            //selectedItem = parks[currentPin] as NSManagedObject
            //
            detailVC.currentSelection = selectedItem
        }
        
        
        //print("HMD IT works kinda \n")

        
        
      
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}