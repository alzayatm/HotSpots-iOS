//
//  BusinessDetailView.swift
//  HotSpots
//
//  Created by Mihad Alzayat on 11/5/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var businessDictionary: [String: AnyObject]!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView(longitude, lat:latitude)
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(pin)
        
        print("# people: \(businessDictionary["numOfPeople"]!)")
        print(" avg age: \(businessDictionary["averageAge"]!)")
        print("# guys: \(businessDictionary["numOfMales"]!)")
        print("# girls: \(businessDictionary["numOfFemales"]!)")
        print("% guys: \(businessDictionary["percentMale"]!)")
        print("% girls: \(businessDictionary["percentFemale"]!)")
        
    }
    
    func setupMapView(long: CLLocationDegrees, lat: CLLocationDegrees) {
        mapView.showsUserLocation = true
        mapView.scrollEnabled = false
        mapView.zoomEnabled = false
        mapView.pitchEnabled = false
        mapView.rotateEnabled = false
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        
    }

}
