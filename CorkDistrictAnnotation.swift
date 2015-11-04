//
//  CorkDistrictAnnotation.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/24/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum LocationType: Int {
    case Accommodation = 0
    case Package
    case Parking
    case Restaurant
    case Winery
}

protocol CorkDistrictAnnotation: MKAnnotation {
    
    var title: String? { get }
    var type: LocationType { get }
    var subtitle: String? { get }
    var phone: String { get }
    var coordinate: CLLocationCoordinate2D { get }
    var image: UIImage { get }
    
}