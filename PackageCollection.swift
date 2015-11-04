//
//  PackageCollection.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/23/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

class PackageCollection {
    
    var cdCount: Int?
    var webCount: Int?
    var lastChangedWeb: String?
    var lastChangedCD: String?
    var items: [CorkDistrictPackage]
    var url: NSURL
    var loaded: Bool
    
    init(url: NSURL) {
        self.url = url
        items = [CorkDistrictPackage]()
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