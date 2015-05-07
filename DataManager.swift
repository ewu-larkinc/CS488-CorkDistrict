//
//  DataManager.swift
//  CorkDistrict
//


import Foundation
import CoreData
import UIKit
import CoreLocation


private let _SingletonSharedInstance = DataManager()

enum Index: Int {
    case Name = 0
    case NodeID = 1
    case Address = 2
    case Zipcode = 3
    case City = 4
    case Phone = 5
}

class DataManager {

    class var sharedInstance: DataManager {
        return _SingletonSharedInstance
    }
    
    var dataReceived: Bool = false
    
    
    private let URL_NOTIFICATIONS = NSURL(string: "http://www.nathanpilgrim.net/apns/push_notifications")
    private let URL_CHANGELOG = NSURL(string: "http://www.nathanpilgrim.net/rest/all")
    
    private var wineries = CorkDistrictEntity()
    private var restaurants = CorkDistrictEntity()
    private var accommodations = CorkDistrictEntity()
    private var packages = CorkDistrictEntity()
    private var parking = CorkDistrictEntity()
    private var progress = Float()
    
    
    
    //#MARK: - Access Methods
    func getProgress() -> Float {
        return progress
    }
    
    func getWineries() -> [NSManagedObject] {
        return wineries.entities 
    }
    
    func getNotificationURL() -> NSURL {
        return URL_NOTIFICATIONS!
    }
    
    func getWineryIndex(title: String) -> Int {
        
        var i : Int
        
        for (i=0; i < wineries.entities.count; i++) {
            var tempTitle = wineries.entities[i].valueForKey("name") as! String
            println("current winery title is \(tempTitle)")
            
            if (title == tempTitle) {
                return i
            }
        }
        
        return -1
    }
    
    func getRestaurants() -> [NSManagedObject] {
        return restaurants.entities 
    }
    
    func getAccommodations() -> [NSManagedObject] {
        return accommodations.entities 
    }
    
    func getPackages() -> [NSManagedObject] {
        return packages.entities 
    }
    
    func getParking() -> [NSManagedObject] {
        return parking.entities 
    }
    
    func hasDownloadFinished() -> Bool {
        return packages.entities.count != 0
    }
    
    //#MARK: - Data Management Methods
    func loadData() -> Void {
        
        initializeEntityObjects()
        fetchAllEntitiesFromCoreData()
        
        if (!dataReceived) {
            fetchAllEntitiesFromWeb()
        }
        
        dataReceived = true
    }
    
    func initializeEntityObjects() {
        
        /*wineries.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/wineries.json")!
        wineries.type = "Winery"
        restaurants.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/restaurants.json")!
        restaurants.type = "Restaurant"
        packages.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/packages.json")!
        packages.type = "Package"
        parking.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/parking.json")!
        parking.type = "Parking"
        accommodations.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/accommodations.json")!
        accommodations.type = "Accommodation"*/
        
        wineries.URL = NSURL(string: "http://www.corkdistrictapp.com/rest/wineries.json")!
        wineries.type = "Winery"
        restaurants.URL = NSURL(string: "http://www.corkdistrictapp.com/rest/restaurants.json")!
        restaurants.type = "Restaurant"
        packages.URL = NSURL(string: "http://www.corkdistrictapp.com/rest/packages.json")!
        packages.type = "Package"
        parking.URL = NSURL(string: "http://www.corkdistrictapp.com/rest/parking.json")!
        parking.type = "Parking"
        accommodations.URL = NSURL(string: "http://www.corkdistrictapp.com/rest/lodging.json")!
        accommodations.type = "Accommodation"
    }
    
    //#MARK: - Core Data Methods
    func deleteFromCoreData(entity: CorkDistrictEntity) -> Void {
        
        entity.clearEntities()
        println("Deleting \(entity.type) from coreData")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let deletionFetchRequest = NSFetchRequest(entityName: entity.type)
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(deletionFetchRequest, error: &error) as! [NSManagedObject]
        
        var i = Int()
        for result in fetchedResults {
            managedContext.deleteObject(result)
        }
        
        var error2: NSError?
        if !managedContext.save(&error2) {
            println("Could not save \(error2), \(error2?.userInfo)")
        }
        
    }
    
    func fetchEntitiesFromCoreData(entity: CorkDistrictEntity) {
        
        println("fetching \(entity.type) from coreData")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext! 
        
        let fetchRequest = NSFetchRequest(entityName: entity.type)
        
        var error: NSError? 
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]? 
        
