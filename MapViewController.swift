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

        //CoreData
        let dataManager = DataManager.sharedInstance
        wineries = dataManager.getWineries()
        restaurants = dataManager.getRestaurants()
        hotels = dataManager.getAccommodations()
        parking = dataManager.getParking()
        
        util.mapView = theMapView
        
        //request user location
        locationManager.requestWhenInUseAuthorization()
        self.theMapView.showsUserLocation = true
        
        var coord = CLLocationCoordinate2D()
        coord.latitude = 47.655262
        coord.longitude = -117.414129
        
        var wineriesTemp = [NSManagedObject]()
        wineriesTemp.append(wineries[2]);
        
        //self.mapRoutes = self.util.getDirections(wineriesTemp, start: coord)

        //self.util.sortByDistance(self.mapRoutes)

        winePins = util.placePinsOnMap(wineries, type: "winery")
        restPins = util.placePinsOnMap(restaurants, type: "rest")
        hotelPins = util.placePinsOnMap(hotels, type: "hotel")
        parkPins = util.placePinsOnMap(parking, type: "park")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false

        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(47.655262, -117.414129)
        
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
    }
    
    @IBAction func filterWineries(AnyObject) {
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
    @IBAction func filterHotels(AnyObject) {
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
    @IBAction func filterRest(AnyObject) {
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
    @IBAction func filterParking(AnyObject) {
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
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is MKPointAnnotation) {
            return nil
        }

            var anView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            if(annotation.subtitle == "winery") {
                anView.image = UIImage(named:"Wine_Icon")
            }
            else if(annotation.subtitle == "rest") {
                anView.image = UIImage(named:"Food_Icon")
            }
            else if(annotation.subtitle == "hotel") {
                anView.image = UIImage(named:"Hotel_Icon")
            }
            else if(annotation.subtitle == "park") {
                anView.image = UIImage(named:"Car_Icon")
            }
            anView.canShowCallout = false

    
        return anView
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if (overlay is MKPolyline) {
            var pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7);
            pr.lineWidth = 4;
            return pr;
        }
        
        
        return nil
    }
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
//......Determines what kind of pin was touched...........................................................//
        var temp = wineries[view.annotation.title!.toInt()!]
        
        if(view.annotation.subtitle == "winery") {
            temp = wineries[view.annotation.title!.toInt()!]
        }
        else if(view.annotation.subtitle == "rest") {
            temp = restaurants[view.annotation.title!.toInt()!]
        }
        else if(view.annotation.subtitle == "hotel") {
            temp = hotels[view.annotation.title!.toInt()!]
        }
        else if(view.annotation.subtitle == "park") {
            temp = parking[view.annotation.title!.toInt()!]
        }
        
        
        
        print("PIN SUBTITLE: "+view.annotation.subtitle!+"\n")
        
        
        
        
//......Create a alertView when pin is clicked...........................................................//
        var alertView = UIAlertController(title: temp.valueForKey("name") as? String, message: temp.valueForKey("address") as? String, preferredStyle: .Alert)
        
        var imageView = UIImageView(frame: CGRectMake(10, 15, 50, 50))
        if(view.annotation.subtitle != "park") {
            let imageData = temp.valueForKey("imageData") as? NSData
            
            imageView.image = UIImage(data: imageData!)
            
            alertView.view.addSubview(imageView)
        }
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
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            action in
            
        })
        
        alertView.addAction(callAction)
        alertView.addAction(detailAction)
        alertView.addAction(cancelAction)
        
        
        
        presentViewController(alertView, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}