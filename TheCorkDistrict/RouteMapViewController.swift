//
//  RouteMapViewController.swift
//  TheCorkDistrict
//
//  Created by Bowman on 5/13/15.
//  Copyright (c) 2015 Chris Larkin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class RouteMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBAction func returnToHomePage(AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    let locationManager = CLLocationManager()
    var clusterArray = [NSManagedObject]()
    
    var locationPin = [MKPointAnnotation]()
    
    let util = MapUtilities()
    
    var destination: NSManagedObject!
    
    var mapRoutes = [MKRoute]()
    
    @IBOutlet var theMapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        util.mapView = theMapView
       /*
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
*/
        locationManager.startUpdatingLocation()
        self.theMapView.showsUserLocation = true
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.09, 0.09)
        var mypin: String = destination.valueForKey("placemark") as! String
        var llarray = mypin.componentsSeparatedByString(",")
        
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(NSString(string: llarray[0]).doubleValue, NSString(string: llarray[1]).doubleValue)//self.theMapView.userLocation.location.coordinate
        //CLLocationCoordinate2DMake(47.655262, -117.414129)
        
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
        
        var destinationArray = [NSManagedObject]()
        destinationArray.append(destination)
        
        //destination.
        
        util.placePinsOnMap(destinationArray, type: "finish")
        print("Lat: ")
        println(self.locationManager.location.coordinate.latitude)
        print("Long: ")
        println(self.locationManager.location.coordinate.longitude)
        
        util.getDirections(destinationArray, start: CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude))


    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = false
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        //return nil
       return util.viewForAnnotation(mapView, viewForAnnotation: annotation)
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if (overlay is MKPolyline) {
            
            return util.renderForOverlay(mapView, rendererForOverlay: overlay)
        }
        
        return nil
    }
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {

        detailAlertView(destination, view: view)
        
    }
    func detailAlertView(var temp: NSManagedObject, view: MKAnnotationView!) {
    
        
        view.canShowCallout = false
        
        var alertView = UIAlertController(title: temp.valueForKey("name") as? String, message: temp.valueForKey("address") as? String, preferredStyle: .Alert)
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
            self.performSegueWithIdentifier("routeToDetail", sender: self)
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

        detailVC.currentSelection = destination
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}