        entity.entities = fetchedResults!
    }
    
    func fetchAllEntitiesFromCoreData() {
        fetchEntitiesFromCoreData(wineries)
        fetchEntitiesFromCoreData(restaurants)
        fetchEntitiesFromCoreData(packages)
        fetchEntitiesFromCoreData(accommodations)
        fetchEntitiesFromCoreData(parking)
    }
    
    func addEntityToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext! 
        var entityType = entityInfo[6] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as! NSManagedObject 
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData") 
        newEntity.setValue(entityInfo[Index.Name.rawValue], forKey: "name")
        newEntity.setValue(entityInfo[Index.NodeID.rawValue], forKey: "nodeID")
        newEntity.setValue(entityInfo[Index.Address.rawValue], forKey: "address")
        newEntity.setValue(entityInfo[Index.Zipcode.rawValue], forKey: "zipcode")
        newEntity.setValue(entityInfo[Index.City.rawValue], forKey: "city")
        newEntity.setValue(entityInfo[Index.Phone.rawValue], forKey: "phone")
        
        if (entityType != parking.type) {
            newEntity.setValue(entityInfo[7], forKey: "about")
            newEntity.setValue(entityInfo[8], forKey: "website")
            
            if (entityType == wineries.type) {
                newEntity.setValue(entityInfo[9], forKey: "cluster")
            }
        }
        
        
        var geocoder = CLGeocoder() 
        geocoder.geocodeAddressString( "\(entityInfo[1]), \(entityInfo[3]), WA, USA", completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0]  as? CLPlacemark
            {
        
                if let placemark = placemarks?[0]  as? CLPlacemark {
                    var latlong: String = "\(placemark.location.coordinate.latitude)," 
                    latlong += "\(placemark.location.coordinate.longitude)" 
        
                    var coord : CLLocationCoordinate2D
                    newEntity.setValue(latlong, forKey: "placemark") 
                }
        
        }
        })
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        switch (entityType) {
            
        case "Winery":
            self.wineries.entities.append(newEntity)
        case "Restaurant":
            self.restaurants.entities.append(newEntity)
        case "Accommodation":
            self.accommodations.entities.append(newEntity)
        case "Package":
            self.packages.entities.append(newEntity)
        default:
            println("Invalid entity type")
            
        }
    }
    
    func addParkingToCoreData(entityInfo: NSMutableArray) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entityType = entityInfo[6] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as! NSManagedObject
        
        newEntity.setValue(entityInfo[Index.Name.rawValue], forKey: "name")
        newEntity.setValue(entityInfo[Index.NodeID.rawValue], forKey: "nodeID")
        newEntity.setValue(entityInfo[Index.Address.rawValue], forKey: "address")
        newEntity.setValue(entityInfo[Index.Zipcode.rawValue], forKey: "zipcode")
        newEntity.setValue(entityInfo[Index.City.rawValue], forKey: "city")
        newEntity.setValue(entityInfo[Index.Phone.rawValue], forKey: "phone")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        parking.entities.append(newEntity)
        
    }
    
    func addPackageToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entityType = entityInfo[11] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as! NSManagedObject
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData")
        newEntity.setValue(entityInfo[0], forKey: "name")
        newEntity.setValue(entityInfo[1], forKey: "about")
        newEntity.setValue(entityInfo[2], forKey: "website")
        newEntity.setValue(entityInfo[3], forKey: "cost")
        newEntity.setValue(entityInfo[4], forKey: "startDay")
        newEntity.setValue(entityInfo[5], forKey: "startMonth")
        newEntity.setValue(entityInfo[6], forKey: "endDay")
        newEntity.setValue(entityInfo[7], forKey: "endMonth")
        newEntity.setValue(entityInfo[8], forKey: "startYear")
        newEntity.setValue(entityInfo[9], forKey: "endYear")
        newEntity.setValue(entityInfo[10], forKey: "relatedNodeID")
        
        let relatedNodeID = entityInfo[10] as! String
        //println("searching for relatedEntityTitle: \(relatedNodeID)")
        /*var index : Int = 0
        index = getWineryIndex(relatedTitle)
        let wineries.entities = getWineries()
        
        println("index is \(index)")
        
        let relatedEntity = wineries.entities[index]
        
        
        if (index >= 0) {
            newEntity.setValue(relatedEntity.valueForKey("address"), forKey: "relatedEntityAddress")
            newEntity.setValue(relatedEntity.valueForKey("city"), forKey: "relatedEntityCity")
            newEntity.setValue(relatedEntity.valueForKey("zipcode"), forKey: "relatedEntityZipcode")
            newEntity.setValue(relatedEntity.valueForKey("address"), forKey: "relatedEntityPhone")
        }*/
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        packages.entities.append(newEntity)
    }
    
    //#MARK: - NSURLSession Methods
    func fetchAllEntitiesFromWeb() {
        fetchEntitiesFromWeb(wineries)
        fetchEntitiesFromWeb(restaurants)
        fetchEntitiesFromWeb(packages)
        fetchEntitiesFromWeb(parking)
        fetchEntitiesFromWeb(accommodations)
    }
    
    func fetchEntitiesFromWeb(entity: CorkDistrictEntity) -> Void {
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(entity.URL) {
            (data, response, error) -> Void in
            
            if error != nil {
                println(error.localizedDescription)
            } else {
                self.parseJSONEntity(data, entity: entity)
            }
        }
        
        task.resume()
    }
    
    //#MARK: - JSON Methods
    func parseJSONEntity(data: NSData, entity: CorkDistrictEntity) -> Void {
        
        if (entity.type == packages.type) {
            parseJSONPackage(data, entity: entity)
            
        } else {
            
            let json = JSON(data: data)
            println("\(entity.type) webCount: \(json.count) cdCount: \(entity.entities.count)")
            if (json.count != entity.entities.count) {
                println("Downloading \(entity.type)...")
                deleteFromCoreData(entity)
                var ctr=0
            
                while (ctr < json.count) {
                
                    let entityCityStateZip = json[ctr]["City State Zip"].stringValue
                    let cityStateZipArray = separateCityStateZip(entityCityStateZip)
                
                    let entityCity = cityStateZipArray[0]
                    let entityState = cityStateZipArray[1]
                    let entityZip = cityStateZipArray[2]
                
                    var infoArray = NSMutableArray()
                    infoArray.addObject(json[ctr]["node_title"].stringValue)
                    infoArray.addObject(json[ctr]["nid"].stringValue)
                    infoArray.addObject(json[ctr]["Street Address"].stringValue)
                    infoArray.addObject(entityZip)
                    infoArray.addObject(entityCity)
                    infoArray.addObject(json[ctr]["Phone"].stringValue)
                    infoArray.addObject(entity.type)
                
                    println("testing")
                    println(json[ctr]["node_title"].stringValue)
                
                
                    if (entity.type != parking.type) {
                    
                        let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
                        let entityImageUrl = NSURL(string: entityImageString)
                        let imgData = NSData(contentsOfURL: entityImageUrl!)
                        let entityImage = UIImage(data: imgData!)
                    
                        infoArray.addObject(json[ctr]["Description"].stringValue)
                        infoArray.addObject(json[ctr]["Website"].stringValue)
                    
                        if (entity.type == wineries.type) {
                            infoArray.addObject(json[ctr]["Cluster"].stringValue)
                    }
                    
                    addEntityToCoreData(infoArray, entityImage: entityImage!)
                    } else {
                        addParkingToCoreData(infoArray)
                    }
                
                    ctr++
                }
            }
            
        }
        
    }
    
    func parseJSONPackage(data: NSData, entity: CorkDistrictEntity) -> Void {
        
        let json = JSON(data: data)
        println("\(entity.type) webCount: \(json.count) cdCount: \(entity.entities.count)")
        
        if (json.count != entity.entities.count) {
            println("Downloading \(entity.type)...")
            deleteFromCoreData(entity)
            var ctr=0
            var infoArray = NSMutableArray()
        
            while (ctr < json.count) {
            
                infoArray.addObject(json[ctr]["node_title"].stringValue)
                infoArray.addObject(json[ctr]["Description"].stringValue)
                infoArray.addObject(json[ctr]["Website"].stringValue)
                infoArray.addObject(json[ctr]["Cost"].stringValue)
                infoArray.addObject(json[ctr]["StartDay"].stringValue)
                infoArray.addObject(json[ctr]["StartMonth"].stringValue)
                infoArray.addObject(json[ctr]["EndDay"].stringValue)
                infoArray.addObject(json[ctr]["EndMonth"].stringValue)
                infoArray.addObject(json[ctr]["StartYear"].stringValue)
                infoArray.addObject(json[ctr]["EndYear"].stringValue)
                infoArray.addObject(json[ctr]["nid"].stringValue)
                infoArray.addObject(entity.type)
            
                println("testing in parseJSONPackages...")
                println("incoming title is \(infoArray[0])")
                println("incoming cost is \(infoArray[3])")
            
                var temp2 = json[ctr]["RelatedEntityTitle"]["item"]["target_id"].stringValue
            
                println("incoming related entity nid is \(temp2)")
                var temp = json[ctr]["Thumbnail"].stringValue
                println("thumbnail string value is \(temp)")
            
                let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
                let entityImageUrl = NSURL(string: entityImageString)
                let imgData = NSData(contentsOfURL: entityImageUrl!)
                let entityImage = UIImage(data: imgData!)
            
                addPackageToCoreData(infoArray, entityImage: entityImage!)
                ctr++
            }
        }
        
    }
    
    
    //#MARK: - Misc. Methods
    func stripHtml(urlObject: String) -> String {
        
        //println("testing... entitiyImageString is \(urlObject)")
        let entityImageStringArray = urlObject.componentsSeparatedByString(" ")
        var entityImageString = entityImageStringArray[2].stringByReplacingOccurrencesOfString("src=\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return entityImageString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func separateCityStateZip(cityStateZip: String) -> [String] {
        
        //println("Testing... cityStateZip is \(cityStateZip)")
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
    
    
}
