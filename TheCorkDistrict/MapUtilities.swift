//
//  MapUtilities.swift
//  TheCorkDistrict
//
//  Created by Bowman on 4/19/15.
//  Copyright (c) 2015 Chris Larkin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapUtilities {
    
    var distanceRequired: Bool = false
    var wineries = [NSManagedObject]()
    var restaurants = [NSManagedObject]()
    var hotels = [NSManagedObject]()
    var parking = [NSManagedObject]()
    
    var currentType = NSString()
    var currentPin = Int()
    
    @IBOutlet var mapView: MKMapView!
    
    func multiPinsMap() {
        //CoreData
        let dataManager = DataManager.sharedInstance
        
        wineries = dataManager.getWineries()
        
        restaurants = dataManager.getRestaurants()
        
        hotels = dataManager.getAccommodations()
        
        parking = dataManager.getParking()
        
    }
    func getWineries() -> [NSManagedObject] {
        return wineries
    }
    
    func pinTypeOnMap(type: String) -> [MKPointAnnotation]{
        
        switch(type) {
        case "winery":
            return placePinsOnMap(wineries, type: "winery")
        case "rest":
            return placePinsOnMap(restaurants, type: "rest")
        case "hotel":
            return placePinsOnMap(hotels, type: "hotel")
        case "park":
            return placePinsOnMap(parking, type: "park")
        default:
            print("error")
            
        }
        return placePinsOnMap(wineries, type: "winery")
    }
    
    func getDirections( theArray: [NSManagedObject], let start: CLLocationCoordinate2D) -> [MKRoute]{
        
        var myRoutes = [MKRoute]()
        
        for location in theArray {
            
            let sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
            
            let mypin = location.valueForKey("placemark") as! String
            
            var llarray = mypin.componentsSeparatedByString(",")
            
            let coord = CLLocationCoordinate2DMake(NSString(string: llarray[0]).doubleValue,NSString(string: llarray[1]).doubleValue)
            
            let destinationPlacemark:MKPlacemark = MKPlacemark(coordinate: coord, addressDictionary: nil)
            
            let directionRequest:MKDirectionsRequest = MKDirectionsRequest()
            
            
            directionRequest.source = MKMapItem(placemark: sourcePlacemark)
            
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            
            directionRequest.transportType = MKDirectionsTransportType.Automobile
            
            directionRequest.requestsAlternateRoutes = true
            
            let directions:MKDirections = MKDirections(request: directionRequest)
            
            directions.calculateDirectionsWithCompletionHandler ({
                (response: MKDirectionsResponse?, error: NSError?) in
                
                if error != nil{
                    
                    print(error)
                }
                else {
                    
                    let myroute = response!.routes[0]
                    
                    myRoutes.append(myroute)
                    
                    print(myroute.distance/1609.344)//meters convert to miles
                    
                    self.mapView.addOverlay(myroute.polyline, level: MKOverlayLevel.AboveRoads)
                }
                
            })
        }//end of for loop
        
        return myRoutes
    }

    func sortByDistance( var mapRoutes: [MKRoute]) {
        
        print(mapRoutes)
        
        for route in mapRoutes {
            print(route.distance)
        }
        
        mapRoutes.sortInPlace({$0.distance > $1.distance})
        
        for route in mapRoutes {
            print(route.distance)
        }
        
    }
    
    func viewForAnnotation(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let anView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        if(annotation.subtitle! == "winery") {
            anView.image = UIImage(named:"Wine_Icon")
        }
        else if(annotation.subtitle! == "rest") {
            anView.image = UIImage(named:"Food_Icon")
        }
        else if(annotation.subtitle! == "hotel") {
            anView.image = UIImage(named:"Hotel_Icon")
        }
        else if(annotation.subtitle! == "park") {
            anView.image = UIImage(named:"Car_Icon")
        }
        else if(annotation.subtitle! == "finish") {
            anView.image = UIImage(named: "flag_icon")
        }
        anView.canShowCallout = false
        
        return anView
    }
    
    func renderForOverlay(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        let pr = MKPolylineRenderer(overlay: overlay);
        
        pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7);
        
        pr.lineWidth = 4;
        
        return pr
    }
    
    func didSelectAnnotationView(view: MKAnnotationView!) -> NSManagedObject? {

        view.canShowCallout = false;

        let id = view.annotation
        if id!.isKindOfClass(MKUserLocation)
        {
            
            
            
            var temp = wineries[Int(view.annotation!.title!!)!]
            if(view.annotation!.subtitle! == "winery") {
                temp = wineries[Int(view.annotation!.title!!)!]
            }
            else if(view.annotation!.subtitle! == "rest") {
                temp = restaurants[Int(view.annotation!.title!!)!]
            }
            else if(view.annotation!.subtitle! == "hotel") {
                temp = hotels[Int(view.annotation!.title!!)!]
            }
            else if(view.annotation!.subtitle! == "park") {
                temp = parking[Int(view.annotation!.title!!)!]
            }
            self.currentPin = Int(view.annotation!.title!!)!
            self.currentType = view.annotation!.subtitle!!
            return temp
        }
        else{
           // view.annotation.title
            view.canShowCallout = false;
            return nil
        }
    }
        
    
    
    func placePinsOnMap(var array: [NSManagedObject], type: String) -> [MKPointAnnotation]{
        
        var pins = [MKPointAnnotation]()
        
        for var i = 0; i < array.count; i++
        {
            
            let temp = array[i]
            
            let information = MKPointAnnotation()
            
            let address:String = temp.valueForKey("address") as! String
            
            let city:String = temp.valueForKey("city") as! String
            
            if(temp.valueForKey("placemark") != nil) {
                
                let mypin: String = temp.valueForKey("placemark") as! String
                
                var llarray = mypin.componentsSeparatedByString(",")
                
                information.coordinate.latitude = NSString(string: llarray[0]).doubleValue
                
                information.coordinate.longitude = NSString(string: llarray[1]).doubleValue
            }
            else {
                
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString( "\(address), \(city), WA, USA", completionHandler: {(placemarks, error) -> Void in
                    
                    if let placeMarks = placemarks {
                        let pm = placeMarks[0] as CLPlacemark
                        
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        let managedContext = appDelegate.managedObjectContext
                        
                        let lat: String = "\(pm.location!.coordinate.latitude),"
                        
                        let long: String  = "\(pm.location!.coordinate.longitude)"
                        
                        information.coordinate.latitude = NSString(string: lat).doubleValue
                        
                        information.coordinate.longitude = NSString(string: long).doubleValue
                        
                        temp.setValue(lat+long, forKey: "placemark")
        
                        
                        do {
                            try managedContext.save()
                        } catch {
                            print("Could not save \(error)")
                        }
                    }
                    
                })
            }
            
            information.title = "\(i)"
            
            information.subtitle = type
            
            if(mapView != nil) {
                
                pins.append(information)
                
                mapView.addAnnotation(information)
            }
            
        }
        return pins
    }
    
}