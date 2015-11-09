//
//  MapViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/24/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum MapType: Int {
    case Standard = 0
    case Hybrid = 1
    case Satellite = 2
}

enum EntityType: Int {
    case Accommodation = 0
    case Parking
    case Restaurant
    case Winery
    case All
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var accommodationButton: UIButton!
    @IBOutlet weak var parkingButton: UIButton!
    @IBOutlet weak var wineButton: UIButton!
    
    
    
    @IBAction func restaurantBtnSelected(sender: AnyObject) {
        
        if btnSelected[EntityType.Restaurant.rawValue] {
            btnSelected[EntityType.Restaurant.rawValue] = false
            restaurantButton.alpha = 0.4
            
            for annot in mapView.annotations {
                if annot is RestaurantAnnotation {
                    mapView.removeAnnotation(annot)
                }
            }
            
        } else {
            btnSelected[EntityType.Restaurant.rawValue] = true
            addCorkDistrictPinsOfType(EntityType.Restaurant)
            restaurantButton.alpha = 1
            restaurantButton.setNeedsDisplay()
        }
    }
    
    @IBAction func accommodationBtnSelected(sender: AnyObject) {
        if btnSelected[EntityType.Accommodation.rawValue] {
            btnSelected[EntityType.Accommodation.rawValue] = false
            accommodationButton.alpha = 0.4
            
            for annot in mapView.annotations {
                if annot is AccommodationAnnotation {
                    mapView.removeAnnotation(annot)
                }
            }
            
        } else {
            btnSelected[EntityType.Accommodation.rawValue] = true
            addCorkDistrictPinsOfType(EntityType.Accommodation)
            accommodationButton.alpha = 1
            accommodationButton.setNeedsDisplay()
        }
    }
    
    @IBAction func parkingBtnSelected(sender: AnyObject) {
        if btnSelected[EntityType.Parking.rawValue] {
            btnSelected[EntityType.Parking.rawValue] = false
            parkingButton.alpha = 0.4
            
            for annot in mapView.annotations {
                if annot is ParkingAnnotation {
                    mapView.removeAnnotation(annot)
                }
            }
            
        } else {
            btnSelected[EntityType.Parking.rawValue] = true
            addCorkDistrictPinsOfType(EntityType.Parking)
            parkingButton.alpha = 1
            parkingButton.setNeedsDisplay()
        }
    }
    
    /*func toggleAnnotationViews(button: UIButton, type: EntityType) {
        
        if btnSelected[type.rawValue] {
            btnSelected[type.rawValue] = false
            button.alpha = 0.4
            
            for annot in mapView.annotations {
                if annot is ParkingAnnotation {
                    mapView.removeAnnotation(annot)
                }
            }
            
        } else {
            btnSelected[EntityType.Parking.rawValue] = true
            addCorkDistrictPinsOfType(EntityType.Parking)
            parkingButton.alpha = 1
            parkingButton.setNeedsDisplay()
        }
    }*/
    
    @IBAction func wineryBtnSelected(sender: AnyObject) {
        if btnSelected[EntityType.Winery.rawValue] {
            btnSelected[EntityType.Winery.rawValue] = false
            wineButton.alpha = 0.4
            
            for annot in mapView.annotations {
                if annot is WineryAnnotation {
                    mapView.removeAnnotation(annot)
                }
            }
            
        } else {
            btnSelected[EntityType.Winery.rawValue] = true
            addCorkDistrictPinsOfType(EntityType.Winery)
            wineButton.alpha = 1
            wineButton.setNeedsDisplay()
        }
    }
    
    @IBAction func mapTypeChanged(sender: AnyObject) {
        
        let mapType = MapType(rawValue: mapTypeSegmentedControl.selectedSegmentIndex)
        
        switch(mapType!) {
        
            case .Standard:
                mapView.mapType = MKMapType.Standard
            case .Hybrid:
                mapView.mapType = MKMapType.Hybrid
            case .Satellite:
                mapView.mapType = MKMapType.Satellite
        }
    }
    
    private var entities = [CorkDistrictEntity]()
    private var btnSelected = [Bool]()
    private var selectedEntity: CorkDistrictEntity?
    

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareButtonLayout()
        
        
        let data = CorkDistrictData.sharedInstance
        entities = data.getAllEntities()
        
        
        if let coordinates = data.getMapCoordinates() {
            mapView.setCenterCoordinate(coordinates, animated: true)
            
            let center = MKMapPointForCoordinate(coordinates)
            let size = MKMapSize(width: 5000, height: 5000)
            
            let area = MKMapRect(origin: center, size: size)
            mapView.setVisibleMapRect(area, animated: true)
        }
        
