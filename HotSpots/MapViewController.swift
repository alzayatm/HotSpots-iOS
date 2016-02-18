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

    // For location updates
    var firstLocationUpdate = true
    
    // Button refreshing map view
    @IBOutlet weak var refreshButton: UIButton!
    
    // Location annotations 
    var annotations = [CustomPin]()
    
    // Zoom in label variables
    var firstLaunch = true
    var zoomInLabel = UILabel()
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        let businessDictionary: [[String:String]] = [["Street": "1574 onyx dr.", "State": "VA", "City": "Bla bla bla bla bla"],
        ["Street": "Sesame Street", "State": "WA", "City": "Bla bla bla bla bla"],
        ["Street": "Downing street", "State": "FL", "City": "Bla bla bla bla bla"],
        ["Street": "Jesus lane", "State": "KS", "City": "Bla bla bla bla bla"],
        ["Street": "Downing street", "State": "FL", "City": "Bla bla bla bla bla"],
        ["Street": "Downing street", "State": "FL", "City": "Bla bla bla bla bla"]]
        
         let coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 38.109438, longitude: -77.684032), CLLocationCoordinate2D(latitude: 38.405932, longitude: -77.293043), CLLocationCoordinate2D(latitude: 38.742739, longitude: -77.333333), CLLocationCoordinate2D(latitude: 38.925229, longitude: -77.036133), CLLocationCoordinate2D(latitude: 38.404494, longitude: -77.404392), CLLocationCoordinate2D(latitude: 40.7483, longitude: -73.984911)]
        
        
        for var i = 0; i < coordinates.count; i++ {
        
            annotations.append(CustomPin(title: "Pin\(i)", subtitle: "Hello", coordinate: coordinates[i], businessDictionary: businessDictionary[i]))
        
        }
        mapView.addAnnotations(annotations)
        */
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
            locationManager.distanceFilter = 10
            
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
        
        
        // If the user is travelling less than 5 mph, update location
        print("Your speed is \(manager.location?.speed)")
        if manager.location?.speed <= 3.5 {
            self.updateLongAndLat(location!)
        }
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
        let params: [String: AnyObject] = ["longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude, "userID": KeychainManager.stringForKey("userID")!]
        
        // Turning your data into JSON format and storing in HTTP request body
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print("Error serializing data with json object")
        }
        
        // Making a request over the network with request
        // Returns data, response, error objects
        let task = session.dataTaskWithRequest(request)
        
        // To display zoom in notification
        firstLaunch = false
        
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
        
        let pin = CustomPin(title: mapItem.name!, subtitle: self.streetAddresses[indexPath.row], coordinate: mapItem.placemark.coordinate, businessDictionary: nil)
        
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
                
                // Remove values from dictionary and array to populate with new data
                self.addressDictionary.removeAll(keepCapacity: false)
                self.streetAddresses.removeAll(keepCapacity: false)
                
                // storing data about location in dictionary
                for item in (response?.mapItems)! {
                    
                    // Storing map item address details into dictionary
                    self.addressDictionary = item.placemark.addressDictionary!
                    
                    // taking street value out of dictionary and storing in array
                    self.streetAddresses.append(self.addressDictionary["Street"] as? String ?? "")
                    
                }
            
                // Storing the array of MKMapItems in the array
                self.searchResults = (response?.mapItems)!
                print(self.searchResults.count)
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
        
        let viewFrameWidth = self.view.frame.width
        let animatesToFrame = CGRect(x: 0, y: 108.2, width: viewFrameWidth, height: 17)
        let originalFrame = CGRect(x: 0, y: 90, width: viewFrameWidth, height: 17)
        zoomInLabel.text = "Zoom in to see HotSpots"
        zoomInLabel.textAlignment = .Center
        zoomInLabel.alpha = 0.8
        zoomInLabel.textColor = UIColor.whiteColor()
        zoomInLabel.backgroundColor = UIColor.orangeColor()
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.zoomInLabel.frame = originalFrame
            self.zoomInLabel.removeFromSuperview()
        }
      
        // Stop retrieving hotspots if user is not zoomed in
        if self.mapView.region.span.latitudeDelta > 0.1 && self.mapView.region.span.longitudeDelta > 0.1 && !firstLaunch  {
           
            if zoomInLabel.frame != animatesToFrame {
                print("called")
                self.view.insertSubview(zoomInLabel, atIndex: 1)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.zoomInLabel.frame = animatesToFrame
                })
            }
            return
        }
        
        // loop through the annotations, whatever isn't within the confines of the map, remove it
        //let mapRect = self.mapView.visibleMapRect
        //let userLoc = mapView.userLocation.location
        
        //let NECoord: CLLocationCoordinate2D = self.getCoordinateFromMapRectangle(MKMapRectGetMaxX(mapRect), y: mapRect.origin.y)
        // Get farthest bottom left coordinate
        //let SWCoord: CLLocationCoordinate2D = self.getCoordinateFromMapRectangle(mapRect.origin.x, y: MKMapRectGetMaxY(mapRect))
        
        /*
        // Clear older annotations from mapview if the user has totally left the visible portion of the map
        if !(userLoc?.coordinate.latitude >= SWCoord.latitude && userLoc?.coordinate.latitude <= NECoord.latitude && userLoc?.coordinate.longitude >= SWCoord.longitude && userLoc?.coordinate.longitude <= NECoord.longitude) {
            print("annotations reset")
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll(keepCapacity: false)
        }

        
        for var i = 0; i < self.annotations.count; i++ {
            
            if !(self.annotations[i].coordinate.latitude > SWCoord.latitude && self.annotations[i].coordinate.latitude < NECoord.latitude && self.annotations[i].coordinate.longitude > SWCoord.longitude && self.annotations[i].coordinate.longitude < NECoord.longitude) {
                self.mapView.removeAnnotation(self.annotations[i])
                self.annotations.removeAtIndex(i)
            } else {
                
            }
        }
        */
        // Perform request on a background thread
        let qos = QOS_CLASS_USER_INTERACTIVE
        let queue = dispatch_get_global_queue(qos, 0)
        
        dispatch_async(queue) {
            self.fetchHotSpots()
            
            // Main thread to update the UI
            dispatch_async(dispatch_get_main_queue(), {
                // update the pins on the main thread
                self.mapView.addAnnotations(self.annotations)
                
            })
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Detail View" {
            let point = (sender as? MKAnnotationView)?.annotation as! CustomPin
            let tableViewController = segue.destinationViewController as! UITableViewController
            tableViewController.title = (point.title)!
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
    
    // MARK: - Retrieve hotspots
    
    private func getCoordinateFromMapRectangle(x: Double, y: Double) -> CLLocationCoordinate2D {
        let mapPoint: MKMapPoint = MKMapPoint(x: x , y: y)
        return MKCoordinateForMapPoint(mapPoint)
    }
    
    func fetchHotSpots() {
        
        /* Get the coordinates of the visible portion of the map */
        // Get the visible portion of the mapview 
        let mapRect = self.mapView.visibleMapRect
        // Get farthest top right coordinate
        let NECoord: CLLocationCoordinate2D = self.getCoordinateFromMapRectangle(MKMapRectGetMaxX(mapRect), y: mapRect.origin.y)
        // Get farthest bottom left coordinate
        let SWCoord: CLLocationCoordinate2D = self.getCoordinateFromMapRectangle(mapRect.origin.x, y: MKMapRectGetMaxY(mapRect))
        /*
        print("ne long coordinate = \(NECoord.longitude)")
        print("ne lat coordinate = \(NECoord.latitude)")
        let bottomLeftPin = CustomPin(title: "bottom left", subtitle: "yeah", coordinate: SWCoord, businessDictionary: nil)
        let topRightPin = CustomPin(title: "Top right", subtitle: "yeah", coordinate: NECoord, businessDictionary: nil)
        self.mapView.addAnnotation(bottomLeftPin)
        self.mapView.addAnnotation(topRightPin)
        */
        /* Get the prefer search method of the user */
        let defaults = NSUserDefaults.standardUserDefaults()
        let searchPreference = defaults.objectForKey("SortBy")
        
        // Configuration for session object
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Configuration for session object
        let session = NSURLSession(configuration: config)
        
        // The URL which the endpoint can be found at
        let URL = NSURL(string: "http://localhost:3000/gethotspots")
        
        // Initialize the request with the URL
        let request = NSMutableURLRequest(URL: URL!)
        
        // Configure the request
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(KeychainManager.stringForKey("token")! as String, forHTTPHeaderField: "Authorization")
        
        
        // Body sent to the server
        var params: [String: AnyObject] = ["NECoordLat": NECoord.latitude, "NECoordLong": NECoord.longitude, "SWCoordLat": SWCoord.latitude, "SWCoordLong": SWCoord.longitude]
        
        // If the user has a search preference, add it to the request
        if String(searchPreference) != "Most Populated" { params["searchPreferenceDetail"] = defaults.objectForKey("SortByParams")!}
        
        print(params["searchPreferenceDetail"]!)
        // Turning your data into JSON format and storing in HTTP request body
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            print(error)
        }

        // Making a request over the network with request
        // Returns data, response, error objects
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            let httpResponse = response as? NSHTTPURLResponse
            
            if httpResponse?.statusCode != 200 {
                print(httpResponse?.statusCode)
            }
            
            if error != nil {
                print("Localized description error: \(error?.localizedDescription)")
            }
            
            do {
                // Things to be returned by the server
                /* 
                * Business name
                * Business address
                * Latitude
                * Longitude 
                * Phone number 
                * Total number of people 
                * number of females 
                * number of males 
                * Percentage full
                */
                // Store JSON data into dictionary
                //let hotSpots = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableArray
                //print(hotSpots)
                /*
                for var i = 0; i < hotSpots?.count; i++ {
                    
                    let name = hotSpots![i]["name"]! as! String
                    print(name)
                    let longitude = hotSpots![i]["coordinates"]!!["x"]!! as! CLLocationDegrees
                    print(longitude)
                    let latitude = hotSpots![i]["coordinates"]!!["y"]!! as! CLLocationDegrees
                    print(latitude)
                    // A dictionary of additional information about the hotspot
                    //let businessDictionary = [String:String]()
                    
                    self.annotations.append(CustomPin(title: name, subtitle: "123 crap", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), businessDictionary: nil))

                    print("number of pins in array \(self.annotations.count)")
                }
                */
            } catch {
               print(error)
            }
        }
        
        // Start the session
        task.resume()
    }
    
    // Refresh HotSpots button
    @IBAction func refreshHotSpots(sender: AnyObject) {
        
        // Stop retrieving hotspots if user is not zoomed in
        if self.mapView.region.span.latitudeDelta > 0.1 && self.mapView.region.span.longitudeDelta > 0.1 { return }
        
        // Clear older annotations from mapview
        self.mapView.removeAnnotations(self.annotations)
        self.annotations.removeAll()
        
        // Perform request on a background thread
        let qos = QOS_CLASS_USER_INTERACTIVE
        let queue = dispatch_get_global_queue(qos, 0)
        
        dispatch_async(queue) {
            self.fetchHotSpots()
            
            // Main thread to update the UI 
            dispatch_async(dispatch_get_main_queue(), {
                // update the pins on the main thread
                self.mapView.addAnnotations(self.annotations)
                
            })
        }
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

