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
    private let URL_NOTIFICATIONS = NSURL(string: "http://www.nathanpilgrim.net/apns/push_notifications")
    private let URL_CHANGELOG = NSURL(string: "http://www.nathanpilgrim.net/rest/all")
    
    //TESTING
    private var thewineries = CorkDistrictEntity()
    private var therestaurants = CorkDistrictEntity()
    private var theaccommodations = CorkDistrictEntity()
    private var thepackages = CorkDistrictEntity()
    private var theparking = CorkDistrictEntity()
    private var progress = Float()
    private var taskNumber = Int(0)
    //END TESTING
    
    
    
    
    //#MARK: - Access Methods
    func getProgress() -> Float {
        return progress
    }
    
    func getWineries() -> [NSManagedObject] {
        return thewineries.entities 
    }
    
    func getNotificationURL() -> NSURL {
        return URL_NOTIFICATIONS!
    }
    
    func getWineryIndex(title: String) -> Int {
        
        var i : Int
        
        for (i=0; i < thewineries.entities.count; i++) {
            var tempTitle = thewineries.entities[i].valueForKey("name") as! String
            println("current winery title is \(tempTitle)")
            
            if (title == tempTitle) {
                return i
            }
        }
        
        return -1
    }
    
    func getRestaurants() -> [NSManagedObject] {
        return therestaurants.entities 
    }
    
    func getAccommodations() -> [NSManagedObject] {
        return theaccommodations.entities 
    }
    
    func getPackages() -> [NSManagedObject] {
        return thepackages.entities 
    }
    
    func getParking() -> [NSManagedObject] {
        return theparking.entities 
    }
    
    func hasDownloadFinished() -> Bool {
        return thepackages.entities.count != 0
    }
    
    //#MARK: - Data Management Methods
    func loadData() -> Void {
        
        initializeEntityObjects()
        
        if (!dataReceived) {
            
            getWebCounts()
            getCoreDataCounts()
            
            var timer = Timer(duration: 5.0, completionHandler: {
                self.compareEntityCounts()
            })
            timer.start()
        }
        
        dataReceived = true
    }
    
    func compareEntityCounts() {
        
        println("thewineries webCount: \(thewineries.webCount)")
        println("thewineries cdCount: \(thewineries.cdCount)")
        println("therestaurants webCount: \(therestaurants.webCount)")
        println("therestaurants cdCount: \(therestaurants.cdCount)")
        println("theaccommodations webCount: \(theaccommodations.webCount)")
        println("theaccommodations cdCount: \(theaccommodations.cdCount)")
        println("thepackages webCount: \(thepackages.webCount)")
        println("thepackages cdCount: \(thepackages.cdCount)")
        println("theparking webCount: \(theparking.webCount)")
        println("theparking cdCount: \(theparking.cdCount)")
        
        if (theaccommodations.webCount != theaccommodations.cdCount) {
            println("deleting accommodations and redownloading")
            deleteFromCoreData(theaccommodations.type)
            fetchEntitiesFromWeb(theaccommodations.URL, entityType: theaccommodations.type)
        } else {
            println("fetching accommodations from core data")
            theaccommodations.entities = fetchEntitiesFromCoreData(theaccommodations.type)!
        }
        if (thepackages.webCount != thepackages.cdCount) {
            println("deleting packages and redownloading")
            deleteFromCoreData(thepackages.type)
            fetchEntitiesFromWeb(thepackages.URL, entityType: thepackages.type)
        } else {
            println("fetching packages from core data")
            thepackages.entities = fetchEntitiesFromCoreData(thepackages.type)!
        }
        if (theparking.webCount != theparking.cdCount) {
            println("deleting parking and redownloading")
            deleteFromCoreData(theparking.type)
            fetchEntitiesFromWeb(theparking.URL, entityType: theparking.type)
        } else {
            println("fetching parking from core data")
            theparking.entities = fetchEntitiesFromCoreData(theparking.type)!
        }
        if (therestaurants.webCount != therestaurants.cdCount) {
            println("deleting restaurants and redownloading")
            deleteFromCoreData(therestaurants.type)
            fetchEntitiesFromWeb(therestaurants.URL, entityType: therestaurants.type)
        } else {
            println("fetching restaurants from core data")
            therestaurants.entities = fetchEntitiesFromCoreData(therestaurants.type)!
        }
        if (thewineries.webCount != thewineries.cdCount) {
            println("deleting wineries and redownloading")
            deleteFromCoreData(thewineries.type)
            fetchEntitiesFromWeb(thewineries.URL, entityType: thewineries.type)
        } else {
            println("fetching wineries from core data")
            thewineries.entities = fetchEntitiesFromCoreData(thewineries.type)!
        }
    }
    
    func initializeEntityObjects() {
        thewineries.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/wineries.json")!
        thewineries.type = "Winery"
        therestaurants.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/restaurants.json")!
        therestaurants.type = "Restaurant"
        thepackages.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/packages.json")!
        thepackages.type = "Package"
        theparking.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/parking.json")!
        theparking.type = "Parking"
        theaccommodations.URL = NSURL(string: "http://www.nathanpilgrim.net/rest/accommodations.json")!
        theaccommodations.type = "Accommodation"
    }
    
    //#MARK: - Core Data Methods
    func deleteFromCoreData(entityType: String) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let deletionFetchRequest = NSFetchRequest(entityName: entityType)
        
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
    
    func fetchEntitiesFromCoreData(entityType: String) -> [NSManagedObject]? {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext! 
        
        let fetchRequest = NSFetchRequest(entityName: entityType) 
        
        var error: NSError? 
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]? 
        
        return fetchedResults 
    }
    
    func getCoreDataCounts() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let wineryFetchRequest = NSFetchRequest(entityName: thewineries.type)
        let restaurantFetchRequest = NSFetchRequest(entityName: therestaurants.type)
        let packageFetchRequest = NSFetchRequest(entityName: thepackages.type)
        let parkingFetchRequest = NSFetchRequest(entityName: theparking.type)
        let accommodationFetchRequest = NSFetchRequest(entityName: theaccommodations.type)
        
        var error: NSError?
        
        let fetchedAccommodations = managedContext.executeFetchRequest(accommodationFetchRequest, error: &error) as! [NSManagedObject]
        
        let fetchedPackages = managedContext.executeFetchRequest(packageFetchRequest, error: &error) as! [NSManagedObject]
        
        let fetchedParking = managedContext.executeFetchRequest(parkingFetchRequest, error: &error) as! [NSManagedObject]
        
        let fetchedRestaurants = managedContext.executeFetchRequest(restaurantFetchRequest, error: &error) as! [NSManagedObject]
        
        let fetchedWineries = managedContext.executeFetchRequest(wineryFetchRequest, error: &error) as! [NSManagedObject]
        
        theaccommodations.cdCount = fetchedAccommodations.count
        println("Accommodations cdCount: \(theaccommodations.cdCount)")
        thepackages.cdCount = fetchedPackages.count
        println("Packages cdCount: \(thepackages.cdCount)")
        theparking.cdCount = fetchedParking.count
        println("Parking cdCount: \(theparking.cdCount)")
        therestaurants.cdCount = fetchedRestaurants.count
        println("Restaurants cdCount: \(therestaurants.cdCount)")
        thewineries.cdCount = fetchedWineries.count
        println("Wineries cdCount: \(thewineries.cdCount)")
    }
    
    func addEntityToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext! 
        var entityType = entityInfo[5] as! String 
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as! NSManagedObject 
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData") 
        newEntity.setValue(entityInfo[0], forKey: "name") 
        newEntity.setValue(entityInfo[1], forKey: "address") 
        newEntity.setValue(entityInfo[2], forKey: "zipcode") 
        newEntity.setValue(entityInfo[3], forKey: "city") 
        newEntity.setValue(entityInfo[4], forKey: "phone") 
        
        if (entityType != theparking.type) {
            newEntity.setValue(entityInfo[6], forKey: "about") 
            newEntity.setValue(entityInfo[7], forKey: "website") 
            
            if (entityType == thewineries.type) {
                newEntity.setValue(entityInfo[8], forKey: "cluster") 
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
            self.thewineries.entities.append(newEntity)
        case "Restaurant":
            self.therestaurants.entities.append(newEntity)
        case "Accommodation":
            self.theaccommodations.entities.append(newEntity)
        case "Package":
            self.thepackages.entities.append(newEntity)
        default:
            println("Invalid entity type")
            
        }
    }
    
    func addParkingToCoreData(entityInfo: NSMutableArray) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entityType = entityInfo[5] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as! NSManagedObject
        
        newEntity.setValue(entityInfo[0], forKey: "name")
        newEntity.setValue(entityInfo[1], forKey: "address")
        newEntity.setValue(entityInfo[2], forKey: "zipcode")
        newEntity.setValue(entityInfo[3], forKey: "city")
        newEntity.setValue(entityInfo[4], forKey: "phone")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        theparking.entities.append(newEntity)
        
    }
    
    func addPackageToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entityType = entityInfo[9] as! String
        
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
        newEntity.setValue(entityInfo[8], forKey: "relatedEntityName")
        
        let relatedTitle = entityInfo[8] as! String
        println("searching for relatedEntityTitle: \(relatedTitle)")
        /*var index : Int = 0
        index = getWineryIndex(relatedTitle)
        let thewineries.entities = getWineries()
        
        println("index is \(index)")
        
        let relatedEntity = thewineries.entities[index]
        
        
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
        
        thepackages.entities.append(newEntity)
    }
    
    
    
    //#MARK: - NSURLSession Methods
    func countEntitiesFromURL(entityURL: NSURL, entityType: String) -> Void {
        
        var count: Int
        //println("Current url is \(entityURL)")
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(entityURL) {
            (data, response, error) -> Void in
            
            if error != nil {
                println(error.localizedDescription)
            } else {
                self.extractCountFromJSON(data, entityType: entityType)
            }
        }
        task.resume()
    }
    
    func getWebCounts() {
        
        countEntitiesFromURL(thewineries.URL, entityType: thewineries.type)
        countEntitiesFromURL(theaccommodations.URL, entityType: theaccommodations.type)
        countEntitiesFromURL(therestaurants.URL, entityType: therestaurants.type)
        countEntitiesFromURL(thepackages.URL, entityType: thepackages.type)
        countEntitiesFromURL(theparking.URL, entityType: theparking.type)
        
        
        /*fetchEntitiesFromWeb(theaccommodations.URL!, entityType: theaccommodations.type)
        fetchEntitiesFromWeb(therestaurants.URL!, entityType: therestaurants.type)
        fetchEntitiesFromWeb(thepackages.URL!, entityType: thepackages.type)
        fetchEntitiesFromWeb(theparking.URL!, entityType: theparking.type)
        fetchEntitiesFromWeb(thewineries.URL!, entityType: thewineries.type)*/
    }
    
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
    
    //#MARK: - JSON Methods
    func extractCountFromJSON(data: NSData, entityType: String) -> Void {
        
        //println("testing... extractCount method is firing!")
        
        let json = JSON(data: data)
        println("\(entityType) web count is \(json.count)")
        
        switch (entityType) {
        case self.theaccommodations.type:
            theaccommodations.webCount = json.count
        case self.thepackages.type:
            thepackages.webCount = json.count
        case self.theparking.type:
            theparking.webCount = json.count
        case self.therestaurants.type:
            therestaurants.webCount = json.count
        case self.thewineries.type:
            thewineries.webCount = json.count
        default:
            println("Invalid EntityType")
        }
    }
    
    func parseJSONEntity(data: NSData, entityType: String) -> Void {
        
        
        if (entityType == thepackages.type) {
            parseJSONPackage(data, entityType: entityType)
            
        } else {
            
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
                
                println("testing")
                println(json[ctr]["node_title"].stringValue)
                
                
                if (entityType != theparking.type) {
                    
                    let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
                    let entityImageUrl = NSURL(string: entityImageString)
                    let imgData = NSData(contentsOfURL: entityImageUrl!)
                    let entityImage = UIImage(data: imgData!)
                    
                    infoArray.addObject(json[ctr]["Description"].stringValue)
                    infoArray.addObject(json[ctr]["Website"].stringValue)
                    
                    if (entityType == thewineries.type) {
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
    
    func parseJSONPackage(data: NSData, entityType: String) -> Void {
        
        let json = JSON(data: data)
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
            infoArray.addObject(json[ctr]["RelatedEntityTitle"].stringValue)
            infoArray.addObject(entityType)
            
            println("testing in parseJSONPackages...")
            println("incoming title is \(infoArray[0])")
            println("incoming cost is \(infoArray[3])")
            
            var temp2 = json[ctr]["RelatedEntityTitle"].stringValue
            
            println("incoming related entity title is \(temp2)")
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
