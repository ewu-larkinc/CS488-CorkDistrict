//
//  RoutingMapViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/26/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class RoutingMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var directionView: UIView!
    
    @IBAction func startBtnSelected(sender: AnyObject) {
        displayDirections = true
        switchViewDisplay()
        if textDirections.count > 0 {
            directionStepLabel.text = textDirections[stepIndex]
            
            if let location = locationManager.location {
                let theRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, (tripDistance!)/6, (tripDistance!)/6)
                mapView.setRegion(theRegion, animated: true)
            }
            
        }
    }
    @IBAction func previousStepSelected(sender: AnyObject) {
        
        if stepIndex > 0 {
            directionStepLabel.text = textDirections[--stepIndex]
        }
    }
    @IBAction func nextStepSelected(sender: AnyObject) {
        
        if stepIndex < textDirections.count-1 {
            directionStepLabel.text = textDirections[++stepIndex]
        }
    }
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var previousStepBtn: UIButton!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var directionStepLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    static let DEG_TO_RAD: Double = 0.017453292519943295769236907684886
    static let EARTH_RADIUS_IN_METERS = 6372797.560856
    
    private var textDirections = [String]()
    private var stepIndex: Int = 0
    static var numberOfLocationUpdates = 0
    
    let locationManager = CLLocationManager()
    var displayDirections = false
    var tripDistance: Double?
    var curLocPlacemark: MKPlacemark?
    
    
    override func viewDidLoad() {
        
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.startUpdatingLocation()
        
        setupLayoutObjects()
        
        
        let data = CorkDistrictData.sharedInstance
        if let tour = data.getCurrentTour() {
            
            print("GETTING WINE TOUR...")
            directionView.hidden = true
            mapView.showsUserLocation = false
            
            var centerLocation: CLLocationCoordinate2D
            let type = data.getCurrentTourType()
        
            //choose map center point based on
            if(type == WineTourType.Downtown) {
                centerLocation = CLLocationCoordinate2DMake(47.654447, -117.424911)
            } else if(type == WineTourType.MtSpokane) {
                centerLocation = CLLocationCoordinate2DMake(47.765638, -117.303686)//47.654461, -117.425019)
            } else {
                centerLocation = CLLocationCoordinate2DMake(47.657251, -117.409676)
            }
            
            let frameLength = CLLocationDistance(500)
            
            let theRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(centerLocation, frameLength, frameLength)
            
            mapView.setRegion(theRegion, animated: true)
            
            for entity in tour {
                let annotation = WineryAnnotation(title: entity.title, coordinate: entity.coordinate!, phone: entity.phone)
                mapView.addAnnotation(annotation)
            }
        } else {
            initRouting()
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func initRouting() {
        
        let data = CorkDistrictData.sharedInstance
        if let entity = data.getSelectedEntity() {
            if let destPt = entity.coordinate {
                print("GETTING ROUTE COORDINATES")
                
                
                let destPlacemark = MKPlacemark(coordinate: destPt, addressDictionary: nil)
                
                guard let location = locationManager.location else {
                    print("Couldn't obtain user location!")
                    return
                }
                
                let curLocPlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
                tripDistance = RoutingMapViewController.getDistanceBetweenCoordinates(location.coordinate, to: destPt)
                print("Distance between coordinates is \(tripDistance)")
                
                let request = MKDirectionsRequest()
                request.source = MKMapItem(placemark: curLocPlacemark)
                request.destination = MKMapItem(placemark: destPlacemark)
                
                let destinationAnnotation = DestinationAnnotation(title: entity.title, coordinate: destPt, phone: entity.phone)
                
                let theRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, tripDistance!, tripDistance!)
                mapView.setRegion(theRegion, animated: false)
                mapView.addAnnotation(destinationAnnotation)
                
                
                let directions = MKDirections(request: request)
                directions.calculateDirectionsWithCompletionHandler ({
                    (response: MKDirectionsResponse?, error: NSError?) in
                    
                    if error != nil{
                        print(error)
                    }
                    else {
                        self.showRoute(response!)
                        self.locationManager.startUpdatingLocation()
                    }
                    
                })
                
            }
        }
    }
    
    func setupLayoutObjects() {
        
        startBtn.layer.cornerRadius = 3.0
        
        directionView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        directionView.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        directionView.layer.shadowOpacity = 0.7
        directionView.layer.shadowRadius = 1
        startBtn.layer.shadowColor = UIColor.darkGrayColor().CGColor
        startBtn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        startBtn.layer.shadowOpacity = 0.7
        startBtn.layer.shadowRadius = 1
    }
    
    static func getDistanceBetweenCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        
        let latitudeArc  = (from.latitude - to.latitude) * DEG_TO_RAD;
        let longitudeArc = (from.longitude - to.longitude) * DEG_TO_RAD;
        var latitudeH = sin(latitudeArc * 0.5);
        latitudeH *= latitudeH;
        var longitudeH = sin(longitudeArc * 0.5);
        longitudeH *= longitudeH;
        let tmp = cos(from.latitude*DEG_TO_RAD) * cos(to.latitude*DEG_TO_RAD);
        return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*longitudeH));
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 2.0
        return renderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
            
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "DestinationAnnotation")
            
            if annotation is DestinationAnnotation {
                view.image = UIImage(named: "finishTag")
                return view
            } else if annotation is WineryAnnotation {
                view.image = UIImage(named: "wineryIcon")
                return view
            }
            
        
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        print("DidUpdateUserLocation executing now...")
        
        if RoutingMapViewController.numberOfLocationUpdates == 0 {
            initRouting()
            RoutingMapViewController.numberOfLocationUpdates++
        } else {
            mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
        }
        mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
    }
    
    func showRoute(response: MKDirectionsResponse) {
        
        textDirections = [String]()
        
        for route in response.routes {
            
            for step in route.steps {
                textDirections.append(step.instructions)
            }
            
            mapView.addOverlay(route.polyline,
                level: MKOverlayLevel.AboveRoads)
        }
        
        
    }
    
    func switchViewDisplay() {
        
        if displayDirections {
            directionStepLabel.hidden = false
            previousStepBtn.hidden = false
            nextStepBtn.hidden = false
            startBtn.enabled = false
            directionStepLabel.enabled = true
            previousStepBtn.enabled = true
            nextStepBtn.enabled = true
            startBtn.hidden = true
            
        } else {
            directionStepLabel.hidden = true
            previousStepBtn.hidden = true
            nextStepBtn.hidden = true
            startBtn.enabled = true
            directionStepLabel.enabled = false
            previousStepBtn.enabled = false
            nextStepBtn.enabled = false
            startBtn.hidden = false
            
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            if let t = annotation.title, s = annotation.subtitle {
                if let title = t, subtitle = s {
                    
                    let alertView = UIAlertController(title: title, message: subtitle, preferredStyle: .Alert)
                    
                    let callAction = UIAlertAction(title: "Call", style: .Default, handler: {
                        action in
                        let alertMessage = UIAlertController(title: "Are you sure?", message: "Are you sure you want to call this winery?", preferredStyle: .Alert)
                        let callFinalAction = UIAlertAction(title: "Call", style: .Default, handler: {
                            action in
                            let pNumber = "tel://" + subtitle
                            let url:NSURL? = NSURL(string: pNumber)
                            UIApplication.sharedApplication().openURL(url!)
                        })
                        
                        alertMessage.addAction(callFinalAction)
                        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        self.presentViewController(alertMessage, animated: true, completion: nil)
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
            }
        }
        
        
    }
    
    
}