        addCorkDistrictPinsOfType(EntityType.All)
    }
    
    func prepareButtonLayout() {
        
        wineButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        wineButton.layer.shadowOpacity = 0.7
        wineButton.layer.shadowRadius = 1
        
        restaurantButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        restaurantButton.layer.shadowOpacity = 0.7
        restaurantButton.layer.shadowRadius = 1
        
        accommodationButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        accommodationButton.layer.shadowOpacity = 0.7
        accommodationButton.layer.shadowRadius = 1
        
        parkingButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        parkingButton.layer.shadowOpacity = 0.7
        parkingButton.layer.shadowRadius = 1
        
        btnSelected.append(true)
        btnSelected.append(true)
        btnSelected.append(true)
        btnSelected.append(true)
    }
    
    func removeAnnotations() {
        let toDelete = mapView.annotations
        mapView.removeAnnotations(toDelete)
        mapView.reloadInputViews()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let sub = annotation.subtitle {
            if let subtitle = sub {
                
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "CorkDistrictAnnotationView")
                
                switch (subtitle) {
                case "Accommodation":
                    view.image = UIImage(named: "accommodationIcon")
                case "Parking":
                    view.image = UIImage(named: "parkingIcon")
                case "Restaurant":
                    view.image = UIImage(named: "restaurantIcon")
                case "Winery":
                    view.image = UIImage(named: "wineryIcon")
                default:
                    break
                }
                
                return view
            }
        }
        
        return nil
    }
    
    
    func getEntityByTitle(title: String) -> CorkDistrictEntity? {
        
        for entity in entities {
            
            if entity.title == title {
                return entity
            }
        }
        
        return nil
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            if let t = annotation.title, s = annotation.subtitle {
                if let title = t, subtitle = s {
                    
                    let alertView = UIAlertController(title: title, message: subtitle, preferredStyle: .Alert)
                    
                    let callAction = UIAlertAction(title: "Call", style: .Default) {
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
                    }
                    
                    
                    let detailAction = UIAlertAction(title: "Details", style: .Default) {
                        action in
                        
                        let data = CorkDistrictData.sharedInstance
                        data.setSelectedEntityByTitle(title)
                        self.performSegueWithIdentifier("mapToDetailSegue", sender: self)
                    }
                    
                    let routeAction = UIAlertAction(title: "Directions", style: .Default) {
                        action in
                        
                        self.performSegueWithIdentifier("mapToRoutingSegue", sender: self)
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
                        action in
                        
                    }
                    
                    
                    alertView.addAction(callAction)
                    if(view.annotation!.subtitle! != "park") {
                        alertView.addAction(detailAction)
                    }
                    alertView.addAction(cancelAction)
                    alertView.addAction(routeAction)
                    
                    
                    
                    
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    func addCorkDistrictPinsOfType(type: EntityType) {
        
        let data = CorkDistrictData.sharedInstance
        
        switch (type) {
            
            case .Accommodation:
                addPins(data.getAccommodations())
            case .Parking:
                addPins(data.getParking())
            case .Restaurant:
                addPins(data.getRestaurants())
            case .Winery:
                addPins(data.getWineries())
            case .All:
                addPins(entities)
        }
    }
    
    
    
    func addPins(entities: [CorkDistrictEntity]) {
        
        for entity in entities {
            
            if let coordinate = entity.coordinate {
                
                var annotation: CorkDistrictAnnotation
                
                print("Current entity type is \(entity.typePlural)")
                
                switch (entity.type) {
                    
                    case .Accommodation:
                        annotation = AccommodationAnnotation(title: entity.title, coordinate: coordinate, phone: entity.phone)
                    case .Parking:
                        annotation = ParkingAnnotation(title: entity.title, coordinate: coordinate, phone: entity.phone)
                    case .Restaurant:
                        annotation = RestaurantAnnotation(title: entity.title, coordinate: coordinate, phone: entity.phone)
                    default:
                        annotation = WineryAnnotation(title: entity.title, coordinate: coordinate, phone: entity.phone)
                    
                }
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
}
