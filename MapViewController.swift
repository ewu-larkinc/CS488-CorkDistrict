//
//  MapViewController.swift
//  CorkDistrict
//
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBAction func returnToHomePage(AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    //let geocoder = CLGeocoder()
    
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
        
        placeWineries(wineries, type: "winery")
        placeWineries(restaurants, type: "rest")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    @IBAction func filterWineries(AnyObject) {
        if(showWineries){
            placeWineries(wineries, type: "winery")
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
        //theMapView.removeAnnotations(theMapView.annotations)
    }
    func placeWineries(var array: [NSManagedObject], var type: String) {
        
        
        for var i = 0; i < array.count; i++
        {
            
            //var temp = wineries[i]
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
                
            }
            information.title = temp.valueForKey("name") as? String
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
        var alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = view.annotation.title!;
        alertView.message = "message";
        alertView.show();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}