//
//  CorkDistrictEntity.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/23/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class CorkDistrictEntity {
    
    var type: LocationType
    var title: String
    var address: String
    var city: String
    var zip: String
    var phone: String
    var nodeID: String
    var typePlural: String
    
    var coordinate: CLLocationCoordinate2D?
    var webAddress: String?
    var description: String?
    var image: UIImage?
    
    var cluster: String?
    var hours: String?
    var cardAccepted: String?
    
    /*static func setArtwork(imgName: String) {
        artwork = UIImage(named: imgName)
    }*/
    
    //RESTAURANTS/ACCOMMODATIONS
    init(title: String, address: String, zip: String, phone: String, city: String, nodeID: String, webAddress: String, description: String, type: LocationType, typePlural: String, image: UIImage) {
        self.type = type
        self.title = title
        self.address = address
        self.city = city
        self.zip = zip
        self.phone = phone
        self.nodeID = nodeID
        self.typePlural = typePlural
        
        self.webAddress = webAddress
        self.description = description
        self.image = image
    }
    
    //PARKING
    init(type: LocationType, title: String, address: String, city: String, zip: String, phone: String, nodeID: String, typePlural: String) {
        self.type = type
        self.title = title
        self.address = address
        self.city = city
        self.zip = zip
        self.phone = phone
        self.nodeID = nodeID
        self.typePlural = typePlural

    }
    
    //WINERIES
    init(title: String, address: String, zip: String, phone: String, city: String, nodeID: String, webAddress: String, description: String, type: LocationType, typePlural: String, image: UIImage, cluster: String, hours: String, cardAccepted: String) {
        self.type = type
        self.title = title
        self.address = address
        self.city = city
        self.zip = zip
        self.phone = phone
        self.nodeID = nodeID
        self.typePlural = typePlural
        
        self.webAddress = webAddress
        self.description = description
        self.image = image
        self.cluster = cluster
        self.hours = hours
        self.cardAccepted = cardAccepted
    }
    
    func setCoordinate(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }

}