//
//  DataManager.swift
//  CorkDistrict
//


import Foundation
import CoreData
import UIKit
import CoreLocation
import SystemConfiguration


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
    
    
    private let URL_NOTIFICATIONS = NSURL(string: "http://www.corkdistrictapp.com/rest/push_notifications")
    private let URL_CHANGELOG = NSURL(string: "http://www.corkdistrictapp.com/rest/all.json")
    
    private var wineries = CorkDistrictEntity()
    private var restaurants = CorkDistrictEntity()
    private var accommodations = CorkDistrictEntity()
    private var packages = CorkDistrictEntity()
    private var parking = CorkDistrictEntity()
    
    private var downtownCluster = [NSManagedObject]()
    private var mtCluster = [NSManagedObject]()
    private var sodoCluster = [NSManagedObject]()
    private var progress = Float()
    private var wineDone = false
    private var restDone = false
    private var packDone = false
    private var parkDone = false
    private var accomDone = false
    private var timeOuts = Int(0)

    
    
    //#MARK: - Access Methods
    func getProgress() -> Float {
        return progress
    }
    
    func getNumTimeouts() -> Int {
        return timeOuts
    }
    
    func getWineries() -> [NSManagedObject] {
        return wineries.entities 
    }
    
    func getNotificationURL() -> NSURL {
        return URL_NOTIFICATIONS!
    }
    
    func getEntityByNodeId(nid: Int) -> NSManagedObject {
        
        var i : Int
        
        for (i=0; i < wineries.entities.count; i++) {
            
            let tempID = wineries.entities[i].valueForKey("nodeID") as! String
            let test = Int(tempID)
            
            if (test == nid) {
                return wineries.entities[i]
            }
        }
        
        for (i=0; i < restaurants.entities.count; i++) {
            
            
            let tempID = restaurants.entities[i].valueForKey("nodeID") as! String
            let test = Int(tempID)
            
            if (test == nid) {
                return restaurants.entities[i]
            }
        }
        
        for (i=0; i < accommodations.entities.count; i++) {
            
            let tempID = accommodations.entities[i].valueForKey("nodeID") as! String
            let test = Int(tempID)
            
            if (test == nid) {
                return accommodations.entities[i]
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityType = "Winery"
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as NSManagedObject
            newEntity.setValue("blank", forKey: "name")
        
        return newEntity
    }
    
    func getEntityByName(entityName: String) -> NSManagedObject {
        
        var i : Int
        
        for (i=0; i < wineries.entities.count; i++) {
            
            let tempTitle = wineries.entities[i].valueForKey("name") as! String
            
            if (tempTitle == entityName) {
                return wineries.entities[i]
            }
        }
        
        for (i=0; i < restaurants.entities.count; i++) {
            
            let tempTitle = restaurants.entities[i].valueForKey("name") as! String
            
            if (tempTitle == entityName) {
                return restaurants.entities[i]
            }
        }
        
        for (i=0; i < accommodations.entities.count; i++) {
            
            let tempTitle = accommodations.entities[i].valueForKey("name") as! String
            
            if (tempTitle == entityName) {
                return accommodations.entities[i]
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityType = "Winery"
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as NSManagedObject
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
    
    func isDeviceConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) 
    }
    
    //#MARK: - Data Management Methods
    func loadData() -> Void {
        
        initializeEntityObjects()
        
        if isDeviceConnectedToNetwork() {
            
            fetchDatesFromWeb()
            fetchDatesFromCoreData()
            fetchAllCountsFromCoreData()
            
            if (!dataReceived) {
                let timer = Timer(duration: 1.0, completionHandler: {
                    self.fetchAllEntitiesFromWeb()
                })
                
                timer.start()
            }
        } else {
            fetchAllEntitiesFromCoreData()
        }
        
        dataReceived = true
    }
    
    func fetchAllEntitiesFromCoreData() {
        
        fetchEntityFromCoreData(wineries)
        fetchEntityFromCoreData(restaurants)
        fetchEntityFromCoreData(accommodations)
        fetchEntityFromCoreData(parking)
        fetchEntityFromCoreData(packages)
    }
    
    func fetchAllCountsFromCoreData() {
        
        fetchCountFromCoreData(wineries)
        fetchCountFromCoreData(restaurants)
        fetchCountFromCoreData(accommodations)
        fetchCountFromCoreData(parking)
        fetchCountFromCoreData(packages)
    }
    
    func fetchAllEntitiesFromWeb() {
        
        progress = 0
        
        if wineries.isOutOfDate() {
            fetchEntityFromWeb(wineries)
        } else {
            fetchEntityFromCoreData(wineries)
        }
        
        if restaurants.isOutOfDate() {
            fetchEntityFromWeb(restaurants)
        } else {
            fetchEntityFromCoreData(restaurants)
        }
        
        if accommodations.isOutOfDate() {
            fetchEntityFromWeb(accommodations)
        } else {
            fetchEntityFromCoreData(accommodations)
        }
        
        if parking.isOutOfDate() {
            fetchEntityFromWeb(parking)
        } else {
            fetchEntityFromCoreData(parking)
        }
        
        if packages.isOutOfDate() {
            fetchEntityFromWeb(packages)
        } else {
            fetchEntityFromCoreData(packages)
        }
        
    }
    
    func initializeEntityObjects() {
        
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
    func deleteFromCoreData(entity: CorkDistrictEntity) {
        
        entity.clearEntities()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let deletionFetchRequest = NSFetchRequest(entityName: entity.type)
        
        let fetchedResults = try! managedContext.executeFetchRequest(deletionFetchRequest) as! [NSManagedObject]
        
        for result in fetchedResults {
            managedContext.deleteObject(result)
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
    }
    
    func deleteDatesFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "LastChanged")
        
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        for result in fetchedResults {
            managedContext.deleteObject(result)
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
    }
    
    func saveDatesToCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName("LastChanged", inManagedObjectContext: managedContext)
        
        
        newEntity.setValue(wineries.lastChangedWeb, forKey: "wineries")
        newEntity.setValue(restaurants.lastChangedWeb, forKey: "restaurants")
        newEntity.setValue(accommodations.lastChangedWeb, forKey: "accommodations")
        newEntity.setValue(parking.lastChangedWeb, forKey: "parking")
        newEntity.setValue(packages.lastChangedWeb, forKey: "packages")
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
    }
    
    func fetchEntityFromCoreData(entity: CorkDistrictEntity) {
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: entity.type)
        
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        entity.entities = fetchedResults
    }
    
    func fetchCountFromCoreData(entity: CorkDistrictEntity) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: entity.type)
        
        var error: NSError?
        let fetchedResult = managedContext.countForFetchRequest(fetchRequest, error: &error)
        entity.setCDCount(fetchedResult)
        print("Adding count of \(entity.cdCount) to entity type \(entity.type)")
        //adding this print statement fixed the issue where all entity cdCounts were showing 0 when 
        //evaluated later by the isOutOfDate method in the CorkDistrictEntity class - WTF??
    }
    
    func fetchDatesFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "LastChanged")
        
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        let results = fetchedResults
        for result in results {
            
            accommodations.lastChangedCD = (result.valueForKey("accommodations") as! String)
            packages.lastChangedCD = (result.valueForKey("packages") as! String)
            parking.lastChangedCD = (result.valueForKey("parking") as! String)
            wineries.lastChangedCD = (result.valueForKey("wineries") as! String)
            restaurants.lastChangedCD = (result.valueForKey("restaurants") as! String)
        }
        
    }
    
    func addEntityToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate 
        let managedContext = appDelegate.managedObjectContext
        let entityType = entityInfo[6] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as NSManagedObject
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData") 
        newEntity.setValue(entityInfo[Index.Name.rawValue], forKey: "name")
        newEntity.setValue(entityInfo[Index.NodeID.rawValue], forKey: "nodeID")
        newEntity.setValue(entityInfo[Index.Address.rawValue], forKey: "address")
        newEntity.setValue(entityInfo[Index.Zipcode.rawValue], forKey: "zipcode")
        newEntity.setValue(entityInfo[Index.City.rawValue], forKey: "city")
        newEntity.setValue(entityInfo[Index.Phone.rawValue], forKey: "phone")
        
        if (entityType != parking.type) {
            newEntity.setValue(entityInfo[7], forKey: "about")
            
            let website = removeOddCharacters(entityInfo[8] as! String)
            
            newEntity.setValue(website, forKey: "website")
            
            if (entityType == wineries.type) {
                newEntity.setValue(entityInfo[9], forKey: "cluster")
                newEntity.setValue(entityInfo[10], forKey: "hours")
                
                if let cardAccepted = entityInfo[11] as? String {
                    
                    newEntity.setValue(cardAccepted, forKey: "cardAccepted")
                }
                
                
                
            }
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString( "\(entityInfo[Index.Address.rawValue]), \(entityInfo[Index.City.rawValue]), WA, USA", completionHandler: {(placemarks, error) -> Void in
            
            if let placeMarks = placemarks {
                
                let pm = placeMarks[0] as CLPlacemark
                var latlong: String = "\(pm.location!.coordinate.latitude),"
                latlong += "\(pm.location!.coordinate.longitude)"
                
                //var coord : CLLocationCoordinate2D
                newEntity.setValue(latlong, forKey: "placemark")
                
            }
        })
        
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
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
                print("Invalid entity type")
            
        }
    }
    
    func addParkingToCoreData(entityInfo: NSMutableArray) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityType = entityInfo[6] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as NSManagedObject
        
        newEntity.setValue(entityInfo[Index.Name.rawValue], forKey: "name")
        newEntity.setValue(entityInfo[Index.NodeID.rawValue], forKey: "nodeID")
        newEntity.setValue(entityInfo[Index.Address.rawValue], forKey: "address")
        newEntity.setValue(entityInfo[Index.Zipcode.rawValue], forKey: "zipcode")
        newEntity.setValue(entityInfo[Index.City.rawValue], forKey: "city")
        newEntity.setValue(entityInfo[Index.Phone.rawValue], forKey: "phone")
        
       
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
        
        parking.entities.append(newEntity)
        
    }
    
    func addPackageToCoreData(entityInfo: NSMutableArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityType = entityInfo[11] as! String
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext:
            managedContext) as NSManagedObject
        
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
        
        //var relatedNodeIDString = entityInfo[12] as! String
        
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
        
        packages.entities.append(newEntity)
    }
    
    func updateProgress() {
        
        
        if (!wineDone) {
            if (wineries.entities.count == wineries.webCount && wineries.webCount != 0) {
                print("wineries determined to be done!")
                progress += 0.2
                wineDone = true
            }
        }
        
        
        if (!restDone) {
            if (restaurants.entities.count == restaurants.webCount && restaurants.webCount != 0) {
                print("restaurants determined to be done!")
                progress += 0.2
                restDone = true
            }
        }
        
        
        if (!accomDone) {
            if (accommodations.entities.count == accommodations.webCount && accommodations.webCount != 0) {
                print("accommodations determined to be done!")
                progress += 0.2
                accomDone = true
            }
        }
        
        
        if (!parkDone) {
            if (parking.entities.count == parking.webCount && parking.webCount != 0) {
                print("parking determined to be done!")
                progress += 0.2
                parkDone = true
            }
        }
        
        
        if (!packDone) {
            if (packages.entities.count == packages.webCount) {
                print("packages determined to be done!")
                progress += 0.2
                packDone = true
            }
        }
    }
    
    //#MARK: - NSURLSession Methods
    func fetchDatesFromWeb() {
        
        NSURLSession.sharedSession().configuration.timeoutIntervalForResource = 5.0
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL_CHANGELOG!) {
            (data, response, error) -> Void in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.parseDatesAndTotals(data!)
            }
        }
        
        task.resume()
    }
    
    func fetchEntityFromWeb(entity: CorkDistrictEntity) -> Void {
        
        NSURLSession.sharedSession().configuration.timeoutIntervalForResource = 10.0
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(entity.URL) {
            (data, response, error) -> Void in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.parseJSONEntity(data!, entity: entity)
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
                
            deleteFromCoreData(entity)
            
            var ctr=0
            while (ctr < json.count) {
                
                let entityCityStateZip = json[ctr]["City State Zip"].stringValue
                let cityStateZipArray = separateCityStateZip(entityCityStateZip)
                
                let entityCity = cityStateZipArray[0]
                //let entityState = cityStateZipArray[1]
                let entityZip = cityStateZipArray[2]
                
                let infoArray = NSMutableArray()
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
                        
                    let desc = json[ctr]["Description"].stringValue as String
                    let description = removeOddCharacters(desc)
                    
                    infoArray.addObject(description)
                    infoArray.addObject(json[ctr]["Website"].stringValue)
                    
                    if (entity.type == wineries.type) {
                        infoArray.addObject(json[ctr]["Cluster"].stringValue)
                        infoArray.addObject(json[ctr]["Hours of Operation"].stringValue)
                        let test = json[ctr]["Cork District Card"].stringValue
                        infoArray.addObject(test)
                        print("cardAccepted value: \(test)")
                    }
                    
                addEntityToCoreData(infoArray, entityImage: entityImage!)
                } else {
                    addParkingToCoreData(infoArray)
                }
                
                ctr++
                
            }
        }
        
        /*if (entity.type == accommodations.type) {
            progress = 1.0
        }*/
        
    }
    
    func parseDatesAndTotals(data: NSData) {
        
        
        let json = JSON(data: data)
        
        var ctr: Int = 0
        var dates = [String]()
        var wineriesIn = false
        var restIn = false
        var accommIn = false
        var packIn = false
        var parkIn = false
        
        while (ctr < json.count) {
            
            if json[ctr]["node_type"] == "lodging" && !accommIn {
                let accommodationsDate = json[ctr]["node_changed"].stringValue
                let count = json[ctr]["count"].intValue
                dates.append(accommodationsDate)
                accommodations.setWebCount(count)
                accommodations.lastChangedWeb = accommodationsDate
                accommIn = true
            }
            else if json[ctr]["node_type"] == "packages" && !packIn {
                let packagesDate = json[ctr]["node_changed"].stringValue
                let count = json[ctr]["count"].intValue
                dates.append(packagesDate)
                packages.setWebCount(count)
                packages.lastChangedWeb = packagesDate
                packIn = true
            }
            else if json[ctr]["node_type"] == "parking" && !parkIn {
                let parkingDate = json[ctr]["node_changed"].stringValue
                let count = json[ctr]["count"].intValue
                dates.append(parkingDate)
                parking.setWebCount(count)
                parking.lastChangedWeb = parkingDate
                parkIn = true
            }
            else if json[ctr]["node_type"] == "winery" && !wineriesIn {
                let wineryDate = json[ctr]["node_changed"].stringValue
                let count = json[ctr]["count"].intValue
                dates.append(wineryDate)
                wineries.setWebCount(count)
                wineries.lastChangedWeb = wineryDate
                wineriesIn = true
            }
            else if json[ctr]["node_type"] == "restaurant" && !restIn {
                let restaurantDate = json[ctr]["node_changed"].stringValue
                let count = json[ctr]["count"].intValue
                dates.append(restaurantDate)
                restaurants.setWebCount(count)
                restaurants.lastChangedWeb = restaurantDate
                restIn = true
            }
            
            ctr++
        }
      
        deleteDatesFromCoreData()
        saveDatesToCoreData()
    }
    
    func parseJSONPackage(data: NSData, entity: CorkDistrictEntity) -> Void {
        
        let json = JSON(data: data)
            
        deleteFromCoreData(entity)
        var ctr=0
            
        
        while (ctr < json.count) {
            let infoArray = NSMutableArray()
                
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
    
    
    //#MARK: - Misc. Methods
    func stripHtml(urlObject: String) -> String {
        
        let entityImageStringArray = urlObject.componentsSeparatedByString(" ")
        let entityImageString = entityImageStringArray[2].stringByReplacingOccurrencesOfString("src=\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return entityImageString.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeOddCharacters(string: String) -> String {
        
        let term1 = "&quot;"
        let term2 = "&#039;"
        let term3 = "&amp;"
        let term4 = "http://"
        
        var tempString = string.stringByReplacingOccurrencesOfString(term1, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        tempString = tempString.stringByReplacingOccurrencesOfString(term2, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        tempString = tempString.stringByReplacingOccurrencesOfString(term4, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return tempString.stringByReplacingOccurrencesOfString(term3, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
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
    
    func separateClusters() {
        
        var curCluster : String
        
        for winery in wineries.entities {
            
            curCluster = (winery.valueForKey("cluster") as? String)!
            
            switch (curCluster) {
            case "Mt. to Lake":
                mtCluster.append(winery)
            case "Downtown":
                downtownCluster.append(winery)
            case "SoDo":
                sodoCluster.append(winery)
            default:
                print("Invalid cluster type")
            }
            
            curCluster = ""
        }
    }
    
    
}
