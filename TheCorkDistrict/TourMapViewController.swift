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
    
    
    @IBAction func returnToHomePage(_: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    let locationManager = CLLocationManager()
    
    var tourPins = [MKPointAnnotation]()
    
    let util = MapUtilities()
    var currentCluster = Int()
    var tour: [NSManagedObject] = [NSManagedObject]()
    var mapRoutes = [MKRoute]()
    
    @IBOutlet var theMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        util.mapView = theMapView
        
        //locationManager.requestWhenInUseAuthorization()
        
        self.theMapView.showsUserLocation = true
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(47.655262, -117.414129)

        
        if(currentCluster == 0) // Downtown
        {
            theSpan = MKCoordinateSpanMake(0.025, 0.025)
            centerLocation = CLLocationCoordinate2DMake(47.654447, -117.424911)
        }
        if(currentCluster == 1) // Mtn to Lake
        {
            theSpan = MKCoordinateSpanMake(0.2, 0.2)
            centerLocation = CLLocationCoordinate2DMake(47.765638, -117.303686)//47.654461, -117.425019)
        }
        if(currentCluster == 2) // SODO
        {
            theSpan = MKCoordinateSpanMake(0.03, 0.03)
            centerLocation = CLLocationCoordinate2DMake(47.657251, -117.409676)
        }
        
        let theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
        
        tourPins = util.placePinsOnMap(tour, type: "winery")
        
       // util.getDirections(tour, start: tourPins[0].coordinate)
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
        let anView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
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
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        //var temp = tour[view.annotation!.title.toInt()!]
        if let annotation = view.annotation {
            if let title = annotation.title {
                if let unwrappedTitle = title {
                    let index = Int(unwrappedTitle)
                    let temp = tour[index!]
                    
                    //util.currentPin = view.annotation.title!.toInt()!
                    if let a2 = view.annotation {
                        if let title2 = a2.title {
                            if let unwrappedTitle2 = title2 {
                                util.currentPin = Int(unwrappedTitle2)!
                                
                            }
                        }
                    }
                    
                    let alertV: UIAlertController = sameAddress(temp, view: view)
                    
                    if(alertV.actions.count > 1) {
                        self.presentViewController(alertV, animated: true, completion: nil)
                    }
                    else {
                        detailAlertView(temp, view: view)
                    }
                }
            }
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
            self.performSegueWithIdentifier("tourDetail", sender: self)
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
        let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
        var selectedItem: NSManagedObject = tour[util.currentPin] as NSManagedObject
        selectedItem = tour[util.currentPin] as NSManagedObject
        detailVC.currentSelection = selectedItem
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}