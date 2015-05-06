//
//  MapUtilities.swift
//  TheCorkDistrict
//
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapUtilities {
    
    var pins = [MKPointAnnotation]()
    var myRoutes = [MKRoute]()
    var distanceRequired: Bool = false
    @IBOutlet var mapView: MKMapView!
    
    func getDirections(var theArray: [NSManagedObject], let start: CLLocationCoordinate2D) {
        
        for location in theArray {
      
            
     //   var mypin: String = start.valueForKey("placemark") as! String
     //   var llarray = mypin.componentsSeparatedByString(",")
        //var coord = CLLocationCoordinate2DMake(NSString(string: llarray[0]).doubleValue,NSString(string: llarray[1]).doubleValue)
        
        var sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: start, addressDictionary: nil)
         
            
        println(location.valueForKey("placemark") as! String)
        
        var mypin = location.valueForKey("placemark") as! String
        var llarray = mypin.componentsSeparatedByString(",")
        var coord = CLLocationCoordinate2DMake(NSString(string: llarray[0]).doubleValue,NSString(string: llarray[1]).doubleValue)
        
        var destinationPlacemark:MKPlacemark = MKPlacemark(coordinate: coord, addressDictionary: nil)
        
        var source:MKMapItem = MKMapItem(placemark: sourcePlacemark)
        var destination:MKMapItem = MKMapItem(placemark: destinationPlacemark)
        var directionRequest:MKDirectionsRequest = MKDirectionsRequest()
        
        directionRequest.setSource(source)
        directionRequest.setDestination(destination)
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
                self.mapView.addOverlay(myroute.polyline, level: MKOverlayLevel.AboveRoads)
                
            }
            
        })
        }//for loop
    }
    
    func sortByDistance() {

        
        for route in myRoutes {
            println(route.distance)
        }
        
        myRoutes.sort({$0.distance > $1.distance})
        
        for route in myRoutes {
            println(route.distance)
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
                        //newEntity.setValue(latlong, forKey: "placemark")
                    }
                    
                })
            }
            
            information.title = "\(i)"
            information.subtitle = type
            
            pins.append(information)
            
            mapView.addAnnotation(information)
        }
        
    }
    
}