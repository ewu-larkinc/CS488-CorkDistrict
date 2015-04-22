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
    var showWineries: Bool = false
    var winePins = [MKPointAnnotation]()
    
    @IBOutlet var theMapView: MKMapView!
    
    @IBOutlet var wineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //CoreData
        let dataManager = DataManager.sharedInstance
        wineries = dataManager.getWineries()
        restaurants = dataManager.getRestaurants()
        
        // Do any additional setup after loading the view, typically from a nib.
        var lat: CLLocationDegrees = 47.66
        var long: CLLocationDegrees = -117.2999
        
        var latDelta: CLLocationDegrees = 0.5
        var longDelta: CLLocationDegrees = 0.5
        
        
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
        
        
        
        //request user location
        locationManager.requestWhenInUseAuthorization()
        //  if locationManager.
        self.theMapView.showsUserLocation = true
        
        placePinsOnMap(wineries, type: "winery")
        placePinsOnMap(restaurants, type: "rest")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    @IBAction func filterWineries(AnyObject) {
        if(showWineries){
            placePinsOnMap(wineries, type: "winery")
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
            theMapView.removeAnnotation(winePins[i])
        }
    }
    func placePinsOnMap(var array: [NSManagedObject], var type: String) {
        
        
        for var i = 0; i < array.count; i++
        {
            
            var temp = array[i]
            var information = MKPointAnnotation()
            
            var address:String = temp.valueForKey("address") as! String
            var city:String = temp.valueForKey("city") as! String
            if(temp.valueForKey("placemark") != nil) {
                
                var mypin: String = temp.valueForKey("placemark") as! String
                var llarray = mypin.componentsSeparatedByString(",")
                
                information.coordinate.latitude = NSString(string: llarray[0]).doubleValue
                information.coordinate.longitude = NSString(string: llarray[1]).doubleValue
            }
            else {
                var geocoder = CLGeocoder()
                geocoder.geocodeAddressString( "\(address), \(city), WA, USA", completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                    if let placemark = placemarks?[0]  as? CLPlacemark
                    {
                        var lat: String = "\(placemark.location.coordinate.latitude),"
                        var long: String  = "\(placemark.location.coordinate.longitude)"
                        
                        information.coordinate.latitude = NSString(string: lat).doubleValue
                        information.coordinate.longitude = NSString(string: long).doubleValue
                    }
                    
                })
            }
            
            information.title = "\(i)"
            information.subtitle = type
            
            winePins.append(information)
            
            theMapView.addAnnotation(information)
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
            }
            if(annotation.subtitle == "rest") {
                anView.image = UIImage(named:"Food_Icon")
            }
            anView.canShowCallout = false
            
        }
        else {
            anView.annotation = annotation
            
        }
        
        return anView
    }
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        var index = view.annotation.title!.toInt()!
        
        var temp = wineries[index]
        
        if(view.annotation.subtitle == "winery") {
            temp = wineries[index]
        }
        else if(view.annotation.subtitle == "rest") {
            temp = restaurants[index]
        }
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