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
    private let URL_CHANGELOG = NSURL(string: "http://www.nathanpilgrim.net/rest/all.json")
    
    private var wineries = CorkDistrictEntity()
    private var restaurants = CorkDistrictEntity()
    private var accommodations = CorkDistrictEntity()
    private var packages = CorkDistrictEntity()
    private var parking = CorkDistrictEntity()
    
    private var downtownCluster = [NSManagedObject]()
    private var mtCluster = [NSManagedObject]()
    private var sodoCluster = [NSManagedObject]()
    var dataCheckFinished = false
    private var progress = Float()
    
    //TESTING
    private var wineDone = false
    private var restDone = false
    private var packDone = false
    private var parkDone = false
    private var accomDone = false
    //
    
    
    //#MARK: - Access Methods
    func getProgress() -> Float {
        return progress
    }
    
    func checkProgress() -> Float {
        return progress
    }
    
    func getWineries() -> [NSManagedObject] {
        return wineries.entities 
    }
    
    func getNotificationURL() -> NSURL {
        return URL_NOTIFICATIONS!
    }
    
    func getEntity(nid: Int) -> NSManagedObject {
        
        var i : Int
        
        for (i=0; i < wineries.entities.count; i++) {
            
            var tempTitle = wineries.entities[i].valueForKey("name") as! String
            var tempID = wineries.entities[i].valueForKey("nodeID") as! String
            var test = tempID.toInt()
            
            if (test == nid) {
                return wineries.entities[i]
            }
        }
        
        for (i=0; i < restaurants.entities.count; i++) {
            
            var tempTitle = restaurants.entities[i].valueForKey("name") as! String
            var tempID = restaurants.entities[i].valueForKey("nodeID") as! String
            var test = tempID.toInt()
            
            if (test == nid) {
                return restaurants.entities[i]
            }
        }
        
        for (i=0; i < accommodations.entities.count; i++) {
            
            var tempTitle = accommodations.entities[i].valueForKey("name") as! String
            var tempID = accommodations.entities[i].valueForKey("nodeID") as! String
            var test = tempID.toInt()
            
            if (test == nid) {
                return accommodations.entities[i]
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entityType = "Winery"
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as! NSManagedObject
        newEntity.setValue("blank", forKey: "name")
        
        return newEntity
    }
    
    func getEntity(entityName: String) -> NSManagedObject {
        
        var i : Int
        
        for (i=0; i < wineries.entities.count; i++) {
            
            var tempTitle = wineries.entities[i].valueForKey("name") as! String
            
            if (tempTitle == entityName) {
                return wineries.entities[i]
            }
        }
        
        for (i=0; i < restaurants.entities.count; i++) {
            
            var tempTitle = restaurants.entities[i].valueForKey("name") as! String
            
            if (tempTitle == entityName) {
                return restaurants.entities[i]
            }
        }
        
        for (i=0; i < accommodations.entities.count; i++) {
            
            var tempTitle = accommodations.entities[i].valueForKey("name") as! String
            
            if (tempTitle == entityName) {
                return accommodations.entities[i]
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entityType = "Winery"
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as! NSManagedObject
        newEntity.setValue("blank", forKey: "name")
        
        return newEntity
    }
    
    func getMtCluster() -> [NSManagedObject] {
        return mtCluster
    }
    
    func getSoDoCluster() -> [NSManagedObject] {
        return sodoCluster
    }
    
    func getDowntownCluster() -> [NSManagedObject] {
        return downtownCluster
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
        fetchDatesFromWeb()
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
    
    func saveDatesToCoreData() {
        println("Saving dates to core data")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName("LastChanged", inManagedObjectContext: managedContext) as! NSManagedObject
        
        newEntity.setValue(accommodations.lastChangedWeb, forKey: "accommodations")
        newEntity.setValue(wineries.lastChangedWeb, forKey: "wineries")
        newEntity.setValue(packages.lastChangedWeb, forKey: "packages")
        newEntity.setValue(parking.lastChangedWeb, forKey: "parking")
        newEntity.setValue(restaurants.lastChangedWeb, forKey: "restaurants")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
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
    
    func fetchDatesFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "LastChanged")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            for result in results {
                
                //var type = result.valueForKey("node_type") as? String
                //println("Assigning lastChangedCD to entityType: \(type)")
                accommodations.lastChangedCD = (result.valueForKey("accommodations") as? String)!
                packages.lastChangedCD = (result.valueForKey("packages") as? String)!
                parking.lastChangedCD = (result.valueForKey("parking") as? String)!
                wineries.lastChangedCD = (result.valueForKey("wineries") as? String)!
                restaurants.lastChangedCD = (result.valueForKey("restaurants") as? String)!
                
            }
        }
    }
    
    func fetchAllEntitiesFromCoreData() {
        
        fetchDatesFromCoreData()
        fetchEntitiesFromCoreData(wineries)
        fetchEntitiesFromCoreData(restaurants)
        fetchEntitiesFromCoreData(accommodations)
        fetchEntitiesFromCoreData(parking)
        fetchEntitiesFromCoreData(packages)
    }
    
    func addEntityToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext! 
        var entityType = entityInfo[6] as! String
        var stringCheck = "Not"
        
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
                newEntity.setValue(entityInfo[10], forKey: "hours")
                
                if let cardAccepted = entityInfo[11] as? String {
                    
                    newEntity.setValue(cardAccepted, forKey: "cardAccepted")
                }
                
                
                
            }
        }
        
        
        var geocoder = CLGeocoder() 
        geocoder.geocodeAddressString( "\(Index.Address.rawValue), \(Index.Zipcode.rawValue), WA, USA", completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
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
        newEntity.setValue(entityInfo[10], forKey: "nodeID")
        newEntity.setValue(entityInfo[12], forKey: "relatedNodeID")
        
        var relatedNodeIDString = entityInfo[12] as! String
        
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        packages.entities.append(newEntity)
    }
    
    func updateProgress() {
        
        //progress = 0
        
        println("wineries count and webcount: \(wineries.entities.count) \(wineries.webCount)")
        if (!wineDone) {
            if (wineries.entities.count == wineries.webCount && wineries.webCount != 0) {
                println("wineries determined to be done!")
                progress += 0.2
                wineDone = true
            }
        }
        
        println("restaurants count and webcount: \(restaurants.entities.count) \(restaurants.webCount)")
        if (!restDone) {
            if (restaurants.entities.count == restaurants.webCount && restaurants.webCount != 0) {
                println("restaurants determined to be done!")
                progress += 0.2
                restDone = true
            }
        }
        
        println("accommodations count and webcount: \(accommodations.entities.count) \(accommodations.webCount)")
        if (!accomDone) {
            if (accommodations.entities.count == accommodations.webCount && accommodations.webCount != 0) {
                println("accommodations determined to be done!")
                progress += 0.2
                accomDone = true
            }
        }
        
        println("parking count and webcount: \(parking.entities.count) \(parking.webCount)")
        if (!parkDone) {
            if (parking.entities.count == parking.webCount && parking.webCount != 0) {
                println("parking determined to be done!")
                progress += 0.2
                parkDone = true
            }
        }
        
        println("packages count and webcount: \(packages.entities.count) \(packages.webCount)")
        if (!packDone) {
            if (packages.entities.count == packages.webCount && packages.webCount != 0) {
                println("packages determined to be done!")
                progress += 0.2
                packDone = true
            }
        }
        
        if progress >= 1 {
            dataCheckFinished = true
        }
        
    }
    
    //#MARK: - NSURLSession Methods
    func fetchAllEntitiesFromWeb() {
        
        progress = 0
        fetchEntitiesFromWeb(wineries)
        fetchEntitiesFromWeb(restaurants)
        fetchEntitiesFromWeb(accommodations)
        fetchEntitiesFromWeb(parking)
        fetchEntitiesFromWeb(packages)
        
    }
    
    func fetchDatesFromWeb() {
        
        var session = NSURLSession.sharedSession()
        
        var task = session.dataTaskWithURL(URL_CHANGELOG!) {
            (data, response, error) -> Void in
            
            if error != nil {
                println(error.localizedDescription)
            } else {
                self.parseDatesTotals(data)
            }
        }
        
        task.resume()
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
    func parseJSONEntity(data: NSData, entity: CorkDistrictEntity) {
        
        if (entity.type == packages.type) {
            parseJSONPackage(data, entity: entity)
            
        } else {
            let json = JSON(data: data)
            
            println("\(entity.type) lastChangedCD: \(entity.lastChangedCD) lastChangedWeb: \(entity.lastChangedWeb)")
            entity.webCount = json.count
            entity.needsWebUpdate = false
            
            //json.count != entity.entities.count
            if (entity.isOutOfDate()) {
                //entity.needsWebUpdate = true
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
                
                
                    if (entity.type != parking.type) {
                    
                        let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
                        let entityImageUrl = NSURL(string: entityImageString)
                        let imgData = NSData(contentsOfURL: entityImageUrl!)
                        let entityImage = UIImage(data: imgData!)
                    
                        infoArray.addObject(json[ctr]["Description"].stringValue)
                        infoArray.addObject(json[ctr]["Website"].stringValue)
                    
                        if (entity.type == wineries.type) {
                            infoArray.addObject(json[ctr]["Cluster"].stringValue)
                            infoArray.addObject(json[ctr]["Hours of Operation"].stringValue)
                            let test = json[ctr]["Cork District Card"].stringValue
                            infoArray.addObject(test)
                            println("cardAccepted value: \(test)")
                    }
                    
                    addEntityToCoreData(infoArray, entityImage: entityImage!)
                    } else {
                        addParkingToCoreData(infoArray)
                    }
                
                    ctr++
                }
            }
            
        }
        
        if (entity.type == accommodations.type) {
            progress = 1.0
        }
        
    }
    
    func parseDatesTotals(data: NSData) {
        let json = JSON(data: data)
        
        var ctr: Int = 0
        var dates = [String]()
        var wineriesIn = false
        var restIn = false
        var accommIn = false
        var packIn = false
        var parkIn = false
        
        while (ctr < json.count) {
            
            let date = json[ctr]["node_changed"].stringValue
            let ent = json[ctr]["node_type"].stringValue
            
            println("Pulling in date: \(date) for entity type: \(ent)")
            
            if json[ctr]["node_type"] == "lodging" && !accommIn {
                let accommodationsDate = json[0]["node_changed"].stringValue
                dates.append(accommodationsDate)
                accommIn = true
            }
            else if json[ctr]["node_type"] == "packages" && !packIn {
                let packagesDate = json[1]["node_changed"].stringValue
                dates.append(packagesDate)
                packIn = true
            }
            else if json[ctr]["node_type"] == "parking" && !parkIn {
                let parkingDate = json[2]["node_changed"].stringValue
                dates.append(parkingDate)
                parkIn = true
            }
            else if json[ctr]["node_type"] == "winery" && !wineriesIn {
                let wineryDate = json[3]["node_changed"].stringValue
                dates.append(wineryDate)
                wineriesIn = true
            }
            else if json[ctr]["node_type"] == "restaurant" && !restIn {
                let restaurantDate = json[4]["node_changed"].stringValue
                dates.append(restaurantDate)
                restIn = true
            }
            
            ctr++
        }
        
        accommodations.lastChangedWeb = dates[0]
        restaurants.lastChangedWeb = dates[4]
        wineries.lastChangedWeb = dates[3]
        packages.lastChangedWeb = dates[1]
        parking.lastChangedWeb = dates[2]
        
        saveDatesToCoreData()
    }
    
    func parseJSONPackage(data: NSData, entity: CorkDistrictEntity) -> Void {
        
        let json = JSON(data: data)
        
        println("\(entity.type) lastChangedCD: \(entity.lastChangedCD) lastChangedWeb: \(entity.lastChangedWeb)")
        
        //json.count != entity.entities.count
        if (entity.isOutOfDate()) {
            println("Downloading \(entity.type)...")
            entity.webCount = json.count
            entity.needsWebUpdate = false
            
            deleteFromCoreData(entity)
            var ctr=0
            
        
            while (ctr < json.count) {
                var infoArray = NSMutableArray()
                entity.needsWebUpdate = true
                
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
                
                var relatedNid: String
                var tempNid: String
                
                relatedNid = json[ctr]["Related Items"][0]["target_id"].stringValue
                println("TESTING relatedNID coming in as: \(relatedNid)")
                tempNid = relatedNid
                
                if json[ctr]["Related Items"].count > 1 {
                    tempNid = relatedNid + "," + json[ctr]["Related Items"][1]["target_id"].stringValue
                }
                infoArray.addObject(tempNid)
                
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
    
    func separateClusters() {
        
        var curCluster : String
        
        for winery in wineries.entities {
            
            curCluster = (winery.valueForKey("cluster") as? String)!
            //println("CLUSTER TYPE: \(curCluster)")
            
            switch (curCluster) {
            case "Mt. to Lake":
                mtCluster.append(winery)
            case "Downtown":
                downtownCluster.append(winery)
            case "SoDo":
                sodoCluster.append(winery)
            default:
                println("Invalid cluster type")
            }
            
            curCluster = ""
        }
    }
    
    func sortWineriesByName() {
        
        var ctr: Int = 0
        var ctr2: Int = 1
        var temp = String()
        var index: Int = 0
        var name1 = [String]()
        var name2 = [String]()
        
        var tempArray: [String]
        var titlesArray = [String]()
        
        
        while (ctr < wineries.entities.count) {
            
            if let name = wineries.entities[ctr].valueForKey("name") as? String {
                titlesArray.append(name)
            }
            
            ctr++
        }
        ctr = 1
        name1 = titlesArray[0].componentsSeparatedByString(" ")
        
        while (ctr < titlesArray.count) {
            
            name2 = titlesArray[ctr].componentsSeparatedByString(" ")
            
            if name2[0] < name1[0] {
                temp = titlesArray[ctr]
                titlesArray[ctr] = titlesArray[0]
                titlesArray[0] = temp
            }
        
            ctr++
        }
    
        ctr = 0
        println("Printing wineries after alphabetical sort...\n")
        while ctr < titlesArray.count {
            
            println(titlesArray[ctr])
            ctr++
        }
        
    }
    
    
}
