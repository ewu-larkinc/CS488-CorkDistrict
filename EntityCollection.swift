//
//  EntityCollection.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/23/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

class EntityCollection {
    
    var cdCount: Int?
    var webCount: Int?
    var lastChangedWeb: String?
    var lastChangedCD: String?
    var loaded: Bool
    var type: LocationType
    var entities: [CorkDistrictEntity]
    var url: NSURL
    
    init(type: LocationType, url: NSURL) {
        self.type = type
        self.url = url
        entities = [CorkDistrictEntity]()
        loaded = false
    }
    
    func resetCDCount() {
        cdCount = nil
    }
    
    func resetWebCount() {
        webCount = nil
    }
    
    func resetLastChangedWeb() {
        lastChangedWeb = nil
    }
    
    func resetLastChangedCD() {
        lastChangedCD = nil
    }
    
    func isOutOfDate() -> Bool {
        
        guard let cdTotal = cdCount else {
            return true
        }
        
        if cdTotal == 0 {
            return true
        }
        
        if let webTotal = webCount {
            
            if cdTotal == webTotal {
                return false
            }
        }
        
        return true
    }
    
}