//
//  ParkingAnnotation.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/28/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ParkingAnnotation: NSObject, CorkDistrictAnnotation, MKAnnotation {
    
    var title: String?
    var type: LocationType
    var subtitle: String?
    var phone: String
    var coordinate: CLLocationCoordinate2D
    var image: UIImage
    
    
    init(title: String, coordinate: CLLocationCoordinate2D, phone: String) {
        
        self.title = title
        self.subtitle = "Parking"
        self.coordinate = coordinate
        self.phone = phone
        self.type = LocationType.Parking
        self.image = UIImage(named: "parkingIcon")!
    }
}