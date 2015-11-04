//
//  CorkDistrictData.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/16/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import SystemConfiguration

private let _SingletonSharedInstance = CorkDistrictData()

enum Index: Int {
    case Name = 0
    case NodeID = 1
    case Address = 2
    case Zipcode = 3
    case City = 4
    case Phone = 5
}

enum WineTourType: Int {
    case Downtown = 0
    case MtSpokane
    case Sodo
}

class CorkDistrictData {
    
    static var sharedInstance : CorkDistrictData {
        return _SingletonSharedInstance
    }
    
    var dataReceived: Bool = false
    private let URL_NOTIFICATIONS = NSURL(string: "http://www.corkdistrictapp.com/rest/push_notifications")
    private let URL_CHANGELOG = NSURL(string: "http://www.corkdistrictapp.com/rest/all.json")
    private let MAP_CENTER_ADDRESS = "714 W Main, WA, 99201"
    
    private let entityTypeCorkDistrict = "CorkDistrictEntity"
    private let entityTypeLastChanged = "LastChangedEntity"
    private let entityTypePackage = "PackageEntity"
    private var cdDates = [String]()
    private var downtownCluster = [CorkDistrictEntity]()
    private var mtCluster = [CorkDistrictEntity]()
    private var sodoCluster = [CorkDistrictEntity]()
    private var timeOuts: Int?
    private var selectedEntityType: LocationType?
    private var currentURL: NSURL?
    private var selectedEntity: CorkDistrictEntity?
    private var currentCoordinates: CLLocationCoordinate2D?
    private var currentTourType: WineTourType?
    
    
    private var wineries = EntityCollection(type: .Winery, url: NSURL(string: "http://www.corkdistrictapp.com/rest/wineries.json")!)
    private var restaurants = EntityCollection(type: .Restaurant, url: NSURL(string: "http://www.corkdistrictapp.com/rest/restaurants.json")!)
    private var accommodations = EntityCollection(type: .Accommodation, url: NSURL(string: "http://www.corkdistrictapp.com/rest/lodging.json")!)
    private var packages = PackageCollection(url: NSURL(string: "http://www.corkdistrictapp.com/rest/packages.json")!)
    private var parking = EntityCollection(type: .Parking, url: NSURL(string: "http://www.corkdistrictapp.com/rest/parking.json")!)
    
    
    //#MARK: - Access Methods
    func getCurrentURL() -> NSURL? {
        return currentURL
    }
    
    func setCurrentURL(urlString: String) {
        let string = removeWhitespace(urlString)
        print("Creating URL with string \(string)")
        currentURL = NSURL(string: string)
    }
    
    func resetCurrentURL() {
        currentURL = nil
    }
    
    func resetCurrentTour() {
        currentTourType = nil
    }
    
    func setCurrentTour(type: WineTourType) {
        currentTourType = type
    }
    
    func getCurrentTourType() -> WineTourType? {
        return currentTourType
    }
    
    func getCurrentTour() -> [CorkDistrictEntity]? {
        
        if let type = currentTourType {
            switch (type) {
            
            case .Downtown:
                return downtownCluster
            case .MtSpokane:
                return mtCluster
            case .Sodo:
                return sodoCluster
            }
        }
        
        return nil
    }
    
    func getNumTimeouts() -> Int? {
        return timeOuts
    }
    
    func getWineries() -> [CorkDistrictEntity] {
        return wineries.entities
    }
    
    func getNotificationURL() -> NSURL {
        return URL_NOTIFICATIONS!
    }
    
    func getPackages() -> [CorkDistrictPackage] {
        return packages.items
    }
    
    func assignTourClusters() {
        for entity in wineries.entities {
            if let cluster = entity.cluster {
                switch (cluster) {
                    
                    case "Downtown":
                        downtownCluster.append(entity)
                    case "SoDo":
                        sodoCluster.append(entity)
                    default:
                        mtCluster.append(entity)
                }
            }
        }
    }
    
    func getMtCluster() -> [CorkDistrictEntity] {
        return mtCluster
    }
    
    func getSoDoCluster() -> [CorkDistrictEntity] {
        return sodoCluster
    }
    
