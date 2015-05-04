//
//  DataManager.swift
//  CorkDistrict
//


import Foundation
import CoreData
import UIKit
import CoreLocation


private let _SingletonSharedInstance = DataManager()


class DataManager : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    class var sharedInstance: DataManager {
        return _SingletonSharedInstance
    }
    
    var dataReceived: Bool = false
    
    private var wineries = [NSManagedObject]()
    private var restaurants = [NSManagedObject]()
    private var accommodations = [NSManagedObject]()
    private var packages = [NSManagedObject]()
    private var parking = [NSManagedObject]()
    
    private let URL_WINERIES = NSURL(string: "http://www.corkdistrictapp.com/rest/wineries.json")
    private let URL_RESTAURANTS = NSURL(string: "http://www.corkdistrictapp.com/rest/restaurants.json")
    private let URL_ACCOMMODATIONS = NSURL(string: "http://www.corkdistrictapp.com/rest/lodging.json")
    private let URL_PACKAGES = NSURL(string: "http://www.corkdistrictapp.com/rest/packages.json")
    private let URL_PARKING = NSURL(string: "http://www.corkdistrictapp.com/rest/parking.json")
    private let URL_NOTIFICATIONS = NSURL(string: "http://www.corkdistrictapp.com/rest/push_notifications")
    /*
    private let URL_WINERIES = NSURL(string: "http://www.nathanpilgrim.net/rest/wineries.json")
    private let URL_RESTAURANTS = NSURL(string: "http://www.nathanpilgrim.net/rest/restaurants.json")
    private let URL_ACCOMMODATIONS = NSURL(string: "http://www.nathanpilgrim.net/rest/lodging.json")
    private let URL_PACKAGES = NSURL(string: "http://www.nathanpilgrim.net/rest/packages.json")
    private let URL_PARKING = NSURL(string: "http://www.nathanpilgrim.net/rest/parking.json")
    private let URL_NOTIFICATIONS = NSURL(string: "http://www.nathanpilgrim.net/apns/push_notifications")
    */
    private let ENTITY_TYPE_WINERY : String = "Winery"
    private let ENTITY_TYPE_RESTAURANT : String = "Restaurant"
    private let ENTITY_TYPE_ACCOMMODATION : String = "Accommodation"
    private let ENTITY_TYPE_PACKAGE : String = "Package"
    private let ENTITY_TYPE_PARKING : String = "Parking"
    
    //TESTING. FOR USE WITH NSURLSESSION DOWNLOADTASK
    private var sessionConfiguration = NSURLSessionConfiguration()
    private var session = NSURLSession()
    private var progress = Float()
    private var taskNumber = Int(0)
    //END TESTING
    
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        var entityType: String
        var data = NSData(contentsOfURL: location)
        
        switch (downloadTask.taskDescription) {
            
        case ENTITY_TYPE_WINERY:
            let wData = data
            parseJSONEntity(wData!, entityType: ENTITY_TYPE_WINERY)
        case ENTITY_TYPE_RESTAURANT:
            let rData = data
            parseJSONEntity(rData!, entityType: ENTITY_TYPE_RESTAURANT)
        case ENTITY_TYPE_ACCOMMODATION:
            let aData = data
            parseJSONEntity(aData!, entityType: ENTITY_TYPE_ACCOMMODATION)
        case ENTITY_TYPE_PARKING:
            let parkData = data
            parseJSONEntity(parkData!, entityType: ENTITY_TYPE_PARKING)
        case ENTITY_TYPE_PACKAGE:
            let packData = data
            parseJSONEntity(packData!, entityType: ENTITY_TYPE_PACKAGE)
        default:
            break
        }
        
        taskNumber++
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
            
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        progress = (Float(taskNumber)/5) * 100
        
        println("testing in didWriteData method - current progress is \(progress)")
    }
    
    func getProgress() -> Float {
        return progress
    }
    
    func loadData() -> Void {
        
        sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        if (!dataReceived) {
            
            wineries = retrieveEntities(ENTITY_TYPE_WINERY, entityURL: URL_WINERIES!)
            restaurants = retrieveEntities(ENTITY_TYPE_RESTAURANT, entityURL: URL_RESTAURANTS!)
            accommodations = retrieveEntities(ENTITY_TYPE_ACCOMMODATION, entityURL: URL_ACCOMMODATIONS!)
            parking = retrieveEntities(ENTITY_TYPE_PARKING, entityURL: URL_PARKING!)
            //packages = retrieveEntities(ENTITY_TYPE_PACKAGE, entityURL: URL_PACKAGES!)
        }
        
        dataReceived = true
    }
    
    func getWineries() -> [NSManagedObject] {
        return wineries 
    }
    
    func getNotificationURL() -> NSURL {
        return URL_NOTIFICATIONS!
    }
    
    func getWineryIndex(title: String) -> Int {
        
        var i : Int
        
        for (i=0; i < wineries.count; i++) {
            var tempTitle = wineries[i].valueForKey("name") as! String
            println("current winery title is \(tempTitle)")
            
            if (title == tempTitle) {
                return i
            }
        }
        
        return -1
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
    
    func hasDownloadFinished() -> Bool {
        return packages.count != 0
    }
    
    
    //#MARK: - Core Data Methods
    func retrieveEntities(entityType: String, entityURL: NSURL) -> [NSManagedObject] {
        
        var entities = [NSManagedObject]() 
        
        if let results = fetchEntitiesFromCoreData(entityType) {
            entities = results 
            
            if (entities.count == 0) {
                //fetchEntitiesFromWeb(entityURL, entityType: entityType)
                fetchEntitiesFromWeb2(entityURL, entityType: entityType)
            }
        }
        
        return entities 
    }
    
    func fetchEntitiesFromCoreData(entityType: String) -> [NSManagedObject]? {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext! 
        
        let fetchRequest = NSFetchRequest(entityName: entityType) 
        
        var error: NSError? 
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]? 
        
        return fetchedResults 
    }
    
    func addEntity(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
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
        
        if (entityType != ENTITY_TYPE_PARKING) {
            newEntity.setValue(entityInfo[6], forKey: "about") 
            newEntity.setValue(entityInfo[7], forKey: "website") 
            
            if (entityType == ENTITY_TYPE_WINERY) {
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
            self.wineries.append(newEntity)
        case "Restaurant":
            self.restaurants.append(newEntity)
        case "Accommodation":
            self.accommodations.append(newEntity)
        case "Package":
            self.packages.append(newEntity)
        default:
            println("Invalid entity type")
            
        }
    }
    
    func addParking(entityInfo: NSMutableArray) -> Void {
        
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
        
        parking.append(newEntity)
        
    }
    
    func addPackage(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entityType = entityInfo[9] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as! NSManagedObject
        
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
        var index : Int = 0
        index = getWineryIndex(relatedTitle)
        let wineries = getWineries()
        
        println("index is \(index)")
        
        let relatedEntity = wineries[index]
        
        
        if (index >= 0) {
            newEntity.setValue(relatedEntity.valueForKey("address"), forKey: "relatedEntityAddress")
            newEntity.setValue(relatedEntity.valueForKey("city"), forKey: "relatedEntityCity")
            newEntity.setValue(relatedEntity.valueForKey("zipcode"), forKey: "relatedEntityZipcode")
            newEntity.setValue(relatedEntity.valueForKey("address"), forKey: "relatedEntityPhone")
        }
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        packages.append(newEntity)
    }
    
    //#MARK: - NSURLSession Methods
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
    
    func fetchEntitiesFromWeb2(entityUrl: NSURL, entityType: String) -> Void {
        
        var downloadTask = session.downloadTaskWithURL(entityUrl)
        downloadTask.taskDescription = entityType
        
        downloadTask.resume()
    }
    
    //#MARK: - JSON methods
    func parseJSONEntity(data: NSData, entityType: String) -> Void {
        
        
        if (entityType == ENTITY_TYPE_PACKAGE) {
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
                
                
                if (entityType != ENTITY_TYPE_PARKING) {
                    
                    let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
                    let entityImageUrl = NSURL(string: entityImageString)
                    let imgData = NSData(contentsOfURL: entityImageUrl!)
                    let entityImage = UIImage(data: imgData!)
                    
                    infoArray.addObject(json[ctr]["Description"].stringValue)
                    infoArray.addObject(json[ctr]["Website"].stringValue)
                    
                    if (entityType == ENTITY_TYPE_WINERY) {
                        infoArray.addObject(json[ctr]["Cluster"].stringValue)
                    }
                    
                    addEntity(infoArray, entityImage: entityImage!)
                } else {
                    addParking(infoArray)
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
            
            addPackage(infoArray, entityImage: entityImage!)
            ctr++
        }
        
        
    }
    
    
    //#MARK: - Miscellaneous
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
