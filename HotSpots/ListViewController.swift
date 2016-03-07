//
//  ListViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 12/27/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit
import MapKit

class ListViewController: UITableViewController {

    var locationsObjectDictionary: NSMutableDictionary?
    var locationResults = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewConfig()
        self.addObjectDictionaryToLocationResults()
        self.navigationBarConfig()
        
    }
    
    
    func addObjectDictionaryToLocationResults() {
        
        for var i = 0; i < locationsObjectDictionary?["results"]!.count; i++ {
            
            if !(self.locationsObjectDictionary?["results"]![i] is NSNull) {
                
                locationResults.append(["BusinessName": locationsObjectDictionary!["results"]![i]["business_details"]!!["business_name"] as! String,
                    
                    "AverageAge": locationsObjectDictionary!["results"]![i]["business_details"]!!["average_age"] as! NSNumber,
                    
                    "BusinessAddress": locationsObjectDictionary!["results"]![i]["business_details"]!!["business_address"] as! String,
                    
                    "NumOfPeople": locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_people"] as! NSNumber,
                    
                    "NumOfFemales": locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_females"] as! NSNumber,
                    
                    "NumOfMales": locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_males"] as! NSNumber,
                    
                    "PercentMale": locationsObjectDictionary!["results"]![i]["business_details"]!!["percent_male"] as! NSNumber,
                    
                    "PercentFemale": locationsObjectDictionary!["results"]![i]["business_details"]!!["percent_female"] as! NSNumber,
                    
                    "Latitude": locationsObjectDictionary!["results"]![i]["coordinates"]!!["y"]!! as! CLLocationDegrees,
                    
                    "Longitude": locationsObjectDictionary!["results"]![i]["coordinates"]!!["x"]!! as! CLLocationDegrees])
            }
        }
    }
    
    func tableViewConfig() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomCell
        
        cell.businessNameLabel.text = String(locationResults[indexPath.row]["BusinessName"]!)
        cell.businessAddressLabel.text = String(locationResults[indexPath.row]["BusinessAddress"]!)
        cell.numOfPeopleLabel.text = String(locationResults[indexPath.row]["NumOfPeople"]!)
        cell.avgAgeLabel.text = String(locationResults[indexPath.row]["AverageAge"]!)
        cell.numOfMalesLabel.text = String(locationResults[indexPath.row]["NumOfMales"]!)
        cell.numOfFemalesLabel.text = String(locationResults[indexPath.row]["NumOfFemales"]!)
        
        
        return cell 
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationResults.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate 
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        self.performSegueWithIdentifier("Detail View", sender: nil)
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Detail View" {
            
            let cell = sender as? UITableViewCell
            let destinationViewController = segue.destinationViewController as! BusinessDetailViewController
            destinationViewController.title = cell?.textLabel?.text
            destinationViewController.businessDictionary = locationResults[0]
            destinationViewController.longitude = locationResults[(sender?.indexPath.row)!]["Longitude"] as! CLLocationDegrees
            destinationViewController.latitude = locationResults[(sender?.indexPath.row)!]["Latitude"] as! CLLocationDegrees
        }
    }
}
