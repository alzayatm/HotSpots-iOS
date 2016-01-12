//
//  CustomUITextField .swift
//  HotSpots
//
//  Created by mihad alzayat on 12/25/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import Foundation
import UIKit

// A class that extends UITextField to block user from pasting into a UITextField
class CustomUITextField: UITextField {
   
    // To block the user from altering the text field
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
    
}
