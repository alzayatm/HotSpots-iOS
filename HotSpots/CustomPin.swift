//
//  CustomPin.swift
//  HotSpots
//
//  Created by Mihad Alzayat on 10/23/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import Foundation
import MapKit

class CustomPin: NSObject, MKAnnotation {
    
    var title: String? 
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

