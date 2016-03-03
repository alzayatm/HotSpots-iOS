//
//  BusinessDetailView.swift
//  HotSpots
//
//  Created by mihad alzayat on 2/29/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class BusinessDetailView: UIView {
    
    override func drawRect(rect: CGRect) {
    
        // Get current context
        let context = UIGraphicsGetCurrentContext()
        
        // Set color
        CGContextSetStrokeColorWithColor(context, UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 1.0).CGColor)
        
        let rectangle = CGRectMake((frame.size.width / 3) - 50, (frame.size.height / 2) + 40,220,220)
        CGContextAddEllipseInRect(context,rectangle)
        
        // Set fill color
        CGContextSetFillColorWithColor(context, UIColor(red: 0.2, green: 0.4, blue: 0.5, alpha: 1.0).CGColor)
        
        CGContextFillPath(context)
        CGContextStrokePath(context)

    }
}
