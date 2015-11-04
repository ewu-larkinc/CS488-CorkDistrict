//
//  DataSingleton.swift
//  CorkDistrict
//
//  Created by Chris Larkin on 2/12/15.

import Foundation
import CoreData
import UIKit
import CoreLocation

class Singleton {
    
    let locationManager = CLLocationManager()
    var wineries = [NSManagedObject]()
    var restaurants = [NSManagedObject]()
    var accommodations = [NSManagedObject]()
    let geocoder = CLGeocoder()
    
    class var sharedInstance: Singleton {
        struct Static {
            static var instance: Singleton?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Singleton()
        }
        
        return Static.instance!
    }
    
    /*
        This method is called only once, from the viewDidLoad method in ViewController.swift.
        Call getWineries, getRestaurants, or getAccommodations through the singleton object to actually
        acquire the data in whatever view you are working with.
    */
    func loadData() -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Winery")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        let myImage = UIImage(named: "latahCreek.png")
        let myImage2 = UIImage(named: "patitCreek.png")
        
        if let results = fetchedResults {
            wineries = results
        }
        
        if (wineries.count == 0) {
            
            
            let winery = NSMutableArray(objects:
                "Whitestone Winery",
                "8 N Post",
                "99201",
                "Spokane, WA",
                "(509) 838-2427",
                "Whitestone Winery is proud to release estate wines exclusively showing the unique, favorable soil and weather conditions of the Whitestone Vineyard that is located on the shores of Lake Roosevelt. The winery produces limited quantities of premium handcrafted red wines. The winery is located 75 miles west of Spokane on US Hwy 2. Please call for tasting room hours.",
                "Winery")
            
            
            let winery2 = NSMutableArray(objects:
                "Barrister Winery",
                "1213 W Railroad Avenue",
                "99201",
                "Spokane, WA",
                "(509) 465-3591",
                "One of the Northwest's emerging superstar wineries, Barrister Winery is owned by two attorney/winemakers. Specializing in reds, our wines are available at the winery, from our mailing list or in selected fine restaurants and wine shops. Please visit our website to learn more about upcoming events, tours, new releases and hours of operation.",
                "Winery")
            
            let winery3 = NSMutableArray(objects:
                "Overbluff Cellars",
                "620 S Washington",
                "99204",
                "Spokane, WA",
                "(509) 991-4781",
                "",
                "Winery")
            
            let winery4 = NSMutableArray(objects:
                "Knipprath Cellars",
                "5634 E Commerce Avenue",
                "99212",
                "Spokane Valley, WA",
                "(509) 534-5121",
                "",
                "Winery")
            
            let winery5 = NSMutableArray(objects:
                "Liberty Lake Wine Cellars",
                "8 N Post",
                "99019",
                "Liberty Lake, WA",
                "(509) 255-9205",
                "Liberty Lake Wine Cellars produces small lots of hand crafted wine for those who seek out and appreciate limited edition wines. Specializing in single vineyard wines, we feature the fruit of the Red Mountain AVA. Open: Saturdays 1-5pm.",
                "Winery")
            
            let winery6 = NSMutableArray(objects:
                "Nodland Cellars",
                "11616 E Montgomery Dr, Ste 69",
                "99201",
                "Spokane, WA",
                "(509) 927-7770",
                "",
                "Winery")
            
            let winery7 = NSMutableArray(objects:
                "V du V Wines",
                "12 S Scott St",
                "99202",
                "Spokane, WA",
                "(509) 747-3200",
                "",
                "Winery")
            
            let winery8 = NSMutableArray(objects:
                "Barili Cellars",
                "608 W 2nd",
                "99201",
                "Spokane, WA",
                "(509) 979-5830",
                "Barili Cellars is an award-winning, boutique winery featuring small lots of hand-crafted wine. Opened in the spring of 2009, Spokane-based Barili features crisp white and rich reds from select vineyards in the Columbia Valley, served in a family-owned business atmosphere.",
                "Winery")
            
            let winery9 = NSMutableArray(objects:
                "Nectar Tasting Room",
                "120 N Stevens",
                "99201",
                "Spokane, WA",
                "(509) 869-1572",
                "Nectar Tasting Room is shared by five Washington wineries in the heart of downtown Spokane providing over 40 wines in one location. Visitors can enjoy wine from Anelare Winery, Hard Row to Hoe Vineyards, Northwest Cellars, Skylite Cellars, and Terra Blanca Winery. The 2000 square foot space is warm, modern and inviting. You’ll come in for a sip and end up staying for the whole bottle.",
                "Winery")
            
            let winery10 = NSMutableArray(objects:
                "Arbor Crest Wine Cellars",
                "4705 N Fruit Hill Rd",
                "99217",
                "Spokane, WA",
                "(509) 927-9463",
                "One of the state's oldest wineries producing award-winning Washington wines. Named one of “50 Great Producers Every Wine Lover Should Know” by Wine Spectator. The Cliff House Tasting Room, located on a National Historic Site perched atop a cliff offering spectacular views of the Spokane Valley, is open daily 12-5. Visit the website for details including the Summer Concert Series.",
                "Winery")
            
            let winery11 = NSMutableArray(objects:
                "Patit Creek Cellars",
                "822 W Sprague Ave",
                "99201", "Spokane, WA",
                "(509) 868-4045",
                "Located in the heart of the downtown entertainment district, our tasting room is the perfect place to kickoff or wind down your evening. Enjoy your favorite wines by the glass or share a bottle with friends. Featuring ten wines and a myriad of pairing experiences with locally-sourced, light cuisines. Live entertainment and special events monthly. Visit our website for details.",
                "Winery")
            
            let winery12 = NSMutableArray(objects:
                "Emvy Cellars",
                "39 W Pacific Avenue",
                "99201",
                "Spokane, WA",
                "(509) 838-7815",
                "We leave the wine flights up to you; choose to create your own adventure or let us be your guide. Try a gourmet cheese plate to pair with one of our elegant reds or refreshing whites and visit us on First Friday to enjoy your wine while listening to the tunes of local musicians.",
                "Winery")
            
            let winery13 = NSMutableArray(objects:
                "Latah Creek Wine Cellars",
                "13030 E Indiana",
                "99216",
                "Spokane, WA",
                "(509) 926-0164",
                "Latah Creek offers guests the opportunity to visit one of the most picturesque small wineries in the area. Latah Creek's award winning wines may be sampled at your leisure while you tour the adjoining winemaking facilities. Open Mon-Sun 9am to 5pm.",
                "Winery")
            
            let winery14 = NSMutableArray(objects:
                "Cougar Crest Estate Winery",
                "8 N Post",
                "99201",
                "Spokane, WA",
                "(509) 241-3850",
                "Cougar Crest Estate Winery was established at the Walla Walla Airport in 2001 by Deborah and David Hansen. Owners of 50 acres of vineyard, all in the Walla Walla Appellation, the move into making wine has been a natural progression for two people with strong backgrounds in science and a love of fine wine. The first vintage was 900 cases; the 2002 vintage will be 4000 cases.",
                "Winery")
            
            let winery15 = NSMutableArray(objects:
                "Townshend Cellar",
                "8022 E Green Bluff Rd",
                "99005",
                "Spokane, WA",
                "(509) 238-1400",
                "At Townshend Cellar we are dedicated to producing quality wines from the state of    Washington. Our wines derive their distinctive flavors from extensive oak aging in small French and American oak barrels and the selection of grapes from some of the finest vineyards in the Columbia Valley. We also produce a truly unique Huckleberry port-style wine made from Wild North Idaho Huckleberries.",
                "Winery")
            
            let winery16 = NSMutableArray(objects:
                "Robert Karl Cellar",
                "115 W Pacific Avenue",
                "99201",
                "Spokane, WA",
                "(509) 363-1353",
                "Nestled in an old fire station in the Historic Warehouse District, Robert Karl Cellars is a boutique winery dedicated to producing world class wines with grapes grown in Washington's new appellation, Horse Heaven Hills by physician Joseph Gunselman. Wine & Spirits recently selected Robert Karl as one of the Top 100 Wineries in the world.",
                "Winery")
            
            let winery17 = NSMutableArray(objects:
                "Bridge Press Cellars",
                "39 W Pacific Avenue",
                "99201",
                "Spokane, WA",
                "(509) 838-7815",
                "Bridge Press Cellars has the privilege of being Washington State’s 600th winery. We produce wines from some of Washington’s finest vineyards both in Walla Walla and the Columbia Valley. Small production lots allow us to select the best barrels for our signature Cabernet and Merlot blends. This spring we will be releasing our first rose just in time for summer sipping on the     patio.",
                "Winery")
            
            
            addEntity(winery, entityImage: myImage!)
            addEntity(winery2, entityImage: myImage!)
            addEntity(winery3, entityImage: myImage!)
            addEntity(winery4, entityImage: myImage!)
            addEntity(winery5, entityImage: myImage!)
            addEntity(winery6, entityImage: myImage!)
            addEntity(winery7, entityImage: myImage!)
            addEntity(winery8, entityImage: myImage!)
            addEntity(winery9, entityImage: myImage!)
            addEntity(winery10, entityImage: myImage!)
            addEntity(winery11, entityImage: myImage!)
            addEntity(winery12, entityImage: myImage!)
            addEntity(winery13, entityImage: myImage!)
            addEntity(winery14, entityImage: myImage!)
            addEntity(winery15, entityImage: myImage!)
            addEntity(winery16, entityImage: myImage!)
            addEntity(winery17, entityImage: myImage!)
        }
    }
    
    
    func addEntity(entityInfo: NSArray, entityImage: UIImage) -> Void {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var entityType = entityInfo[6] as NSString
        
        let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityType, inManagedObjectContext: managedContext) as NSManagedObject
        
        newEntity.setValue(UIImageJPEGRepresentation(entityImage, 1), forKey: "imageData")
        newEntity.setValue(entityInfo[0], forKey: "name")
        newEntity.setValue(entityInfo[1], forKey: "address")
        newEntity.setValue(entityInfo[2], forKey: "zipcode")
        newEntity.setValue(entityInfo[3], forKey: "city")
        newEntity.setValue(entityInfo[4], forKey: "phone")
        newEntity.setValue(entityInfo[5], forKey: "about")
        
        var address = entityInfo[1] as NSString
        
        geocoder.geocodeAddressString(address + ", WA, USA", {(placemarks: [AnyObject]!, error: NSError!) -> Void in
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
