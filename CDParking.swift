//
//  CDParking.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/19/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

class CDParking {
    
    var title: String
    var address: String
    var phone: String
    var city: String
    var zip: String
    var nodeID: String
    
    init(title: String, address: String, phone: String, zip: String, city: String, nodeID: String) {
        self.title = title
        self.address = address
        self.zip = zip
        self.phone = phone
        self.city = city
        self.nodeID = nodeID
    }
    
}