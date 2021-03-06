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
    var locationPins = [CustomPin]()
    
    // Locations Dictionary 
    var locationsObjectDictionary: NSMutableDictionary?
    
    // Users current location 
    var lastUserCheckinDictionary: NSMutableDictionary?
    
    //var camera: MKMapCamera!
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.centerOnUser), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        let startLocationUpdatesTimer = NSTimer(timeInterval: 300, target: self, selector: #selector(self.startLocationUpdates), userInfo: nil, repeats: true)
        
        NSRunLoop.mainRunLoop().addTimer(startLocationUpdatesTimer, forMode: NSRunLoopCommonModes)
    }
   
    // Start location updates 
    func startLocationUpdates() {
        print("Updating location function")
        self.locationManager.startUpdatingLocation()
    }
    
    // Centers on users position when app becomes active from background
    func centerOnUser() {
        
        self.mapView.setCenterCoordinate((locationManager.location?.coordinate)!, animated: true)
        
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: false)
        
    }
    
    
    // Configure the map view
    func mapViewConfig() {
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.pitchEnabled = true
        self.mapView.rotateEnabled = true
        self.mapView.mapType = .HybridFlyover
        
    }
    
    // Configure the location of the user
    func configureLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self

            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            
            // Distance filter to update location
            //locationManager.distanceFilter = 50.0
            
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
        let imageView: UIImageView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height: 50))
        imageView.image = UIImage(named: "NavigationTitleLogo")
        imageView.contentMode = .ScaleAspectFit
        
        self.navigationItem.titleView = imageView
        
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
        //self.refreshButton.frame = CGRectMake(10, 10, 60, 60)
        
        self.refreshButton.layer.cornerRadius = refreshButton.bounds.size.width / 2
        
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
    
    // Responding to location events
    
    // Delegate method updating user location based on set criteria 
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("-----didUpdateCalled-----")
        /*
        if UIApplication.sharedApplication().applicationState == .Active {
            print("ACTIVE UPDATE: location")
        } else if UIApplication.sharedApplication().applicationState == .Background {
            print("BACKGROUND UPDATE: location")
        }
        */
        
        if firstLocationUpdate {
            let center = CLLocationCoordinate2D(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
            
            self.mapView.setRegion(region, animated: true)
            
            self.firstLocationUpdate = false
        }
        
      
        // If the user is travelling less than 5 mph, update location
        if manager.location?.speed <= 3.5 {
            self.updateLongAndLat(manager.location!, completion: { (lat, long) in
                print("lat \(lat)")
                print("long \(long)")
                if lat != nil && long != nil {
                    print("LAUNCH MONITORED REGION 1")
                    let center = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                    let monitoredRegion = CLCircularRegion(center: center, radius: 10.0, identifier: "UserRegion")
                    monitoredRegion.notifyOnEntry = false
                    self.locationManager.startMonitoringForRegion(monitoredRegion)
                } else {
                    print("LAUNCH MONITORED REGION 2")
                    let center = CLLocationCoordinate2D(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
                    let monitoredRegion = CLCircularRegion(center: center, radius: 10.0, identifier: "UserRegion")
                    monitoredRegion.notifyOnEntry = false
                    self.locationManager.startMonitoringForRegion(monitoredRegion)
                    
                }
            })
            
        }
        self.locationManager.stopUpdatingLocation()
    }
  
    func noInternetAlertMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(confirm)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // Location cannot be retrieved delegate method
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.noInternetAlertMessage("Unable to retrieve user location", message: error.localizedDescription)
    }
    
    // Responding to region events 
    
    // The user did leave the specified region
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("????????????EXITED REGION???????????????")
        
        print("Identifier: \(region.identifier)")
        if manager.location?.speed <= 3.5 {
            self.updateLongAndLat(manager.location!, completion: { (lat, long) in
                print("lat \(lat)")
                print("long \(long)")
                if lat != nil && long != nil {
                    print("MONITORED REGION 1")
                    let center = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                    let monitoredRegion = CLCircularRegion(center: center, radius: 10.0, identifier: "UserRegion")
                    monitoredRegion.notifyOnEntry = false
                    self.locationManager.startMonitoringForRegion(monitoredRegion)
                } else {
                    print("MONITORED REGION 2")
                    let center = CLLocationCoordinate2D(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
                    let monitoredRegion = CLCircularRegion(center: center, radius: 10.0, identifier: "UserRegion")
                    monitoredRegion.notifyOnEntry = false
                    self.locationManager.startMonitoringForRegion(monitoredRegion)
                }
            })
        }
    }
    
    // Called when the delegate starts to monitor a new region
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Started monitoring for region \(region.identifier)")
    }
    
    // The delegate is unable failed to monitor region changes
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        self.noInternetAlertMessage("Unable to monitor region", message: error.localizedDescription)
    }
    
    
    /*
    func configurationObject() -> NSURLSessionConfiguration {
        
        let sessionConfigObject: NSURLSessionConfiguration
        if UIApplication.sharedApplication().applicationState == .Active {
            sessionConfigObject = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("BackgroundSession")
        } else {
            sessionConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
        }
        
        return sessionConfigObject
    }
    */
    
    func updateLongAndLat(location: CLLocation, completion: (lat: CLLocationDegrees?, long: CLLocationDegrees?) -> Void) {
        
        // Configuration for session object
        let sessionConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
       
        // Initialize session object with its configuration
        let session = NSURLSession(configuration: sessionConfigObject)
        
        // The URL which the endpoint can be found at
        let URL = NSURL(string: "https://api.hotspotsapp.us/updatelocation")
        
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
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            let httpResponse = response as? NSHTTPURLResponse
            
            if httpResponse?.statusCode != 200 {
                print("Status code: \(httpResponse?.statusCode)")
            }
            
            if error != nil {
                print("Localized description error: \(error!.localizedDescription)")
            }
            
            
            do {
                //Store JSON data into dictionary
                self.lastUserCheckinDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
                
                print("-------DICTIONARY------")
                print(self.lastUserCheckinDictionary!)
                /*
                print("-------------")
                print("Checkin_id: \(self.lastUserCheckinDictionary!["checkin_id"])")
                print("user_id: \(self.lastUserCheckinDictionary!["user_id"])")
                print("location_id \(self.lastUserCheckinDictionary!["location_id"])")
                print("long: \(self.lastUserCheckinDictionary!["longitude"])")
                print("lat: \(self.lastUserCheckinDictionary!["latitude"])")
                */
                
            } catch {
                print("JSON object could not be retrieved: \(error)")
            }
            
            completion(lat: self.lastUserCheckinDictionary?["latitude"] as? CLLocationDegrees, long: self.lastUserCheckinDictionary?["longitude"] as? CLLocationDegrees)
        }
        
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
        
        //self.mapView.removeAnnotations(self.mapView.annotations)
        //print("Number of address results: \(self.streetAddresses.count)")
        searchController.searchBar.barTintColor = UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 0.5)
        
        // Changing the color of the search bar's cancel button to white
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor.whiteColor()
    }
    
    // Change the color of the search bar belonging to the search controller back to default
    func didDismissSearchController(searchController: UISearchController) {
        self.searchResults.removeAll(keepCapacity: false)
        self.streetAddresses.removeAll(keepCapacity: false)
        searchController.searchBar.barTintColor = .None
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        
        //print("Row number: \(indexPath.row)")
        //print("In row \(self.searchResults[indexPath.row].name)")
        cell.textLabel?.text = self.searchResults[indexPath.row].name
        
        //print("In row \(self.streetAddresses[indexPath.row])")
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
        
        //mapView.addAnnotation(pin)
        //mapView.selectAnnotation(pin, animated: true)
    
        // (mapItem.placemark.location?.coordinate)!
        mapView.setCenterCoordinate(pin.coordinate, animated: false)
        mapView.setUserTrackingMode(.None, animated: false)
        
       return indexPath
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.searchQuery(searchController.searchBar.text!) {
            self.tableViewController.tableView.reloadData()
        }
    }
    
    // MARK: - MKLocalSearch 
    
    func searchQuery(query: String, completion: () -> Void) {
        
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
                //self.addressDictionary.removeAll(keepCapacity: false)
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
                
                
                /*
                // Debugging code
                print("Number of search results \(self.searchResults.count)")
                print("Number of addresses \(self.streetAddresses.count)")
                
                for var i = 0; i < self.searchResults.count; i++ {
                    print(self.searchResults[i].name!)
                    print(self.streetAddresses[i])
                } 
                */
                completion()
            }
        }
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print(self.searchResults.count)
        
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Return nil if the annotation is the user's location
        if annotation.isKindOfClass(MKUserLocation) { return nil }
        
        // Attempt to reuse pins that were active
        // Create a custom annotation view if nil 
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin")
        let customPinAnnotation = annotation as! CustomPin
        
        let numOfPeopleLabel = UILabel(frame: CGRectMake(11, 4, 30, 30))
        numOfPeopleLabel.adjustsFontSizeToFitWidth = true
        
        // When there is no pin to reuse
        if annotationView == nil {
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.centerOffset = CGPoint(x: 0, y: -20)
            annotationView!.canShowCallout = true
            
            let percentMale = customPinAnnotation.businessDictionary!["percentMale"] as! NSInteger
            if percentMale >= 70 {
                annotationView?.image = UIImage(named: "DarkBluePin")
            } else if percentMale >= 51 && percentMale <= 69 {
                annotationView?.image = UIImage(named: "LightBluePin")
            } else if percentMale >= 31 && percentMale <= 49 {
                annotationView?.image = UIImage(named: "LightPinkPin")
            } else if percentMale < 30 {
                annotationView?.image = UIImage(named: "DarkPinkPin")
            } else if percentMale == 50 {
                annotationView?.image = UIImage(named: "EqualGenderPin")
            }
            
            annotationView?.frame = CGRectMake(0, 0, 37.5, 62.5)
            
            if customPinAnnotation.businessDictionary!["numOfPeople"]! as! NSInteger > 99 {
                numOfPeopleLabel.text = "99+"
            } else {
                numOfPeopleLabel.text = String(customPinAnnotation.businessDictionary!["numOfPeople"]!)
            }
            
            annotationView?.subviews.last?.removeFromSuperview()
            annotationView?.addSubview(numOfPeopleLabel)
            
            // Right call out button
            let rightCallOutButton = UIButton(type: UIButtonType.DetailDisclosure)
            annotationView?.rightCalloutAccessoryView = rightCallOutButton
        
        } else {
            
            annotationView!.annotation = annotation
            if customPinAnnotation.businessDictionary!["numOfPeople"]! as! NSInteger > 99 {
                numOfPeopleLabel.text = "99+"
            } else {
                numOfPeopleLabel.text = String(customPinAnnotation.businessDictionary!["numOfPeople"]!)
            }
            
            let percentMale = customPinAnnotation.businessDictionary!["percentMale"] as! NSInteger
            if percentMale >= 70 {
                annotationView?.image = UIImage(named: "DarkBluePin")
            } else if percentMale >= 51 && percentMale <= 69 {
                annotationView?.image = UIImage(named: "LightBluePin")
            } else if percentMale >= 31 && percentMale <= 49 {
                annotationView?.image = UIImage(named: "LightPinkPin")
            } else if percentMale < 30 {
                annotationView?.image = UIImage(named: "DarkPinkPin")
            } else if percentMale == 50 {
                annotationView?.image = UIImage(named: "EqualGenderPin")
            }
            
            annotationView?.frame = CGRectMake(0, 0, 37.5, 62.5)
            annotationView?.subviews.last?.removeFromSuperview()
            annotationView?.addSubview(numOfPeopleLabel)
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
        if self.mapView.region.span.latitudeDelta > 0.09 && self.mapView.region.span.longitudeDelta > 0.09 && !firstLaunch  {
           
            if zoomInLabel.frame != animatesToFrame {
                self.view.insertSubview(zoomInLabel, atIndex: 1)
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.zoomInLabel.frame = animatesToFrame
                })
            }
            return
        }
        
        // Perform request on a background thread
        if self.mapView.region.span.latitudeDelta < 0.09 && self.mapView.region.span.longitudeDelta < 0.09 {
            
            self.mapView.removeAnnotations(locationPins)
            self.locationPins.removeAll(keepCapacity: false)
            
            let qos = DISPATCH_QUEUE_PRIORITY_HIGH
            let queue = dispatch_get_global_queue(qos, 0)
        
            dispatch_async(queue) {
                self.fetchHotSpots() {
                    self.addLocationInfoToPins()

                    dispatch_sync(dispatch_get_main_queue(), {
                        //print("Adding: \(self.locationPins.count)")
                        self.mapView.addAnnotations(self.locationPins)
                    })
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Detail View" {
            let pin = (sender as? MKAnnotationView)?.annotation as! CustomPin
            let viewController = segue.destinationViewController as! BusinessDetailViewController
            viewController.title = (pin.title)!
    
            viewController.businessDictionary = pin.businessDictionary
            viewController.longitude = pin.coordinate.longitude
            viewController.latitude = pin.coordinate.latitude
        }
    }
    
    // MARK: - Navigation bar button presentation functions
    
    @IBAction func listView(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewControllerWithIdentifier("List View") as! ListViewController
        
        destinationViewController.modalTransitionStyle = .FlipHorizontal
        destinationViewController.locationsObjectDictionary = self.locationsObjectDictionary
        let navController = UINavigationController(rootViewController: destinationViewController)
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
    
    func fetchHotSpots(completion: () -> Void) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        /* Get the coordinates of the visible portion of the map */
        // Get the visible portion of the mapview 
        let mapRect = self.mapView.visibleMapRect
        // Get farthest top right coordinate
        let NECoord: CLLocationCoordinate2D = self.getCoordinateFromMapRectangle(MKMapRectGetMaxX(mapRect), y: mapRect.origin.y)
        // Get farthest bottom left coordinate
        let SWCoord: CLLocationCoordinate2D = self.getCoordinateFromMapRectangle(mapRect.origin.x, y: MKMapRectGetMaxY(mapRect))
        
        /* Get the prefer search method of the user */
        let defaults = NSUserDefaults.standardUserDefaults()
        let searchPreference: String = (defaults.objectForKey("SortBy") as? String)!
        //let searchPreferenceDetails: String = (defaults.objectForKey("SortByParams") as? String)!
        
        // Configuration for session object
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Configuration for session object
        let session = NSURLSession(configuration: config)
        
        // The URL which the endpoint can be found at
        let URL = NSURL(string: "https://api.hotspotsapp.us/gethotspots")
        
        // Initialize the request with the URL
        let request = NSMutableURLRequest(URL: URL!)
        
        // Configure the request
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(KeychainManager.stringForKey("token")! as String, forHTTPHeaderField: "Authorization")
        
        // Body sent to the server
        var params: [String: AnyObject] = ["NECoordLat": NECoord.latitude, "NECoordLong": NECoord.longitude, "SWCoordLat": SWCoord.latitude, "SWCoordLong": SWCoord.longitude]
        
        // If the user has a search preference, add it to the request
        if searchPreference ==  "Most Populated" {
            params["SearchPreference"] = "Most Populated"
            params["SearchPreferenceDetail"] = defaults.objectForKey("SortByParams")!
        } else if searchPreference == "Gender" {
            params["SearchPreference"] = "Gender"
            params["SearchPreferenceDetail"] = defaults.objectForKey("SortByParams")!
        } else if searchPreference == "Age" {
            params["SearchPreference"] = "Age"
            params["SearchPreferenceDetail"] = defaults.objectForKey("SortByParams")!
        }
        
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
                print("Status code: \(httpResponse?.statusCode)")
            }
            
            if error != nil {
                print("Localized description error: \(error!.localizedDescription)")
            }
            
            do {
                //Store JSON data into dictionary
                self.locationsObjectDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
            
                //print(self.locationsObjectDictionary!)
                
            } catch {
               print("JSON object could not be retrieved: \(error)")
                self.locationsObjectDictionary?.removeAllObjects()
            }
            completion()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        // Start the session
        task.resume()
    }
    
    // Refresh HotSpots button
    @IBAction func refreshHotSpots(sender: AnyObject) {
        
        // Stop retrieving hotspots if user is not zoomed in
        if self.mapView.region.span.latitudeDelta > 0.09 && self.mapView.region.span.longitudeDelta > 0.09 { return }
        
        // Clear older annotations from mapview
        self.mapView.removeAnnotations(locationPins)
        self.locationPins.removeAll(keepCapacity: false)
        
        // Perform request on a background thread
     
        let qos = DISPATCH_QUEUE_PRIORITY_HIGH
        let queue = dispatch_get_global_queue(qos, 0)
        
        dispatch_async(queue) {
            self.fetchHotSpots() {
                self.addLocationInfoToPins()
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.mapView.addAnnotations(self.locationPins)
                    
                })
            }
        }
    }
    
    
    func addLocationInfoToPins() {
        
        if locationsObjectDictionary?.count > 0 {
        for var i = 0; i < self.locationsObjectDictionary?["results"]!.count; i += 1 {
        //for result in self.locationsObjectDictionary?["results"]! {
            
            if !(self.locationsObjectDictionary!["results"]![i] as AnyObject is NSNull) {
                
                // Retrieve all info from business
                let name = self.locationsObjectDictionary!["results"]![i]["business_details"]!!["business_name"]! as! String
                let address = self.locationsObjectDictionary!["results"]![i]["business_details"]!!["business_address"] as! String
                let longitude = self.locationsObjectDictionary!["results"]![i]["coordinates"]!!["x"]!! as! CLLocationDegrees
                let latitude = self.locationsObjectDictionary!["results"]![i]["coordinates"]!!["y"]!! as! CLLocationDegrees
                
                let businessDictionary: [String: AnyObject] = ["numOfPeople": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_people"]! as! NSNumber, "averageAge": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["average_age"]! as! NSNumber,
                    "numOfFemales": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_females"]! as! NSNumber,
                    "numOfMales": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["num_of_males"]! as! NSNumber,
                    "percentFemale": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["percent_female"]! as! NSNumber,
                    "percentMale": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["percent_male"]! as! NSNumber,
                    "businessName": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["business_name"]! as! String,
                    "businessAddress": self.locationsObjectDictionary!["results"]![i]["business_details"]!!["business_address"] as! String]
                
                // Add to locationPins array
                //print("Before insertion into pin: \(businessDictionary)")
             
                self.locationPins.append(CustomPin(title: name, subtitle: address, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), businessDictionary: businessDictionary))
                //print("Number of entries in locationPins: \(self.locationPins.count)")
                
            }
        }
        }
    }
    
    // MARK: - NSURLSessionDelegate
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("Updated location in background")
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        if error != nil {
            print("Error from session delegate: \(error?.localizedDescription)")
        }
    }
    
    // MARK: - NSURLSessionDataDelegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        print("Response received for background location updates")
        // Checking HTTP Response in case of error
        let httpResponse = response as? NSHTTPURLResponse
        
        if httpResponse?.statusCode != 200 {
            print(httpResponse?.statusCode)
        }
    }
    
    // MARK: - NSURLSessionTaskDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("Completed with error")
        if error != nil {
            print("Error from taskdelegate: \(error?.localizedDescription)")
        }
    }
}

