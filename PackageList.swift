//
//  PackageList.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/19/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

class PackageList {
    
    var cdCount: Int?
    var webCount: Int?
    var lastChangedWeb: String?
    var lastChangedCD: String?
    var type: String
    var items: [CDPackage]
    var url: NSURL
    
    init(type: String, url: NSURL) {
        self.type = type
        self.url = url
        items = [CDPackage]()
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