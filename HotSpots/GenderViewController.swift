//
//  GenderViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/6/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class GenderViewController: UITableViewController {

    var oldIndexPath = NSIndexPath(forRow: 2, inSection: 0)
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if String(defaults.objectForKey("Gender")!) == "Male" {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .Checkmark
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .None
            
            self.oldIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        } else {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .None
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = .Checkmark
            
            self.oldIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.oldIndexPath != indexPath {
            tableView.cellForRowAtIndexPath(oldIndexPath)?.accessoryType = .None
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            
            let label = tableView.cellForRowAtIndexPath(indexPath)?.contentView.subviews[0] as! UILabel
            defaults.setObject(label.text, forKey: "Gender")
            
        }
        
        self.oldIndexPath = indexPath
    }

   

}
