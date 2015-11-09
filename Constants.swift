//
//  Constants.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 11/8/15.
//  Copyright © 2015 Chris Larkin. All rights reserved.
//

import Foundation
import UIKit


class Constants {
    
    struct Colors {
        
        static let wineryColor = UIColor.init(red: 255.0, green: 81.0, blue: 55.0, alpha: 1.0)
        static let restaurantColor = UIColor.init(red: 244.0, green: 236.0, blue: 92.0, alpha: 1.0)
        static let accommodationColor = UIColor.init(red: 64.0, green: 178.0, blue: 177.0, alpha: 1.0)
        static let parkingColor = UIColor.init(red: 85.0, green: 110.0, blue: 145.0, alpha: 1.0)
    }

    struct URLStrings {
        
        static let Notifications = "http://www.corkdistrictapp.com/rest/push_notifications"
        static let Changelog = "http://www.corkdistrictapp.com/rest/all.json"
        static let Winery = "http://www.corkdistrictapp.com/rest/wineries.json"
        static let Restaurant = "http://www.corkdistrictapp.com/rest/restaurants.json"
        static let Accommodation = "http://www.corkdistrictapp.com/rest/lodging.json"
        static let Package = "http://www.corkdistrictapp.com/rest/packages.json"
        static let Parking = "http://www.corkdistrictapp.com/rest/parking.json"
    }
    
    struct CoreData {
        
        static let Title = "title"
        static let Website = "website"
        static let ImageData = "imageData"
        static let Placemark = "placemark"
        
        struct PackageAttributes {
            
            static let StartDay = "startDay"
            static let StartMonth = "startMonth"
            static let StartYear = "startYear"
            static let EndDay = "endDay"
            static let EndMonth = "endMonth"
            static let EndYear = "endYear"
            static let Cost = "cost"
            static let RelatedNodeID = "relatedNodeID"
        }
        
        struct EntityAttributes {
            
            static let Address = "address"
            static let Zipcode = "zipcode"
            static let Phone = "phone"
            static let City = "city"
            static let NodeID = "nodeID"
            static let Cluster = "cluster"
            static let Hours = "hours"
            static let CardAccepted = "cardAccepted"
            static let Description = "about"
            static let Type = "type"
        }
    }
    
    
    
    struct JSON {
        
        static let Title = "title"
        static let Thumbnail = "Thumbnail"
        static let UpdatedDate = "Updated_date"
        static let Count = "count"
        static let Website = "Website"
        
        struct PackageAttributes {
            
            static let StartDay = "StartDay"
            static let StartMonth = "StartMonth"
            static let StartYear = "StartYear"
            static let EndDay = "EndDay"
            static let EndMonth = "EndMonth"
            static let EndYear = "EndYear"
            static let Cost = "Cost"
            static let RelatedItems = "Related Items"
            static let TargetIndex = "target_id"
        }
        
        struct EntityAttributes {
            static let NodeID = "Nid"
            static let Address = "Street Address"
            static let CityStateZip = "City State Zip"
            static let Phone = "Phone"
            static let Description = "Description"
            static let Cluster = "Cluster"
            static let Hours = "Hours of Operation"
            static let CorkCardAccepted = "Cork District Card"
            static let Type = "Type"
        }
    }
    
}