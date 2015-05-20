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
    //var needsWebUpdate = Bool()
    var needsWebUpdate = true
    var entities = [NSManagedObject]()
    var lastChangedWeb = String()
    var lastChangedCD = String()

    func clearEntities() {
        entities = [NSManagedObject]()
    }
    
    func isOutOfDate() -> Bool {
        
        if (lastChangedCD == "") {
            println("Entity type \(self.type) is out of date!")
            return true
        }
        else if (lastChangedCD != lastChangedWeb && lastChangedCD != "" && lastChangedWeb != "") {
            println("Entity type \(self.type) is out of date!")
            return true
        }
        
        println("Entity type \(self.type) is NOT out of date!")
        return false
    }
    
}