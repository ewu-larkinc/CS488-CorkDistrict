//
//  CorkDistrictEntity.swift
//  TheCorkDistrict
//
//

import Foundation
import UIKit
import CoreData

class CorkDistrictEntity {
    
    var cdCount = Int(0)
    var webCount = Int(0)
    var type = String()
    var URL = NSURL()
    var needsWebUpdate = Bool()
    var entities = [NSManagedObject]()

    func clearEntities() {
        entities = [NSManagedObject]()
    }
    
}