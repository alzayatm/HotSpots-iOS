//
//  ViewController.swift
//  HotSpots
//
//  Created by Mihad Alzayat on 10/14/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {

    // Map
    @IBOutlet weak var mapView: MKMapView!
    
    // Location Manager that manages users location
    let locationManager = CLLocationManager()
    
    // The controller that will manage the search
    var searchController: UISearchController!
    
    // Array of locations returned as search results
    var searchResults = [MKMapItem]()
    
    // Filter the search results for
    var filteredSearchResults = [MKMapItem]()
    
    // Table view controller that will manage displaying the results
    var tableViewController = UITableViewController()
    
    // Address dictionary with details about the location
    var addressDictionary = [NSObject: AnyObject]()

    // An array to store each locations address from dictionary
    var streetAddresses = [String]()

    var firstLocationUpdate = true
    
    // Button refreshing map view
    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLocation()
        self.mapViewConfig()
        self.searchControllerConfig()
        self.navigationBarConfig()
        self.refreshButtonConfig()
        
        self.tableViewController.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.definesPresentationContext = true
    }
    
    // Configure the map view
    func mapViewConfig() {
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.pitchEnabled = false
        self.mapView.rotateEnabled = false
    }
    
    // Configure the location of the user
    func configureLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            
            // Distance filter to update location
            locationManager.distanceFilter = 8
            
            // Begin updating user location
            locationManager.startUpdatingLocation()
            
        } else {
            
            let title = "Location disabled"
            let message = "To enable location services go to Settings > Privacy > Location Services"
            self.locationServicesAlertMessage(title, message: message)
        }
    }
    
    // MARK: - UISearchController

    func searchControllerConfig() {
        
        searchController = UISearchController(searchResultsController: tableViewController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
        
        searchController.definesPresentationContext = true
        
        self.tableViewController.tableView.dataSource = self
        self.tableViewController.tableView.delegate = self
        
        self.mapView.addSubview(searchController.searchBar)
        
    }
    
    // MARK: - UINavigationItem
    
    func navigationBarConfig() {
        
        // Navigation bar logo
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.image = UIImage(named: "NavigationTitleLogo")
        
        self.navigationItem.titleView = imageView // UIImageView(image: UIImage(named: "NavigationTitleLogo"))
        
        // First right location navigation item button
        navigationItem.rightBarButtonItems![0].image = UIImage(named: "Location")
        navigationItem.rightBarButtonItems![0].tintColor =  UIColor.whiteColor()
        
        // Second right location navigation item button
        navigationItem.rightBarButtonItems![1].image = UIImage(named: "List")
        navigationItem.rightBarButtonItems![1].tintColor =  UIColor.whiteColor()
        
        // First left location navigation item button
        navigationItem.leftBarButtonItem?.image = UIImage(named: "Gear")
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    
        navigationItem.title = nil
    }
    
    // Styling the refresh button
    func refreshButtonConfig() {
        
        // Makes the button a circle
        self.refreshButton.frame = CGRectMake(160, 100, 50, 50)
        self.refreshButton.layer.cornerRadius = 0.5 * refreshButton.bounds.size.width
        
        // Changes the tint color to white
        self.refreshButton.tintColor = UIColor.whiteColor()
        
        // Sets the image within the button
        self.refreshButton.setImage(UIImage(named: "Refresh"), forState: .Normal)
        self.refreshButton.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 1.0)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // When user changes tracking permissions delegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        // Message and title that will be passed to custom func locationServicesAlertMessage
        let message: String = "You must turn on location services for this app to use it. Go to Settings > Privacy > Location Services."
        let title: String
        
        if status == .Denied {
            title = "Location services disabled"
            self.locationServicesAlertMessage(title, message: message)
            
        } else  if status == .Restricted {
            title = "Location services restricted"
            self.locationServicesAlertMessage(title, message: message)
            
        } else if status == .AuthorizedWhenInUse {
            title = "Always authorization required"
            self.locationServicesAlertMessage(title, message: message)
            
        } else if status == .AuthorizedAlways {
            self.configureLocation()
            
        } else { // Not Determined - Try to configure location again
            self.configureLocation()
        }
        
    }
    
    // Delegate method updating user location based on set criteria 
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        print(manager.location?.coordinate.latitude)
        print(manager.location?.coordinate.longitude)
        // Get last updated location
        let location = locations.last
        
        if firstLocationUpdate {
            let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
            
            self.mapView.setRegion(region, animated: true)
            
            self.firstLocationUpdate = false
        }
        
        self.updateLongAndLat(location!)
    }
    
    // Location cannot be retrieved delegate method
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        //print("Error: \(error.localizedDescription)")
        //print("Internet issue")
    }

    func updateLongAndLat(location: CLLocation) {
        
        // Configuration for session object
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Initialize session object with its configuration
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        // The URL which the endpoint can be found at
        let URL = NSURL(string: "http://localhost:3000/updatelocation")
        
        // Initialize the request with the URL
        let request = NSMutableURLRequest(URL: URL!)
        
        // Configuring the request
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(KeychainManager.stringForKey("token")! as String, forHTTPHeaderField: "Authorization")
        
        // Parameters sent to the server
        let params: [String: AnyObject] = ["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude]
        
        // Turning your data into JSON format and storing in HTTP request body
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print("Error serializing data with json object")
        }
        
        // Making a request over the network with request
        // Returns data, response, error objects
        let task = session.dataTaskWithRequest(request)
        
        // Start the session
        task.resume()
    }
    
    // Helper method to didChangeAuthorization status
    func locationServicesAlertMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (alertAction) -> Void in
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    // Action for top right button (centers on user)
    @IBAction func positionOnUser(sender: UIBarButtonItem) {
    
        self.mapView.setCenterCoordinate((locationManager.location?.coordinate)!, animated: true)
        
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }
   
    
    // MARK: - UISearchControllerDelegate 
    
    func presentSearchController(searchController: UISearchController) {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        searchController.searchBar.barTintColor = UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 0.5)
        
        // Changing the color of the search bar's cancel button to white
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor.whiteColor()
    }
    
    // Change the color of the search bar belonging to the search controller back to default
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.barTintColor = .None
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // might have subclass UITableViewCell
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = searchResults[indexPath.row].name
        
        cell.detailTextLabel?.text = self.streetAddresses[indexPath.row]
        
        return cell
    }
    
    // Number of rows in the table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let mapItem = self.searchResults[indexPath.row]
        
        searchController.active = false
        
        let pin = CustomPin(title: mapItem.name!, subtitle: self.streetAddresses[indexPath.row], coordinate: mapItem.placemark.coordinate)
        
        mapView.addAnnotation(pin)
        mapView.selectAnnotation(pin, animated: true)
    
        // (mapItem.placemark.location?.coordinate)!
        mapView.setCenterCoordinate(pin.coordinate, animated: false)
        mapView.setUserTrackingMode(.None, animated: false)
        
       return indexPath
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.searchQuery(searchController.searchBar.text!)
        self.tableViewController.tableView.reloadData()
    }
    
    // MARK: - MKLocalSearch 
    
    func searchQuery(query: String) {
        
        // request
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // search 
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if(error != nil) {
                
                print(error?.localizedDescription)
                
            } else {
                
                // remove values from dictionary and array to populate with new data
                self.addressDictionary.removeAll(keepCapacity: false)
                self.streetAddresses.removeAll(keepCapacity: false)
                
                // storing data about location in dictionary
                for item in (response?.mapItems)! {
                    
                    // Storing map item address details into dictionary
                    self.addressDictionary = item.placemark.addressDictionary!
                    
                    // taking street value out of dictionary and storing in array
                    self.streetAddresses.append(self.addressDictionary["Street"] as? String ?? "")
                    
                }
                
                // storing the array of mkmapitems in the array
                self.searchResults = (response?.mapItems)!
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    /*
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //self.searchQuery(searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //self.searchQuery(searchText)
    }
    */
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Return nil if the annotation is the user's location
        if annotation.isKindOfClass(MKUserLocation) { return nil }
        
        // Attempt to reuse pins that were active
        // Create a custom annotation view if nil 
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        // when there is no pin to reuse
        if annotationView == nil {
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView?.centerOffset = CGPoint(x: 0, y: -25)
            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named: "Pin")
            
            // Left call out image
            let leftCallOutPicture = UIImage(named: "")
            annotationView?.leftCalloutAccessoryView = UIImageView(image:leftCallOutPicture)
        
            // Right call out button
            let rightCallOutButton = UIButton(type: UIButtonType.DetailDisclosure)
            annotationView?.rightCalloutAccessoryView = rightCallOutButton
        
        } else {
            annotationView!.annotation = annotation
        }
    
        return annotationView
    }
    
    // Segue to tableView when call out is clicked
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Segue to Business detail view
        self.performSegueWithIdentifier("Detail View", sender: view)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // update the pins when the region is changed
        // fetch information from back end and update pins
        
        /*
        let coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 38.109438, longitude: -77.684032), CLLocationCoordinate2D(latitude: 38.405932, longitude: -77.293043), CLLocationCoordinate2D(latitude: 38.742739, longitude: -77.333333), CLLocationCoordinate2D(latitude: 38.925229, longitude: -77.036133), CLLocationCoordinate2D(latitude: 38.404494, longitude: -77.404392)]
        
        var pins = [CustomPin]()
        
        
        for var i = 0; i < coordinates.count; i++ {
        
        pins.append(CustomPin(title: "Pin\(i)", subtitle: "Hello", coordinate: coordinates[i]))
        
        }
        mapView.addAnnotations(pins)
        */
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Detail View" {
            let point = (sender as? MKAnnotationView)?.annotation
            let tableViewController = segue.destinationViewController as! UITableViewController
            tableViewController.title = (point?.title)!
        
        }
      
    }
    
    // MARK: - Navigation bar button presentation functions
    
    @IBAction func listView(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewControllerWithIdentifier("List View")
        
        listViewController.modalTransitionStyle = .FlipHorizontal
        let navController = UINavigationController(rootViewController: listViewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func settingsView(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = storyboard.instantiateViewControllerWithIdentifier("Settings View")
        
        let navController = UINavigationController(rootViewController: settingsViewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    // MARK: - Provide Hotspots function
    
    // This function retrieves a list of hotspots based on the users location 
    func fetchHotSpots() {
        // Either send the region of the viewable map
        // Turn the viewable map into coordinates
        // Returns json data (dictionary)
    }
    
    
    // MARK: - NSURLSessionDelegate
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("URL SESSION DID FINISH EVENTS FOR BACKGROUND")
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        
        if error != nil {
            print("error from sessiondelegate: \(error?.localizedDescription)")
        }
    }
    
    // MARK: - NSURLSessionDataDelegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        print("DID RECEIVE RESPONSE")
        // Checking HTTP Response in case of error
        let httpResponse = response as? NSHTTPURLResponse
        
        if httpResponse?.statusCode != 200 {
            print(httpResponse?.statusCode)
        }
    }
    
    // MARK: - NSURLSessionTaskDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("DID COMPLETE WITH ERROR")
        if error != nil {
            print("error from taskdelegate: \(error?.localizedDescription)")
        }
    }
    

}

