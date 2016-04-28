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
        
        if locationsObjectDictionary?.count > 0 {
        for var i = 0; i < locationsObjectDictionary?["results"]!.count; i += 1 {
            
            if !(self.locationsObjectDictionary!["results"]![i] as AnyObject is NSNull) {
                
                locationResults.append(["businessName": locationsObjectDictionary!["results"]![i]["business_details"]!!["business_name"] as! String,
                    
                    "averageAge": locationsObjectDictionary!["results"]![i]["business_details"]!!["average_age"] as! NSNumber,
                    
                    "businessAddress": locationsObjectDictionary!["results"]![i]["business_details"]!!["business_address"] as! String,
                    
                    "numOfPeople": locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_people"] as! NSNumber,
                    
                    "numOfFemales": locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_females"] as! NSNumber,
                    
                    "numOfMales": locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_males"] as! NSNumber,
                    
                    "percentMale": locationsObjectDictionary!["results"]![i]["business_details"]!!["percent_male"] as! NSNumber,
                    
                    "percentFemale": locationsObjectDictionary!["results"]![i]["business_details"]!!["percent_female"] as! NSNumber,
                    
                    "Latitude": locationsObjectDictionary!["results"]![i]["coordinates"]!!["y"]!! as! CLLocationDegrees,
                    
                    "Longitude": locationsObjectDictionary!["results"]![i]["coordinates"]!!["x"]!! as! CLLocationDegrees])
            }
        }
        }
    }
    
    func tableViewConfig() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func navigationBarConfig() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 0.5)
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
        
        cell.businessNameLabel.text = String(locationResults[indexPath.row]["businessName"]!)
        cell.businessAddressLabel.text = String(locationResults[indexPath.row]["businessAddress"]!)
        cell.numOfPeopleLabel.text = String(locationResults[indexPath.row]["numOfPeople"]!)
        cell.avgAgeLabel.text = String(locationResults[indexPath.row]["averageAge"]!)
        cell.numOfMalesLabel.text = String(locationResults[indexPath.row]["numOfMales"]!)
        cell.numOfFemalesLabel.text = String(locationResults[indexPath.row]["numOfFemales"]!)
        
        let pieChartView = BusinessDetailView()
        pieChartView.frame = CGRectMake(240, 14, 75, 71)
        // 267, 14, 75, 71
        
    
        pieChartView.segments = [
            Segment(aColor: UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 1.0), aName: "", aValue: locationResults[indexPath.row]["percentMale"] as! CGFloat),
            Segment(aColor: UIColor(red: 250/255, green: 114/255, blue: 208/255, alpha: 1), aName: "", aValue: locationResults[indexPath.row]["percentFemale"] as! CGFloat)
        ]
        
        cell.addSubview(pieChartView)
        
        
        return cell 
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationResults.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate 
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("Detail View", sender: tableView)
    }

    

    // MARK: - PrepareForSegue 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Detail View" {
            
            let destinationViewController = segue.destinationViewController as! BusinessDetailViewController
            let path = (sender as! UITableView).indexPathForSelectedRow
    
            destinationViewController.title = String(locationResults[(path?.row)!]["businessName"]!)
            destinationViewController.businessDictionary = locationResults[(path?.row)!] as [String: AnyObject]
            destinationViewController.longitude = locationResults[(path?.row)!]["Longitude"] as! CLLocationDegrees
            destinationViewController.latitude = locationResults[(path?.row)!]["Latitude"] as! CLLocationDegrees
        }
    }
}