    func getDowntownCluster() -> [CorkDistrictEntity] {
        return downtownCluster
    }
    
    func getRestaurants() -> [CorkDistrictEntity] {
        return restaurants.entities
    }
    
    func getAccommodations() -> [CorkDistrictEntity] {
        return accommodations.entities
    }
    
    func getParking() -> [CorkDistrictEntity] {
        return parking.entities
    }
    
    func getAllEntities() -> [CorkDistrictEntity] {
        return  parking.entities + restaurants.entities + accommodations.entities + wineries.entities
    }
    
    func setSelectedEntityType(type: LocationType) {
        selectedEntityType = type
    }
    
    func setSelectedEntity(entity: CorkDistrictEntity) {
        selectedEntity = entity
    }
    
    func getSelectedEntity() -> CorkDistrictEntity? {
        return selectedEntity
    }
    
    func getMapCenterPointAddress() -> String {
        return MAP_CENTER_ADDRESS
    }
    
    func getEntityByNodeID(nodeID: String) -> CorkDistrictEntity? {
        
        let entities = accommodations.entities + restaurants.entities + wineries.entities
        
        for entity in entities {
            if entity.nodeID == nodeID {
                return entity
            }
        }
        
        return nil
    }
    
    func translateMapCoordinates() {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(MAP_CENTER_ADDRESS, completionHandler: {
            (placemarks, error) -> Void in
            if error != nil {
                print("Error \(error)")
            } else {
                
                if let placemark = placemarks!.first {
                    if let location = placemark.location {
                        print("TEST - converted address to coordinates \(location.coordinate)")
                        self.currentCoordinates = location.coordinate
                    }
                }
            }
        })
    }
    
    func getMapCoordinates() -> CLLocationCoordinate2D? {
        
        return currentCoordinates
    }
    
    func resetSelectedEntity() {
        selectedEntity = nil
    }
    
    func getSelectedEntityType() -> LocationType? {
        return selectedEntityType
    }
    
    func resetSelectedEntityType() {
        selectedEntityType = nil
    }
    
    func hasDownloadFinished() -> Bool {
        
        if !isDeviceConnectedToNetwork() || accommodations.loaded && parking.loaded && packages.loaded && restaurants.loaded && wineries.loaded {
            NSNotificationCenter.defaultCenter().postNotificationName("updateLoadingScreen", object: nil)
            return true
        }
        
        return false
    }
    
    //#MARK: - Update methods
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
    
    
    func loadData() {
        fetchLastChangedValuesFromCoreData()
        
        if (!dataReceived) {
        
            if isDeviceConnectedToNetwork() {
                retrieveDatesAndCountsFromWeb()
            } else {
                fetchAllCollectionsFromCoreData()
            }
        }
        dataReceived = true
    }
    
    func updateEntity(collection: EntityCollection) {
        
        if collection.lastChangedCD != collection.lastChangedWeb || collection.cdCount != collection.webCount {
            retrieveEntityCollectionFromWeb(collection)
        } else {
            fetchEntityCollectionFromCoreData(collection)
        }
    }
    
    func updatePackage(collection: PackageCollection) {
        
        if collection.lastChangedCD != collection.lastChangedWeb || collection.cdCount != collection.webCount {
            print("calling retrievePackageCollectionFromWEb")
            retrievePackageCollectionFromWeb()
        } else {
            print("Calling fetchPackageCollectionFromCoreData")
            fetchPackageCollectionFromCoreData()
        }
    }
    
