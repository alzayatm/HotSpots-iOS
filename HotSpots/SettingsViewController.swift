//
//  SettingsViewController.swift
//  HotSpots
//
//  Created by Mihad Alzayat on 11/6/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var sortByLabel: UILabel!
    @IBOutlet weak var sortByParametersLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBarConfig()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setSortByOption()
        self.setUserDetails()
    }
   
    func navigationBarConfig() {
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.title = "Settings"
        self.navigationItem.leftBarButtonItem?.title = "Done"
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setUserDetails() {
        self.genderLabel.text = String(defaults.objectForKey("Gender")!)
        self.ageLabel.text = String(defaults.objectForKey("Age")!)
    }
    
    func setSortByOption() {
        
        if String(defaults.objectForKey("SortBy")!) == "Most Populated" {
            
            self.sortByLabel.text = "Most Populated"
            self.sortByParametersLabel.text = String(defaults.objectForKey("SortByParams")!)
            
        } else if String(defaults.objectForKey("SortBy")!)  ==  "Gender" {
            
            self.sortByLabel.text = "Gender"
            self.sortByParametersLabel.text = String(defaults.objectForKey("SortByParams")!)
            
        } else {
            
            self.sortByLabel.text = "Age"
            self.sortByParametersLabel.text = String(defaults.objectForKey("SortByParams")!)
        }
    }
}
