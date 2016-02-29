//
//  BusinessDetailView.swift
//  HotSpots
//
//  Created by Mihad Alzayat on 11/5/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit

class BusinessDetailView: UIViewController {

    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    @IBOutlet weak var averageAgeLabel: UILabel!
    @IBOutlet weak var numOfMalesLabel: UILabel!
    @IBOutlet weak var numOfFemalesLabel: UILabel!
    @IBOutlet weak var percentFemaleLabel: UILabel!
    @IBOutlet weak var percentMaleLabel: UILabel!
    
    
    var numOfPeople: String! 
    var averageAge: String!
    var numOfFemales: String!
    var numOfMales: String!
    var percentFemale: String!
    var percentMale: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberOfPeopleLabel.text = numOfPeople
        averageAgeLabel.text = averageAge
        numOfMalesLabel.text = numOfMales
        numOfFemalesLabel.text = numOfFemales
        percentMaleLabel.text = percentMale
        percentFemaleLabel.text = percentFemale
        
        
    }

}
