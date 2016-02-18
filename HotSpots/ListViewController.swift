//
//  ListViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 12/27/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBarConfig()
    }

    func navigationBarConfig() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.2, green: 0.5, blue: 1, alpha: 0.5)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "Map")
        self.navigationItem.leftBarButtonItem?.title = nil
        self.navigationItem.title = "List View"
    }
    
    @IBAction func mapViewbutton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
