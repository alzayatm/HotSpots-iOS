//
//  CustomUIScrollView.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/8/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class CustomUIScrollView: UIScrollView {

    // To dismiss keyboard when user touches outside of textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.endEditing(true)
    }
}
