//
//  CDEntity.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/19/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit


class CDEntity {
    
    var type: String
    var title: String
    var address: String
    var city: String
    var zip: String
    var phone: String
    var nodeID: String
    var typePlural: String
    
    var webAddress: String?
    var description: String?
    var image: UIImage?
    
    var cluster: String?
    var hours: String?
    var cardAccepted: String?
    
    //RESTAURANTS/ACCOMMODATIONS
    init(title: String, address: String, zip: String, phone: String, city: String, nodeID: String, webAddress: String, description: String, type: String, typePlural: String, image: UIImage) {
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
    init(type: String, title: String, address: String, city: String, zip: String, phone: String, nodeID: String, typePlural: String) {
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
    init(title: String, address: String, zip: String, phone: String, city: String, nodeID: String, webAddress: String, description: String, type: String, typePlural: String, image: UIImage, cluster: String, hours: String, cardAccepted: String) {
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
}