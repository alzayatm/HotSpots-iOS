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
            print("Before setting gender \(defaults.objectForKey("Gender"))")
            defaults.setObject(label.text, forKey: "Gender")
            print("After setting Gender \(defaults.objectForKey("Gender"))")
            self.updateGenderReq()
        }
        
        self.oldIndexPath = indexPath
    }

    func updateGenderReq() {
    
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let URL = NSURL(string: "http://api.hotspotsapp.us/updategender")
        let request = NSMutableURLRequest(URL: URL!)
        
        // Configuring the request
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(KeychainManager.stringForKey("token")! as String, forHTTPHeaderField: "Authorization")
      
        
        // Parameters sent to the server
        var gender = String()
        String(defaults.valueForKey("Gender")!) == "Male" ? (gender = "M") : (gender = "F")
        print("Gender set as: \(gender)")
        let params: [String: AnyObject] = ["gender": gender, "userID": KeychainManager.stringForKey("userID")!]
        
        // Turning your data into JSON format and storing in HTTP request body
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            print("Error serializing data with json object")
        }
        
        // Making a request over the network with request
        // Returns data, response, error objects
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            // Checking HTTP Response in case of error
            let httpResponse = response as? NSHTTPURLResponse
            
            if httpResponse?.statusCode != 200 {
                print(httpResponse?.statusCode)
            }
            
            // Checking if error is nil
            if error != nil {
                print("Localized description error: \(error?.localizedDescription)")
            }
        }
        
        // Start the session
        task.resume()
    }

}
