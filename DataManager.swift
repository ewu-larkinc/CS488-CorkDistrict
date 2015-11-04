//
//  DataSingleton.swift
//  CorkDistrict
//


import Foundation
import CoreData
import UIKit
import CoreLocation

private let _SingletonSharedInstance = DataManager()

class DataManager {
    
    class var sharedInstance: DataManager {
        return _SingletonSharedInstance
    }
    
    let ENTITY_URL_WINERY = NSURL(string: "http://www.nathanpilgrim.net/rest/wineries.json")
    let ENTITY_URL_RESTAURANT = NSURL(string: "http://www.nathanpilgrim.net/rest/restaurants.json")
    let ENTITY_URL_ACCOMMODATION = NSURL(string: "http://www.nathanpilgrim.net/rest/accommodations.json")
    let ENTITY_URL_PACKAGE = NSURL(string: "http://www.nathanpilgrim.net/rest/packages.json")
    let ENTITY_TYPE_WINERY : String = "Winery"
    let ENTITY_TYPE_RESTAURANT : String = "Restaurant"
    let ENTITY_TYPE_ACCOMMODATION : String = "Accommodation"
    let ENTITY_TYPE_PACKAGE : String = "Package"
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var wineries = [NSManagedObject]()
    var restaurants = [NSManagedObject]()
    var accommodations = [NSManagedObject]()
    var packages = [NSManagedObject]()
    
    
    func loadData() -> Void {
        
        
        
        if let wineryResults = fetchEntity(ENTITY_TYPE_WINERY) {
            wineries = wineryResults
            
            if (wineries.count == 0) {
                pullJSONEntities(ENTITY_URL_WINERY!, entityType: ENTITY_TYPE_WINERY)
            }
        }
        
        //deleteAllEntitiesOfType(ENTITY_TYPE_WINERY)
        
        
        
        if let restaurantResults = fetchEntity(ENTITY_TYPE_RESTAURANT) {
            restaurants = restaurantResults
            
            if (restaurants.count == 0) {
                pullJSONEntities(ENTITY_URL_RESTAURANT!, entityType: ENTITY_TYPE_RESTAURANT)
            }
        }
        
        /*if let accommodationResults = fetchEntity(ENTITY_TYPE_ACCOMMODATION) {
            accommodations = accommodationResults
            
            if (accommodations.count == 0) {
                pullJSONEntities(ENTITY_URL_ACCOMMODATION!, entityType: ENTITY_TYPE_ACCOMMODATION)
            }
        }
        
        if let packageResults = fetchEntity(ENTITY_TYPE_PACKAGE) {
            packages = packageResults
            
            if (packages.count == 0) {
                pullJSONEntities(ENTITY_URL_PACKAGE!, entityType: ENTITY_TYPE_RESTAURANT)
            }
        }*/
    }
    
    func fetchEntity(entityType: String) -> [NSManagedObject]? {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entityType)
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        return fetchedResults
    }
    
    
    
    
    func pullJSONEntities(entityURL: NSURL, entityType: String) -> Void {
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(entityURL) {
            (data, response, error) -> Void in
            
                if error != nil {
                    println(error.localizedDescription)
                } else {
                    self.parseJSONEntity(data, entityType: entityType)
                }
        }
        
        task.resume()
    }
    
    

    func parseJSONEntity(data: NSData, entityType: String) -> Void {
    
        let json = JSON(data: data)
        var ctr=0
        while (ctr < json.count) {
            
            let entityCityStateZip = json[ctr]["City State Zip"].stringValue
            let cityStateZipArray = entityCityStateZip.componentsSeparatedByString(" ")
            
            var entityCity: String
            var entityState: String
            var entityZip: String
            
            if (cityStateZipArray.count > 3) {
                entityCity = cityStateZipArray[0] + " " + cityStateZipArray[1]
                entityState = cityStateZipArray[2]
                entityZip = cityStateZipArray[3]
            } else {
                entityCity = cityStateZipArray[0]
                entityState = cityStateZipArray[1]
                entityZip = cityStateZipArray[2]
            }
            entityCity = entityCity.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            
            let infoArray = NSMutableArray()
            infoArray.addObject(json[ctr]["node_title"].stringValue)
            infoArray.addObject(json[ctr]["Street Address"].stringValue)
            infoArray.addObject(entityZip)
            infoArray.addObject(entityCity)
            infoArray.addObject(json[ctr]["Phone"].stringValue)
            infoArray.addObject(json[ctr]["Description"].stringValue)
            infoArray.addObject(entityType)
       
            var entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
            //entityImageString = stripHtml(entityImageString)
            
            let entityImageUrl = NSURL(string: entityImageString)
            let imgData = NSData(contentsOfURL: entityImageUrl!)
            let entityImage = UIImage(data: imgData!)
            addEntity(infoArray, entityImage: entityImage!)
            
            ctr++
        }
    }
    
    func stripHtml(urlObject: String) -> String {
        
        let entityImageStringArray = urlObject.componentsSeparatedByString(" ")
        var entityImageString = entityImageStringArray[2].stringByReplacingOccurrencesOfString("src=\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        entityImageString = entityImageString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return entityImageString
    }
    
    func addEntity(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var entityType = entityInfo[6] as NSString
        println("Current entity type (in addEntity) is: \(entityType)")
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as NSManagedObject
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData")
        newEntity.setValue(entityInfo[0], forKey: "name")
        newEntity.setValue(entityInfo[1], forKey: "address")
        newEntity.setValue(entityInfo[2], forKey: "zipcode")
        newEntity.setValue(entityInfo[3], forKey: "city")
        newEntity.setValue(entityInfo[4], forKey: "phone")
        newEntity.setValue(entityInfo[5], forKey: "about")
        
        var address = entityInfo[1] as NSString
        var city = entityInfo[3] as NSString
        
        let fullAddress = address + ", " + city + ", USA"
        
        
        geocoder.geocodeAddressString(fullAddress, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                newEntity.setValue(placemark, forKey: "placemark")
            }
        })
        
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        wineries.append(newEntity)
        
    }
    
    func deleteAllEntitiesOfType(entityType: String) -> Void {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var ctr = 0
        
        if (entityType == "Winery"){
            while (ctr < wineries.count) {
                managedContext.deleteObject(wineries[ctr])
                ctr++
            }
            wineries = [NSManagedObject]()
        } else if (entityType == "Restaurant") {
            while (ctr < restaurants.count) {
                managedContext.deleteObject(restaurants[ctr])
                ctr++
            }
            restaurants = [NSManagedObject]()
        } else if (entityType == "Accommodation") {
            while (ctr < accommodations.count) {
                managedContext.deleteObject(accommodations[ctr])
                ctr++
            }
            accommodations = [NSManagedObject]()
        } else if (entityType == "Package") {
            while (ctr < packages.count) {
                managedContext.deleteObject(packages[ctr])
                ctr++
            }
            packages = [NSManagedObject]()
        }
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func getWineries() -> [NSManagedObject] {
        return wineries
    }
    
    func getRestaurants() -> [NSManagedObject] {
        return restaurants
    }
    
    func getAccommodations() -> [NSManagedObject] {
        return accommodations
    }
    
    
    
}
