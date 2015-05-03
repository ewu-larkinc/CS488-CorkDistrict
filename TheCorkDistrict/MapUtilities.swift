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
    
    @IBOutlet var mapView: MKMapView!
    
    func getDirections(var theArray: [NSManagedObject], let start: CLLocationCoordinate2D) -> [MKRoute]{
        
        var myRoutes = [MKRoute]()
        
        for location in theArray {
        
            var sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
            
            var mypin = location.valueForKey("placemark") as! String
            
            var llarray = mypin.componentsSeparatedByString(",")
            
            var coord = CLLocationCoordinate2DMake(NSString(string: llarray[0]).doubleValue,NSString(string: llarray[1]).doubleValue)
            
            var destinationPlacemark:MKPlacemark = MKPlacemark(coordinate: coord, addressDictionary: nil)

            var directionRequest:MKDirectionsRequest = MKDirectionsRequest()
            
            directionRequest.setSource(MKMapItem(placemark: sourcePlacemark))
            
            directionRequest.setDestination(MKMapItem(placemark: destinationPlacemark))
            
            directionRequest.transportType = MKDirectionsTransportType.Automobile
            
            directionRequest.requestsAlternateRoutes = true
            
            var directions:MKDirections = MKDirections(request: directionRequest)
            
            directions.calculateDirectionsWithCompletionHandler ({
                (response: MKDirectionsResponse?, error: NSError?) in
                
                if error != nil{
                    
                    println(error)
                }
                else {
                    
                    let myroute = response?.routes[0] as! MKRoute
                    
                    myRoutes.append(myroute)
                    
                    println(myroute.distance/1609.344)
                    
                    self.mapView.addOverlay(myroute.polyline, level: MKOverlayLevel.AboveRoads)
                }
                
            })
        }//end of for loop
        
        return myRoutes
    }
    
    func sortByDistance(var mapRoutes: [MKRoute]) {
        
        println(mapRoutes)
        
        for route in mapRoutes {
            println(route.distance)
        }
        
        mapRoutes.sort({$0.distance > $1.distance})
        
        for route in mapRoutes {
            println(route.distance)
        }
        
    }
    
    func placePinsOnMap(var array: [NSManagedObject], var type: String) -> [MKPointAnnotation]{
        
        var pins = [MKPointAnnotation]()
        
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
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        let managedContext = appDelegate.managedObjectContext!
                        
                        var lat: String = "\(placemark.location.coordinate.latitude),"
                        
                        var long: String  = "\(placemark.location.coordinate.longitude)"
                        
                        information.coordinate.latitude = NSString(string: lat).doubleValue
                        
                        information.coordinate.longitude = NSString(string: long).doubleValue
                        
                        temp.setValue(lat+long, forKey: "placemark")
                        
                        var error: NSError?
                        
                        if !managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
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