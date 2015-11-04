//
//  CorkDistrictPackage.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/23/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

class CorkDistrictPackage {
    
    var title: String
    var cost: String
    var startDay: String
    var startMonth: String
    var startYear: String
    var endDay: String
    var endMonth: String
    var endYear: String
    var relatedNodeID: String
    var webAddress: String
    var image: UIImage
    
    init(title: String, cost: String, startDay: String, startMonth: String, startYear: String, endDay: String, endMonth: String, endYear: String, relatedNodeID: String, webAddress: String, image: UIImage) {
        self.title = title
        self.cost = cost
        self.startDay = startDay
        self.startMonth = startMonth
        self.startYear = startYear
        self.endDay = endDay
        self.endMonth = endMonth
        self.endYear = endYear
        self.relatedNodeID = relatedNodeID
        self.webAddress = webAddress
        self.image = image
    }
}