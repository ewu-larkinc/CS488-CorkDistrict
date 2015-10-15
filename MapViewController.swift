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
    
    
    @IBAction func returnToHomePage(_: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    let locationManager = CLLocationManager()
    
    var showWineries: Bool = false
    var showHotels: Bool = false
    var showParking: Bool = false
    var showRest: Bool = false
    
    var winePins = [MKPointAnnotation]()
    var hotelPins = [MKPointAnnotation]()
    var parkPins = [MKPointAnnotation]()
    var restPins = [MKPointAnnotation]()
    
    let util = MapUtilities()
    var mapRoutes = [MKRoute]()
    
    @IBOutlet var theMapView: MKMapView!
    
    @IBOutlet var parkButton: UIButton!
    @IBOutlet var restButton: UIButton!
    @IBOutlet var wineButton: UIButton!
    @IBOutlet var hotelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        util.mapView = theMapView
        util.multiPinsMap()
        
        //request user location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.theMapView.showsUserLocation = true
        
        //fill pin arrays
        winePins = util.pinTypeOnMap("winery")
        
        restPins = util.pinTypeOnMap("rest")
        
        hotelPins = util.pinTypeOnMap("hotel")
        
        parkPins = util.pinTypeOnMap("park")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        
        let centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(47.655262, -117.414129)
        
        let theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
    }
    
    @IBAction func filterWineries(_: AnyObject) {
        if(showWineries){
            addPins(winePins)
            showWineries = false
            wineButton.alpha = 1.0
        }
        else {
            removePins(winePins)
            showWineries = true
            wineButton.alpha = 0.5
        }
    }
    @IBAction func filterHotels(_: AnyObject) {
        if(showHotels){
            addPins(hotelPins)
            showHotels = false
            hotelButton.alpha = 1.0
        }
        else {
            removePins(hotelPins)
            showHotels = true
            hotelButton.alpha = 0.5
        }
    }
    @IBAction func filterRest(_: AnyObject) {
        if(showRest){
            addPins(restPins)
            showRest = false
            restButton.alpha = 1.0
        }
        else {
            removePins(restPins)
            showRest = true
            restButton.alpha = 0.5
        }
    }
    @IBAction func filterParking(_: AnyObject) {
        if(showParking){
            addPins(parkPins)
            showParking = false
            parkButton.alpha = 1.0
        }
        else {
            removePins(parkPins)
            showParking = true
            parkButton.alpha = 0.5
        }
    }
    func removePins(arraytype: [MKPointAnnotation]) {
        for var i = 0; i < arraytype.count; i++ {
            theMapView.removeAnnotation(arraytype[i])
        }
    }
    
    func addPins(arraytype: [MKPointAnnotation]) {
        for var i = 0; i < arraytype.count; i++ {
            theMapView.addAnnotation(arraytype[i])
        }
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        return util.viewForAnnotation(mapView, viewForAnnotation: annotation)
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        //if (overlay is MKPolyline) {
            
            return util.renderForOverlay(mapView, rendererForOverlay: overlay)
        //}
        
        //return nil
    }
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let temp = util.didSelectAnnotationView(view)
        view.canShowCallout = false;

        if(temp != nil)
        {
        
            let alertV: UIAlertController = sameAddress(temp!, view: view)
        
            if(alertV.actions.count > 1) {
                self.presentViewController(alertV, animated: true, completion: nil)
            }
            else {
                detailAlertView(temp!, view: view)
            }
        }
        else{
            view.canShowCallout = false;

        }
        
    }
    func sameAddress( temp: NSManagedObject, view: MKAnnotationView!) -> UIAlertController{
        
        var returnType = UIAlertController()
        
        var shouldAlert: Bool = false
        
        let address:String = temp.valueForKey("address") as! String
        
        let alertView = UIAlertController(title: "Warning: Same Address", message: "", preferredStyle: .Alert)
        
        //var imageView = UIImageView(frame: CGRectMake(10, 15, 50, 50))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            action in
            
        })
        var tempAction = UIAlertAction(title: (temp.valueForKey("name") as! String), style: .Default, handler: {
            action in
            self.detailAlertView(temp, view: view)
        })
        
        alertView.addAction(tempAction)
        alertView.addAction(cancelAction)
        
        for location in util.getWineries() {
            if(location.valueForKey("address") as! String == address && temp != location) {
                
                shouldAlert = true
                
                tempAction = UIAlertAction(title: location.valueForKey("name") as? String, style: .Default, handler: {
                    action in
                    self.detailAlertView(location, view: view)
                })
                
                alertView.addAction(tempAction)
                
            }
        }
        if(shouldAlert) {
            returnType = alertView
        }
        return returnType
    }
    func detailAlertView( temp: NSManagedObject, view: MKAnnotationView!) {
        
        let alertView = UIAlertController(title: temp.valueForKey("name") as? String, message: temp.valueForKey("address") as? String, preferredStyle: .Alert)

        let callAction = UIAlertAction(title: "Call", style: .Default, handler: {
            action in
            let alertMessage = UIAlertController(title: "Are you sure?", message: "Are you sure you want to call this winery?", preferredStyle: .Alert)
            let callFinalAction = UIAlertAction(title: "Call", style: .Default, handler: {
                action in
                var pNumber = "tel://"
                pNumber += (temp.valueForKey("phone")as? String)!
                let url:NSURL? = NSURL(string: pNumber)
                UIApplication.sharedApplication().openURL(url!)
            })
            alertMessage.addAction(callFinalAction)
            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
            
            
            print(temp.valueForKey("phone") as? String)
        })
        
        let detailAction = UIAlertAction(title: "Details", style: .Default, handler: {
            action in
            self.performSegueWithIdentifier("mapDetail", sender: self)

            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            action in
            
        })
        
        alertView.addAction(callAction)
        if(view.annotation!.subtitle! != "park") {
            alertView.addAction(detailAction)
        }
        alertView.addAction(cancelAction)
        
        
        
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        
        let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
        
        var selectedItem: NSManagedObject = util.wineries[util.currentPin] as NSManagedObject
        
        
        if(util.currentType == "winery")
        {
            selectedItem = util.wineries[util.currentPin] as NSManagedObject
            detailVC.currentSelection = selectedItem
            
            
        }
        else if(util.currentType == "rest")
        {
            selectedItem = util.restaurants[util.currentPin] as NSManagedObject
            detailVC.currentSelection = selectedItem
            
        }
        else if(util.currentType == "hotel")
        {
            selectedItem = util.hotels[util.currentPin] as NSManagedObject
            detailVC.currentSelection = selectedItem
            
        }
  
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}