    //#MARK: - Core Data Methods
    func deleteEntityCollectionFromCoreData(collection: EntityCollection) {
        
        collection.entities.removeAll()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let deletionFetchRequest = NSFetchRequest(entityName: entityTypeCorkDistrict)
        let predicate = NSPredicate(format: "type == %@", String(collection.type))
        deletionFetchRequest.predicate = predicate
        
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
    
    func deletePackageCollectionFromCoreData() {
        

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let deletionFetchRequest = NSFetchRequest(entityName: entityTypePackage)
        
        let fetchedResults = try! managedContext.executeFetchRequest(deletionFetchRequest) as! [NSManagedObject]
        
        for result in fetchedResults {
            managedContext.deleteObject(result)
        }
        
        packages.items.removeAll()
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
    }
    
    /*func deleteLastChangedValuesFromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityTypeLastChanged)
        
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        for result in fetchedResults {
            managedContext.deleteObject(result)
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save \(error)")
        }
    }*/
    
    func fetchEntityCollectionFromCoreData(collection: EntityCollection) {
        
        collection.loaded = true
        hasDownloadFinished()
        
        print("fetchEntityFromCoreData - current type = \(collection.type)")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: entityTypeCorkDistrict)
        
        let predicate = NSPredicate(format: "type == %@", String(collection.type))
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        for result in fetchedResults {
            
            let title = result.valueForKey("title") as! String
            let address = result.valueForKey("address") as! String
            let zip = result.valueForKey("zipcode") as! String
            let phone = result.valueForKey("phone") as! String
            let city = result.valueForKey("city") as! String
            let nodeID = result.valueForKey("nodeID") as! String
            
            var coordinate: CLLocationCoordinate2D?
            if let coordString = result.valueForKey("placemark") as? String {
                print("Getting placemark from core data and parsing lat/long")
                let components = coordString.componentsSeparatedByString(",")
                
                print("first component is \(components[0])")
                print("Second component is \(components[1])")
                
                coordinate = CLLocationCoordinate2D(latitude: Double(components[0])!, longitude: Double(components[1])!)
            }
            
            
            var newEntity: CorkDistrictEntity
            
            if collection.type == .Parking {
                
                newEntity = CorkDistrictEntity(type: collection.type, title: title, address: address, city: city, zip: zip, phone: phone, nodeID: nodeID, typePlural: "Parking")
                
            } else if collection.type == .Winery {
                
                let cluster = result.valueForKey("cluster") as! String
                let hours = result.valueForKey("hours") as! String
                let cardAccepted = result.valueForKey("cardAccepted") as! String
                let webAddress = result.valueForKey("website") as! String
                let description = result.valueForKey("about") as! String
                let imageData = result.valueForKey("imageData") as! NSData
                let image = UIImage(data: imageData)
                
                newEntity = CorkDistrictEntity(title: title, address: address, zip: zip, phone: phone, city: city, nodeID: nodeID, webAddress: webAddress, description: description, type: collection.type, typePlural: "Wineries", image: image!, cluster: cluster, hours: hours, cardAccepted: cardAccepted)
                
            } else {
                
                let webAddress = result.valueForKey("website") as! String
                let description = result.valueForKey("about") as! String
                let imageData = result.valueForKey("imageData") as! NSData
                let image = UIImage(data: imageData)
                var typePlural: String
                
                if collection.type == .Restaurant {
                    typePlural = "Restaurants"
                } else {
                    typePlural = "Accommodations"
                }
                
                newEntity = CorkDistrictEntity(title: title, address: address, zip: zip, phone: phone, city: city, nodeID: nodeID, webAddress: webAddress, description: description, type: collection.type, typePlural: typePlural, image: image!)
            }
            
            if let coord = coordinate {
                newEntity.setCoordinate(coord)
            }
            
            collection.entities.append(newEntity)
        }
        
        
        
        
    }
    
    func fetchPackageCollectionFromCoreData() {
        
        packages.loaded = true
        hasDownloadFinished()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        print("fetchPackagesFromCoreData")
        let fetchRequest = NSFetchRequest(entityName: entityTypePackage)
        
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        for result in fetchedResults {
            
            let title = result.valueForKey("title") as! String
            let startDay = result.valueForKey("startDay") as! String
            let startMonth = result.valueForKey("startMonth") as! String
            let startYear = result.valueForKey("startYear") as! String
            let endDay = result.valueForKey("endDay") as! String
            let endMonth = result.valueForKey("endMonth") as! String
            let endYear = result.valueForKey("endYear") as! String
            let cost = result.valueForKey("cost") as! String
            let relatedNodeID = result.valueForKey("relatedNodeID") as! String
            let webAddress = result.valueForKey("webAddress") as! String
            let imageData = result.valueForKey("imageData") as! NSData
            let image = UIImage(data: imageData)
            
            print("relatedNodeID is \(relatedNodeID)")
            
            let newPackage = CorkDistrictPackage(title: title, cost: cost, startDay: startDay, startMonth: startMonth, startYear: startYear, endDay: endDay, endMonth: endMonth, endYear: endYear, relatedNodeID: relatedNodeID, webAddress: webAddress, image: image!)
            
            packages.items.append(newPackage)
            
        }
        
        
        
    }
    
    func fetchLastChangedValuesFromCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: entityTypeLastChanged)
        var fetchedResults: [NSManagedObject]?
        
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            print("Error, could not save. \(error)")
        }
        
        if let results = fetchedResults {
            for result in results {
            
                accommodations.lastChangedCD = (result.valueForKey("accommodation") as! String)
                packages.lastChangedCD = (result.valueForKey("package") as! String)
                parking.lastChangedCD = (result.valueForKey("parking") as! String)
                wineries.lastChangedCD = (result.valueForKey("winery") as! String)
                restaurants.lastChangedCD = (result.valueForKey("restaurant") as! String)
            }
        }
    }
    
    func fetchAllCollectionsFromCoreData() {
    
        fetchEntityCollectionFromCoreData(wineries)
        fetchEntityCollectionFromCoreData(restaurants)
        fetchEntityCollectionFromCoreData(accommodations)
        fetchEntityCollectionFromCoreData(parking)
        fetchPackageCollectionFromCoreData()
    }
    
    func fetchEntityCountFromCoreData(collection: EntityCollection) -> Int {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityTypeCorkDistrict)
        let predicate = NSPredicate(format: "type == %@", String(collection.type))
        fetchRequest.predicate = predicate
        
        var error: NSError?
        return managedContext.countForFetchRequest(fetchRequest, error: &error)
    }
    
    func fetchPackageCountFromCoreData() -> Int {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityTypePackage)
        
        var error: NSError?
        return managedContext.countForFetchRequest(fetchRequest, error: &error)
    }
    
    func storeLastChangedValuesInCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: entityTypeLastChanged)
        let fetchedResults = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        
        if fetchedResults.count == 0 {
            
            let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityTypeLastChanged, inManagedObjectContext: managedContext)
            
            newEntity.setValue(wineries.lastChangedWeb, forKey: "winery")
            newEntity.setValue(restaurants.lastChangedWeb, forKey: "restaurant")
            newEntity.setValue(accommodations.lastChangedWeb, forKey: "accommodation")
            newEntity.setValue(parking.lastChangedWeb, forKey: "parking")
            newEntity.setValue(packages.lastChangedWeb, forKey: "package")
        } else {
            
            fetchedResults[0].setValue(wineries.lastChangedWeb, forKey: "winery")
            fetchedResults[0].setValue(restaurants.lastChangedWeb, forKey: "restaurant")
            fetchedResults[0].setValue(accommodations.lastChangedWeb, forKey: "accommodation")
            fetchedResults[0].setValue(parking.lastChangedWeb, forKey: "parking")
            fetchedResults[0].setValue(packages.lastChangedWeb, forKey: "package")
        }
        
        managedContext.performBlock( {
            do {
                try managedContext.save()
            } catch {
                print("Could not save \(error)")
            }
        })
    }
    
    func storeEntityCollectionInCoreData(collection: EntityCollection) -> Void {
        
        collection.loaded = true
        
        print("addEntityToCoreData -> type: \(collection.type)")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        for entity in collection.entities {
            
            let newEntity = NSEntityDescription.insertNewObjectForEntityForName(self.entityTypeCorkDistrict, inManagedObjectContext: managedContext) as NSManagedObject
            
            print("Creating core data entity for \(entity.title)")
            newEntity.setValue(String(collection.type), forKey: "type")
            newEntity.setValue(entity.title, forKey: "title")
            newEntity.setValue(entity.nodeID, forKey: "nodeID")
            newEntity.setValue(entity.address, forKey: "address")
            newEntity.setValue(entity.zip, forKey: "zipcode")
            newEntity.setValue(entity.city, forKey: "city")
            newEntity.setValue(entity.phone, forKey: "phone")
            
            if let description = entity.description {
                newEntity.setValue(description, forKey: "about")
            }
            
            if let webAddress = entity.webAddress {
                newEntity.setValue(webAddress, forKey: "website")
            }
            
            if let hours = entity.hours {
                newEntity.setValue(hours, forKey: "hours")
            }
            
            if let cluster = entity.cluster {
                newEntity.setValue(cluster, forKey: "cluster")
            }
            
            if let cardAccepted = entity.cardAccepted {
                newEntity.setValue(cardAccepted, forKey: "cardAccepted")
            }
            
            if let image = entity.image {
                newEntity.setValue(UIImageJPEGRepresentation(image, 1), forKey: "imageData")
            }
            
            if let coordinate = entity.coordinate {
                let coordString = String(coordinate.latitude) + "," + String(coordinate.longitude)
                newEntity.setValue(coordString, forKey: "placemark")
            }
            
            
            do {
                try managedContext.save()
            } catch {
                print("Could not save \(error)")
            }
            
        }
    }
    
    func storePackageCollectionInCoreData() -> Void {
        
        packages.loaded = true
        
        print("addPackagesToCoreData")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        for entity in packages.items {
            let newEntity = NSEntityDescription.insertNewObjectForEntityForName(self.entityTypePackage, inManagedObjectContext: managedContext) as NSManagedObject
        
            print("Creating core data package for \(entity.title)")
            newEntity.setValue(entity.title, forKey: "title")
            newEntity.setValue(entity.relatedNodeID, forKey: "relatedNodeID")
            newEntity.setValue(entity.startDay, forKey: "startDay")
            newEntity.setValue(entity.startDay, forKey: "startDay")
            newEntity.setValue(entity.startMonth, forKey: "startMonth")
            newEntity.setValue(entity.startYear, forKey: "startYear")
            newEntity.setValue(entity.endDay, forKey: "endDay")
            newEntity.setValue(entity.endMonth, forKey: "endMonth")
            newEntity.setValue(entity.endYear, forKey: "endYear")
            newEntity.setValue(entity.cost, forKey: "cost")
            newEntity.setValue(entity.webAddress, forKey: "webAddress")
            newEntity.setValue(UIImageJPEGRepresentation(entity.image, 1), forKey: "imageData")
        
        
           
            do {
                try managedContext.save()
            } catch {
                print("Could not save \(error)")
            }
            
        }
        
    }
    
    
    
    //#MARK: - NSURLSession Methods
    func retrieveDatesAndCountsFromWeb() {
        
        NSURLSession.sharedSession().configuration.timeoutIntervalForResource = 5.0
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL_CHANGELOG!) {
            (data, response, error) -> Void in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.compareDatesAndTotals(data!)
            }
        }
        
        task.resume()
    }
    
    func retrievePackageCollectionFromWeb() {
        
        NSURLSession.sharedSession().configuration.timeoutIntervalForResource = 10.0
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(packages.url) {
            (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.deletePackageCollectionFromCoreData()
                
                self.parsePackageJSON(data!) {
                    (packages: PackageCollection) -> Void in
                    packages.loaded = true
                    self.hasDownloadFinished()
                    self.storePackageCollectionInCoreData()
                }
            }
        }
        
        task.resume()
    }
    
    func retrieveEntityCollectionFromWeb(collection: EntityCollection) {
        print("retrieveEntityFromWeb -> type: \(collection.type)")
        NSURLSession.sharedSession().configuration.timeoutIntervalForResource = 10.0
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(collection.url) {
            (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                //self.deleteEntityCollectionFromCoreData(collection)
                
                self.parseEntityJSON(data!, collection: collection) {
                    (collection: EntityCollection) -> Void in
                    
                    collection.loaded = true
                    self.hasDownloadFinished()
                    self.storeEntityCollectionInCoreData(collection)
                }
            }
        }
        
        task.resume()
    }
    
    
    //#MARK: - JSON Methods
    func parseEntityJSON(data: NSData, collection: EntityCollection, completion: (collection: EntityCollection) -> Void) {
        
        let json = JSON(data: data)
            
        var ctr=0
        while (ctr < json.count) {
                
            let entityCityStateZip = json[ctr]["City State Zip"].stringValue
            let cityStateZipArray = separateCityStateZip(entityCityStateZip)
            var entityCity = ""
            var entityZip = ""
                
                
            if cityStateZipArray.count > 0 {
                entityCity = cityStateZipArray[0].stringByReplacingOccurrencesOfString(" ", withString: "")
                entityZip = cityStateZipArray[2]
            }
                
            let title = json[ctr]["node_title"].stringValue
            let nodeID = json[ctr]["nid"].stringValue
            let address = json[ctr]["Street Address"].stringValue
            let phone = json[ctr]["Phone"].stringValue
            let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
            let entityImageUrl = NSURL(string: entityImageString)
            let imgData = NSData(contentsOfURL: entityImageUrl!)
            let desc = json[ctr]["Description"].stringValue as String
            let description = removeOddCharacters(desc)
            var webAddress = json[ctr]["Website"].stringValue
            webAddress = removeOddCharacters(webAddress)
            var entityImage: UIImage
                
            if imgData != nil {
                entityImage = UIImage(data: imgData!)!
            } else {
                entityImage = UIImage()
            }
            
            var newEntity: CorkDistrictEntity
            let geocoder = CLGeocoder()
            
            
            if collection.type == .Parking {
                newEntity = CorkDistrictEntity(type: collection.type, title: title, address: address, city: entityCity, zip: entityZip, phone: phone, nodeID: nodeID, typePlural: "Parking")
            } else if collection.type == .Winery {
                    
                let cluster = json[ctr]["Cluster"].stringValue
                let hours = json[ctr]["Hours of Operation"].stringValue
                let cardAccepted = json[ctr]["Cork District Card"].stringValue
                    
                newEntity = CorkDistrictEntity(title: title, address: address, zip: entityZip, phone: phone, city: entityCity, nodeID: nodeID, webAddress: webAddress, description: description, type: collection.type, typePlural: "Wineries", image: entityImage,cluster: cluster, hours: hours, cardAccepted: cardAccepted)
            } else {
                
                var typePlural: String
                
                if collection.type == .Restaurant {
                    typePlural = "Restaurants"
                } else {
                    typePlural = "Accommodations"
                }
                
                newEntity = CorkDistrictEntity(title: title, address: address, zip: entityZip, phone: phone, city:entityCity, nodeID: nodeID, webAddress: webAddress, description: description, type: collection.type, typePlural: typePlural, image: entityImage)
            }
                
            collection.entities.append(newEntity)
            
            geocoder.geocodeAddressString( "\(address), \(entityCity), WA, USA", completionHandler: {(placemarks,error) -> Void in
                
                
                if let placeMarks = placemarks {
                    let pm = placeMarks[0]
                    if let location = pm.location {
                        newEntity.setCoordinate(location.coordinate)
                    }
                }
            })
                
            ctr++
        }
        
        completion(collection: collection)
    }
    
    func parsePackageJSON(data: NSData, completion: (packages: PackageCollection) -> Void) {
        
        let json = JSON(data: data)
        var ctr=0
        
        while (ctr < json.count) {
            
            let title = json[ctr]["node_title"].stringValue
            let startDay = json[ctr]["StartDay"].stringValue
            let startMonth = json[ctr]["StartMonth"].stringValue
            let startYear = json[ctr]["StartYear"].stringValue
            let endDay = json[ctr]["EndDay"].stringValue
            let endMonth = json[ctr]["EndMonth"].stringValue
            let endYear = json[ctr]["EndYear"].stringValue
            let cost = json[ctr]["Cost"].stringValue
            let webAddress = json[ctr]["Website"].stringValue
            let entityImageString = stripHtml(json[ctr]["Thumbnail"].stringValue)
            let entityImageUrl = NSURL(string: entityImageString)
            let imgData = NSData(contentsOfURL: entityImageUrl!)
            
            
            
            var entityImage: UIImage
            if imgData != nil {
                entityImage = UIImage(data: imgData!)!
            } else {
                entityImage = UIImage()
            }
            
            let temp = json[ctr]["Related Items"][0]["target_id"].stringValue
            var relatedNodeID: String
            print("relatedNodeID is \(temp)")
            
            if json[ctr]["Related Items"].count > 1 {
                relatedNodeID = temp + "," + json[ctr]["Related Items"][1]["target_id"].stringValue
            } else {
                relatedNodeID = temp
            }
            
            let newPackage = CorkDistrictPackage(title: title, cost: cost, startDay: startDay, startMonth: startMonth, startYear: startYear, endDay: endDay, endMonth: endMonth, endYear: endYear, relatedNodeID: relatedNodeID, webAddress: webAddress, image: entityImage)
            
            print("Testing... newPackage.name is \(newPackage.title)")
            packages.items.append(newPackage)
            ctr++
        }
        
        completion(packages: packages)
    }
    
    func compareDatesAndTotals(data: NSData) {
        
        
        let json = JSON(data: data)
        var ctr: Int = 0
        
        while (ctr < json.count) {
            
            let type = json[ctr]["node_type"].stringValue
            
            print("type in compareDatesAndTotals is currently \(type) and ctr is \(ctr)")
            
            if type == "winery" {
                wineries.lastChangedWeb = json[ctr]["node_changed"].stringValue
                wineries.webCount = json[ctr]["count"].intValue
                wineries.cdCount = fetchEntityCountFromCoreData(wineries)
                updateEntity(wineries)
            } else if type == "restaurant" {
                restaurants.lastChangedWeb = json[ctr]["node_changed"].stringValue
                restaurants.webCount = json[ctr]["count"].intValue
                restaurants.cdCount = fetchEntityCountFromCoreData(restaurants)
                updateEntity(restaurants)
            } else if type == "lodging" {
                accommodations.lastChangedWeb = json[ctr]["node_changed"].stringValue
                accommodations.webCount = json[ctr]["count"].intValue
                accommodations.cdCount = fetchEntityCountFromCoreData(accommodations)
                updateEntity(accommodations)
            } else if type == "packages" {
                packages.lastChangedWeb = json[ctr]["node_changed"].stringValue
                packages.webCount = json[ctr]["count"].intValue
                packages.cdCount = fetchPackageCountFromCoreData()
                updatePackage(packages)
            } else if type == "parking" {
                parking.lastChangedWeb = json[ctr]["node_changed"].stringValue
                parking.webCount = json[ctr]["count"].intValue
                parking.cdCount = fetchEntityCountFromCoreData(parking)
                updateEntity(parking)
            }
            
            ctr++
        }
        
        storeLastChangedValuesInCoreData()
    }
    
    //#MARK: - Misc. Methods
    func stripHtml(urlObject: String) -> String {
        
        if urlObject == "" {
            return urlObject
        }
        
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
        tempString = tempString.stringByReplacingOccurrencesOfString(term3, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return tempString.stringByReplacingOccurrencesOfString(term4, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        //return tempString.stringByReplacingOccurrencesOfString(term5, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace(string: String) -> String {
        let term1 = "\n"
        let term2 = "\t"
        let term3 = " "
        
        var tempString = string.stringByReplacingOccurrencesOfString(term1, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        tempString = tempString.stringByReplacingOccurrencesOfString(term2, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return tempString.stringByReplacingOccurrencesOfString(term3, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func separateCityStateZip(cityStateZip: String) -> [String] {
        
        if cityStateZip == "" {
            return [String]()
        }
        
        let cityStateZipArray = cityStateZip.componentsSeparatedByString(" ")
        var resultArray = [String]()
        
        //0-city, 1-state, 2-zip
        if (cityStateZipArray.count > 3) {
            resultArray.append(cityStateZipArray[0] + " " + cityStateZipArray[1])
            resultArray.append(cityStateZipArray[2])
            resultArray.append(cityStateZipArray[3])
        } else {//0-city, 2-state, 3-zip
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
            
            curCluster = winery.cluster!
            
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