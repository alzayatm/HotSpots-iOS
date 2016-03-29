//
//  AppDelegate.swift
//  HotSpots
//
//  Created by Mihad Alzayat on 10/14/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
  
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        if manager.location?.speed <= 3.5 {
            self.updateLongAndLat(manager.location!)
        }
    }
    
    func updateLongAndLat(location: CLLocation) {
        
        // Configuration for session object
        let sessionConfigObject = NSURLSessionConfiguration.defaultSessionConfiguration()
    
        // Initialize session object with its configuration
        let session = NSURLSession(configuration: sessionConfigObject)
        
        // The URL which the endpoint can be found at
        let URL = NSURL(string: "http://dev-api.hotspotsapp.us/updatelocation")
        
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
                print("Status code (terminated request): \(httpResponse?.statusCode)")
            }
            
            if error != nil {
                print("Localized description error (terminated request): \(error!.localizedDescription)")
            }
        }
        
        // Start the session
        task.resume()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 0.5)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Check for token, if nil, display the register view controller - check keychain
        
        print("Value = \(NSUserDefaults.standardUserDefaults().boolForKey("NotFirstLaunch"))")
        
        if !defaults.boolForKey("NotFirstLaunch") {
            
            defaults.setObject("Most Populated", forKey: "SortBy")
            defaults.setObject("", forKey: "SortByParams")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeViewController = storyboard.instantiateViewControllerWithIdentifier("Welcome View")
            
            welcomeViewController.modalPresentationStyle = .FullScreen
            self.window?.rootViewController = welcomeViewController
        }
        
        if launchOptions?[UIApplicationLaunchOptionsLocationKey] != nil {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
}

