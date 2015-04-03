//
//  DataManager.swift
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
    
    var dataReceived: Bool = false
    var wineries = [NSManagedObject]()
    var restaurants = [NSManagedObject]()
    var accommodations = [NSManagedObject]()
    var packages = [NSManagedObject]()
    var parking = [NSManagedObject]()
    
    let ENTITY_URL_WINERY = NSURL(string: "http://www.nathanpilgrim.net/rest/wineries.json")
    let ENTITY_URL_RESTAURANT = NSURL(string: "http://www.nathanpilgrim.net/rest/restaurants.json")
    let ENTITY_URL_ACCOMMODATION = NSURL(string: "http://www.nathanpilgrim.net/rest/lodging.json")
    let ENTITY_URL_PACKAGE = NSURL(string: "http://www.nathanpilgrim.net/rest/packages.json")
    let ENTITY_URL_PARKING = NSURL(string: "http://www.nathanpilgrim.net/rest/parking.json")
    let ENTITY_TYPE_WINERY : String = "Winery"
    let ENTITY_TYPE_RESTAURANT : String = "Restaurant"
    let ENTITY_TYPE_ACCOMMODATION : String = "Accommodation"
    let ENTITY_TYPE_PACKAGE : String = "Package"
    let ENTITY_TYPE_PARKING : String = "Parking"
    
    
    
    
    func loadData() -> Void {
        
        if (!dataReceived) {
            
            wineries = retrieveEntities(ENTITY_TYPE_WINERY, entityURL: ENTITY_URL_WINERY!)
            restaurants = retrieveEntities(ENTITY_TYPE_RESTAURANT, entityURL: ENTITY_URL_RESTAURANT!)
            accommodations = retrieveEntities(ENTITY_TYPE_ACCOMMODATION, entityURL: ENTITY_URL_ACCOMMODATION!)
            packages = retrieveEntities(ENTITY_TYPE_PACKAGE, entityURL: ENTITY_URL_PACKAGE!)
            parking = retrieveEntities(ENTITY_TYPE_PARKING, entityURL: ENTITY_URL_PARKING!)
        }
        
        dataReceived = true
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
    
    func getPackages() -> [NSManagedObject] {
        return packages
    }
    
    func getParking() -> [NSManagedObject] {
        return parking
    }
    
    //#MARK: - Core Data Methods
    func retrieveEntities(entityType: String, entityURL: NSURL) -> [NSManagedObject] {
        
        var entities = [NSManagedObject]()
        
        if let results = fetchEntitiesFromCoreData(entityType) {
            entities = results
            
            if (entities.count == 0) {
                fetchEntitiesFromWeb(entityURL, entityType: entityType)
            }
        }
        
        return entities
    }
    
    func fetchEntitiesFromCoreData(entityType: String) -> [NSManagedObject]? {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entityType)
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        return fetchedResults
    }
    
    func addEntity(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entityType = entityInfo[5] as String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as NSManagedObject
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData")
        newEntity.setValue(entityInfo[0], forKey: "name")
        newEntity.setValue(entityInfo[1], forKey: "address")
        newEntity.setValue(entityInfo[2], forKey: "zipcode")
        newEntity.setValue(entityInfo[3], forKey: "city")
        newEntity.setValue(entityInfo[4], forKey: "phone")
        
        if (entityType != ENTITY_TYPE_PARKING) {
            newEntity.setValue(entityInfo[6], forKey: "about")
            newEntity.setValue(entityInfo[7], forKey: "website")
        }
        
        
        /*var geocoder = CLGeocoder()
        geocoder.geocodeAddressString( "\(entityInfo[1]), \(entityInfo[3]), WA, USA", {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0]  as? CLPlacemark
            {
                var latlong: String = "\(placemark.location.coordinate.latitude),"
                latlong += "\(placemark.location.coordinate.longitude)"
                
                newEntity.setValue(latlong, forKey: "placemark")
            }
            
        })*/
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        switch (entityType) {
            
            case "Winery":
                wineries.append(newEntity)
            case "Restaurant":
                restaurants.append(newEntity)
            case "Accommodation":
                accommodations.append(newEntity)
            case "Package":
                packages.append(newEntity)
            case "Parking":
                parking.append(newEntity)
            default:
                println("Invalid entity type")
            
        }
    }
    
    func addParking(entityInfo: NSMutableArray) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entityType = entityInfo[5] as String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as NSManagedObject
        
        newEntity.setValue(entityInfo[0], forKey: "name")
        newEntity.setValue(entityInfo[1], forKey: "address")
        newEntity.setValue(entityInfo[2], forKey: "zipcode")
        newEntity.setValue(entityInfo[3], forKey: "city")
        newEntity.setValue(entityInfo[4], forKey: "phone")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        parking.append(newEntity)
        
    }
    
    //#MARK: - Data Task Methods
    func fetchEntitiesFromWeb(entityURL: NSURL, entityType: String) -> Void {
        
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
    
    
    func separateCityStateZip(cityStateZip: String) -> [String] {
        
        let cityStateZipArray = cityStateZip.componentsSeparatedByString(" ")
        var resultArray = [String]()
        
        //0-city, 1-state, 2-zip
        if (cityStateZipArray.count > 3) {
            resultArray.append(cityStateZipArray[0] + " " + cityStateZipArray[1])
            resultArray.append(cityStateZipArray[2])
            resultArray.append(cityStateZipArray[3])
        } else {//0,1-city, 2-state, 3-zip
            resultArray.append(cityStateZipArray[0])
            resultArray.append(cityStateZipArray[1])
            resultArray.append(cityStateZipArray[2])
        }
        
        resultArray[0] = resultArray[0].stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
     
        return resultArray
    }
    
    
    //#MARK: - SwiftyJSON methods
    func parseJSONEntity(data: NSData, entityType: String) -> Void {
        
        let json = JSON(data: data)
        var ctr=0
        while (ctr < json.count) {
            
            let entityCityStateZip = json[ctr]["City State Zip"].stringValue
            let cityStateZipArray = separateCityStateZip(entityCityStateZip)
            
            let entityCity = cityStateZipArray[0]
            let entityState = cityStateZipArray[1]
            let entityZip = cityStateZipArray[2]
            
            var infoArray = NSMutableArray()
            infoArray.addObject(json[ctr]["node_title"].stringValue)
            infoArray.addObject(json[ctr]["Street Address"].stringValue)
            infoArray.addObject(entityZip)
            infoArray.addObject(entityCity)
            infoArray.addObject(json[ctr]["Phone"].stringValue)
            infoArray.addObject(entityType)
            
            if (entityType != ENTITY_TYPE_PARKING) {
                
                let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
                let entityImageUrl = NSURL(string: entityImageString)
                let imgData = NSData(contentsOfURL: entityImageUrl!)
                let entityImage = UIImage(data: imgData!)
                
                infoArray.addObject(json[ctr]["Description"].stringValue)
                infoArray.addObject(json[ctr]["Website"].stringValue)
                addEntity(infoArray, entityImage: entityImage!)
            } else {
                addParking(infoArray)
            }
            
            ctr++
        }
    }
    
    
    //#MARK: - Miscellaneous
    func stripHtml(urlObject: String) -> String {
        
        let entityImageStringArray = urlObject.componentsSeparatedByString(" ")
        var entityImageString = entityImageStringArray[2].stringByReplacingOccurrencesOfString("src=\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return entityImageString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    
}
