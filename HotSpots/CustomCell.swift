//
//  CustomCell.swift
//  HotSpots
//
//  Created by mihad alzayat on 3/7/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var numOfFemalesLabel: UILabel!
    @IBOutlet weak var numOfMalesLabel: UILabel!
    @IBOutlet weak var avgAgeLabel: UILabel!
    @IBOutlet weak var numOfPeopleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
