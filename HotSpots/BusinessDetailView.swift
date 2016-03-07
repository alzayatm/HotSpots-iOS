//
//  BusinessDetailView.swift
//  HotSpots
//
//  Created by mihad alzayat on 2/29/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

struct Segment {
    
    init(aColor: UIColor, aName: String, aValue: CGFloat) {
        self.color = aColor
        self.value = aValue
        
        if aValue == 0 {
            self.name = ""
        } else {
            self.name = aName
        }
    }
    
    // The color of the segment
    var color : UIColor
    
    // The name of the segment
    var name : String
    
    // The value of the segment
    var value : CGFloat
}

class BusinessDetailView: UIView {
    
    
    var segments = [Segment]() {
        didSet {
            self.setNeedsDisplay() // re-draw view when the values get set
        }
    }
    
    /// Defines whether the segment labels should be shown when drawing the pie chart
    var showSegmentLabels = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The font to be used on the segment labels
    var segmentLabelFont = UIFont.systemFontOfSize(20) {
        didSet {
            textAttributes[NSFontAttributeName] = segmentLabelFont
            self.setNeedsDisplay()
        }
    }
    
    private lazy var paragraphStyle:NSParagraphStyle = {
        var p = NSMutableParagraphStyle()
        p.alignment = .Center
        return p.copy() as! NSParagraphStyle
    }()
    
    private lazy var textAttributes:[String:AnyObject] = {
        return [NSParagraphStyleAttributeName:self.paragraphStyle, NSFontAttributeName:self.segmentLabelFont]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = false // when overriding drawRect, you must specify this to maintain transparency.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        
        // get current context
        let ctx = UIGraphicsGetCurrentContext()
        
        // radius is the half the frame's width or height (whichever is smallest)
        let radius = ((frame.width < frame.height) ? frame.width:frame.height)*0.5
        
        // center of the view
        let viewCenter = CGPoint(x: bounds.size.width*0.5, y: bounds.size.height*0.5)
        
        // enumerate the total value of the segments (by first generating an array of CGFloat values from the tuple, then using reduce to sum them)
        let valueCount = segments.map{$0.value}.reduce(0, combine: +)
        
        // the starting angle is -90 degrees (top of the circle, as the context is flipped). By default, 0 is the right hand side of the circle, with the positive angle being in an anti-clockwise direction (same as a unit circle in maths).
        var startAngle:CGFloat = -CGFloat(M_PI*0.5)
        
        // loop through the values array
        for segment in segments {
            
            // set fill color to the segment color
            CGContextSetFillColorWithColor(ctx, segment.color.CGColor)
            
            // update the end angle of the segment
            let endAngle = startAngle+CGFloat(M_PI*2)*(segment.value/valueCount)
            
            // move to the center of the pie chart
            CGContextMoveToPoint(ctx, viewCenter.x, viewCenter.y)
            
            // add arc from the center for each segment (anticlockwise is specified for the arc, but as the view flips the context, it will produce a clockwise arc)
            CGContextAddArc(ctx, viewCenter.x, viewCenter.y, radius, startAngle, endAngle, 0)
            
            // fill segment
            CGContextFillPath(ctx)
            
            if showSegmentLabels { // do text rendering
                
                // get the angle midpoint
                let halfAngle = startAngle+(endAngle-startAngle)*0.5;
                
                // get the 'center' of the segment. It's slightly biased to the outer edge, as it's wider.
                let segmentCenter = CGPoint(x: viewCenter.x+radius*0.65*cos(halfAngle), y: viewCenter.y+radius*0.65*sin(halfAngle))
                
                // text to render, as an explicit NSString
                let textToRender : NSString = segment.name
                
                // get the color components of the segement color
                let colorComponents = CGColorGetComponents(segment.color.CGColor)
                
                // get the average brightness of the color
                let averageRGB = (colorComponents[0]+colorComponents[1]+colorComponents[2])/3.0
                
                if averageRGB > 0.7 { // if too light, use black. If too dark, use white
                    textAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
                } else {
                    textAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
                }
                
                // the bounds that the text will occupy
                var renderRect = CGRect(origin: CGPointZero, size: textToRender.sizeWithAttributes(textAttributes))
                
                // center the origin of the rect
                renderRect.origin = CGPoint(x: segmentCenter.x-renderRect.size.width*0.5, y: segmentCenter.y-renderRect.size.height*0.5)
                
                // draw text in the rect, with the given attributes
                textToRender.drawInRect(renderRect, withAttributes: textAttributes)
            }
            
            // update starting angle of the next segment to the ending angle of this segment
            startAngle = endAngle
        }
    }
}
