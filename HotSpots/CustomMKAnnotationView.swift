//
//  CustomMKAnnotationView.swift
//  HotSpots
//
//  Created by mihad alzayat on 3/3/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import Foundation
import MapKit

class CustomMKAnnotationView: MKAnnotationView {
    
    var numOfPeopleLabel: UILabel?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //let customPin = annotation as! CustomPin
        //numOfPeople = customPin.businessDictionary!["numOfPeople"] as? Int
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
     override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
}