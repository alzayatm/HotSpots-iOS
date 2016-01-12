//
//  CustomUITableView.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/8/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class CustomUITableView: UITableView {

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.endEditing(true)
    }

}
