//
//  TourMapViewController.swift
//  TheCorkDistrict
//
//  Created by Bowman on 5/13/15.
//  Copyright (c) 2015 Chris Larkin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TourMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBAction func returnToHomePage(AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    let locationManager = CLLocationManager()
    
    var tourPins = [MKPointAnnotation]()
    
    let util = MapUtilities()
    
    var tour: [NSManagedObject]!
    
    var mapRoutes = [MKRoute]()
    
    @IBOutlet var theMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        util.mapView = theMapView
        
        locationManager.requestWhenInUseAuthorization()
        
        self.theMapView.showsUserLocation = true
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(47.655262, -117.414129)
        
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
        
        tourPins = util.placePinsOnMap(tour, type: "winery")
        
        util.getDirections(tour, start: tourPins[0].coordinate)
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
        var anView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        anView.image = UIImage(named:"Wine_Icon")

        anView.canShowCallout = false
        
        return anView
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if (overlay is MKPolyline) {
            
            return util.renderForOverlay(mapView, rendererForOverlay: overlay)
        }
        
        return nil
    }
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        var temp = util.didSelectAnnotationView(view)
        
        var alertV: UIAlertController = sameAddress(temp, view: view)
        
        if(alertV.actions.count > 1) {
            self.presentViewController(alertV, animated: true, completion: nil)
        }
        else {
            detailAlertView(temp, view: view)
        }
        
    }
    func sameAddress(var temp: NSManagedObject, view: MKAnnotationView!) -> UIAlertController{
        
        var returnType = UIAlertController()
        
        var shouldAlert: Bool = false
        
        var address:String = temp.valueForKey("address") as! String
        
        var alertView = UIAlertController(title: "Warning: Same Address", message: "", preferredStyle: .Alert)
        
        var imageView = UIImageView(frame: CGRectMake(10, 15, 50, 50))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            action in
            
        })
        var tempAction = UIAlertAction(title: temp.valueForKey("name") as! String, style: .Default, handler: {
            action in
            self.detailAlertView(temp, view: view)
        })
        
        alertView.addAction(tempAction)
        alertView.addAction(cancelAction)
        
        for location in util.getWineries() {
            if(location.valueForKey("address") as! String == address && temp != location) {
                
                shouldAlert = true
                
                tempAction = UIAlertAction(title: location.valueForKey("name") as! String, style: .Default, handler: {
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
    func detailAlertView(var temp: NSManagedObject, view: MKAnnotationView!) {
        
        var alertView = UIAlertController(title: temp.valueForKey("name") as? String, message: temp.valueForKey("address") as? String, preferredStyle: .Alert)
        
        if(view.annotation.subtitle != "park") {
            var imageView = UIImageView(frame: CGRectMake(10, 15, 50, 50))
            
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