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
    
    struct Color {
        
        static let wineryColor = UIColor.init(red: 255.0, green: 81.0, blue: 55.0, alpha: 1.0)
        static let restaurantColor = UIColor.init(red: 244.0, green: 236.0, blue: 92.0, alpha: 1.0)
        static let accommodationColor = UIColor.init(red: 64.0, green: 178.0, blue: 177.0, alpha: 1.0)
        static let parkingColor = UIColor.init(red: 85.0, green: 110.0, blue: 145.0, alpha: 1.0)
    }

    struct URL {
        
        static let PhoneBase = "tel://"
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
            
            static let StrtDay = "startDay"
            static let StrtMnth = "startMonth"
            static let StrtYr = "startYear"
            static let EndDay = "endDay"
            static let EndMnth = "endMonth"
            static let EndYr = "endYear"
            static let Cost = "cost"
            static let RelatedNID = "relatedNodeID"
        }
        
        struct EntityAttributes {
            
            static let Addr = "address"
            static let Zip = "zipcode"
            static let Phn = "phone"
            static let Cty = "city"
            static let NID = "nodeID"
            static let Clstr = "cluster"
            static let Hrs = "hours"
            static let Card = "cardAccepted"
            static let Dscrpt = "about"
            static let Type = "type"
        }
    }
    
    struct EntityType {
        
        static let Acom = "Accommodation"
        static let Wne = "Winery"
        static let Rst = "Restaurant"
        static let Prk = "Parking"
        static let Pkg = "Package"
    }
    
    struct Resources {
    
        struct ImageString {
            
            static let WineIcon = "wineryIcon"
            static let DestinationIcon = "finishTag"
            static let RestIcon = "restaurantIcon"
            static let AccommIcon = "accommodationIcon"
            static let ParkIcon = "parkingIcon"
        }
    }
    
    struct AlertAction {
        
        static let Call = "Call"
        static let Cancel = "Cancel"
        static let Details = "View Details"
        static let Directions = "Get Directions"
    }
    
    struct JSON {
        
        static let Title = "title"
        static let Thumbnail = "Thumbnail"
        static let UpdatedDate = "Updated_date"
        static let Count = "count"
        static let Website = "Website"
        
        struct PackageAttributes {
            
            static let StrtDay = "StartDay"
            static let StrtMnth = "StartMonth"
            static let StrtYr = "StartYear"
            static let EndDay = "EndDay"
            static let EndMnth = "EndMonth"
            static let EndYr = "EndYear"
            static let Cost = "Cost"
            static let RelItems = "Related Items"
            static let TargetIndex = "target_id"
        }
        
        struct EntityAttributes {
            static let NodeID = "Nid"
            static let Addr = "Street Address"
            static let CtyStZip = "City State Zip"
            static let Phn = "Phone"
            static let Dscrpt = "Description"
            static let Clstr = "Cluster"
            static let Hrs = "Hours of Operation"
            static let CorkCard = "Cork District Card"
            static let Type = "Type"
        }
    }
    
}