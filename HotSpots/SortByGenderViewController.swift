//
//  SortByGenderViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/1/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class SortByGenderViewController: UITableViewController {

    var oldIndexPath = NSIndexPath(forRow: 3, inSection: 0)
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if String(defaults.objectForKey("SortByParams")!) == "" || String(defaults.objectForKey("SortByParams")!) == "16 - 21" || String(defaults.objectForKey("SortByParams")!) == "22 - 28" || String(defaults.objectForKey("SortByParams")!) == "29 - 35" || String(defaults.objectForKey("SortByParams")!) == "36 - 45" || String(defaults.objectForKey("SortByParams")!) == "46 - 65" || String(defaults.objectForKey("SortByParams")!) == "65+" {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .None
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .None
            
        } else if String(defaults.objectForKey("SortByParams")!) == "Female"{
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .Checkmark
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .None
            
            self.oldIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        } else {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .Checkmark
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .None
            
            self.oldIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        }
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defaults.setObject("Gender", forKey: "SortBy")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.oldIndexPath != indexPath {
            
            tableView.cellForRowAtIndexPath(oldIndexPath)?.accessoryType = .None
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            
            let label = tableView.cellForRowAtIndexPath(indexPath)?.contentView.subviews[0] as! UILabel
            defaults.setObject(label.text, forKey: "SortByParams")
        
        }
        
        
        self.oldIndexPath = indexPath
    }

}
