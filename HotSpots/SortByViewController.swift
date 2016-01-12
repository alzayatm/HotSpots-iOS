//
//  SortByViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 12/31/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit

class SortByViewController: UITableViewController {

    var oldIndexPath = NSIndexPath(forRow: 3, inSection: 0)
    let defaults = NSUserDefaults.standardUserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if String(defaults.objectForKey("SortBy")!) == "Most Populated" {
            
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .Checkmark
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .DisclosureIndicator
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.accessoryType = .DisclosureIndicator
            
            self.oldIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        } else if String(defaults.objectForKey("SortBy")!) == "Gender" {
            
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .Checkmark
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .None
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.accessoryType = .DisclosureIndicator
            
            self.oldIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        } else {
            
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.accessoryType = .Checkmark
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .None
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .DisclosureIndicator
            
            self.oldIndexPath = NSIndexPath(forRow: 2, inSection: 0)
        }
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            tableView.cellForRowAtIndexPath(self.oldIndexPath)?.accessoryType = .DisclosureIndicator
            defaults.setObject("", forKey: "SortByParams")
            self.oldIndexPath = indexPath
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            defaults.setObject("Most Populated", forKey: "SortBy")
        } else if indexPath.row == 1 {
            tableView.cellForRowAtIndexPath(self.oldIndexPath)?.accessoryType = .None
            self.oldIndexPath = indexPath
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            //defaults.setObject("Gender", forKey: "SortBy")
        } else {
            tableView.cellForRowAtIndexPath(self.oldIndexPath)?.accessoryType = .None
            self.oldIndexPath = indexPath
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            //defaults.setObject("Age", forKey: "SortBy")
        }
    
    }
    
    
    
}
