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
    var showWineries: Bool = false
    var winePins = [MKPointAnnotation]()
    
    @IBOutlet var theMapView: MKMapView!
    
    @IBOutlet var wineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CoreData
        let dataManager = DataManager.sharedInstance
        wineries = dataManager.getWineries()
        
        // Do any additional setup after loading the view, typically from a nib.
        var lat: CLLocationDegrees = 47.66
        var long: CLLocationDegrees = -117.2999
        
        var latDelta: CLLocationDegrees = 0.5
        var longDelta: CLLocationDegrees = 0.5
        
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var centerLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        var theRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerLocation, theSpan)
        
        self.theMapView.setRegion(theRegion, animated: true)
        
        placeWineries()
        
    }
    @IBAction func filterWineries(AnyObject) {
        if(showWineries){
            placeWineries()
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
    func placeWineries() {
        
        
        
        for var i = 0; i < wineries.count; i++
        {
            
            var geocoder = CLGeocoder() // moved this line of code inside the forloop to make a new geocoder every iteration through the loop. DUHHH
            
            let temp = wineries[i]
            let information = MKPointAnnotation()
            
            var address:String = temp.valueForKey("address") as String
            var city:String = temp.valueForKey("city") as String
            
            geocoder.geocodeAddressString( "\(address), \(city), WA, USA", {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                if let placemark = placemarks?[0]  as? CLPlacemark
                {
                    information.coordinate = placemark.location.coordinate
                    
                    //information.coordinate = method that returns placemark.location.coordinate
                }
                
            })
            
            information.title = temp.valueForKey("name") as? String
            information.subtitle = address
            
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
            anView.image = UIImage(named:"Wine_Icon")
            anView.canShowCallout = true
        }
        else {
            anView.annotation = annotation
        }
        
        return anView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}