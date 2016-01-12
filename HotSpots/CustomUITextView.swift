//
//  CustomUITextView.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/8/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class CustomUITextView: UITextView {

    // To block the user from altering the text view
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }

}
