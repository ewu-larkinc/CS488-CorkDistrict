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
    var needsWebUpdate = true
    var entities = [NSManagedObject]()
    var lastChangedWeb = String()
    var lastChangedCD = String()

    func clearEntities() {
        entities = [NSManagedObject]()
    }
    
    func doChangedDatesMatch() -> Bool {
        return lastChangedCD == lastChangedWeb
    }
    
    func doCountsMatch() -> Bool {
        return cdCount == webCount
    }
    
    func isOutOfDate() -> Bool {
        
        println("In isOutOfDate method cdCount is \(cdCount) and webcount is \(webCount)")
        
        if (lastChangedCD == "") {
            println("Entity type \(self.type) out of date! (NO DATE STORED IN CORE DATA)")
            println("lastChangedCD is \(lastChangedCD) and lastChangedWeb is \(lastChangedWeb)")
            return true
        }
        else if (cdCount != webCount) {
            println("Entity type \(self.type) out of date! (WEB COUNT IS DIFFERENT FROM CORE DATA COUNT)")
            return true
        }
        else if (lastChangedCD != lastChangedWeb && lastChangedCD != "" && lastChangedWeb != "") {
            println("Entity type \(self.type) out of date! (LASTCHANGED VALUE HAS CHANGED ON WEBSITE)")
            return true
        }
        
        println("Entity type \(self.type) NOT out of date!")
        return false
    }
    
    func setWebCount(count: Int) {
        webCount = count
    }
    
    func setCDCount(count: Int) {
        cdCount = count
    }
    
}