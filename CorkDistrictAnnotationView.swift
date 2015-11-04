//
//  CorkDistrictAnnotationView.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/24/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CorkDistrictAnnotationView: MKAnnotationView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let corkDistrictAnnotation = self.annotation as! CorkDistrictAnnotation
        
        switch (corkDistrictAnnotation.type) {
            case .Accommodation:
                image = UIImage(named: "accommodationIcon")
            case .Parking:
                image = UIImage(named: "parkingIcon")
            case .Restaurant:
                image = UIImage(named: "restaurantIcon")
            case .Winery:
                image = UIImage(named: "wineryIcon")
            default:
                break
        }
        
    }
}
