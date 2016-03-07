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
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var numOfPeopleLabel: UILabel!
    @IBOutlet weak var avgAgeLabel: UILabel!
    @IBOutlet weak var numOfMalesLabel: UILabel!
    @IBOutlet weak var numOfFemalesLabel: UILabel!
    
    var businessDictionary: [String: AnyObject]!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView(longitude, lat:latitude)
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(pin)
        
        self.businessNameLabel.text = String(businessDictionary["businessName"]!)
        self.businessAddressLabel.text = String(businessDictionary["businessAddress"]!)

        self.setDetails()
        self.configPieChart()
    }
    
    func setupMapView(long: CLLocationDegrees, lat: CLLocationDegrees) {
        mapView.showsUserLocation = true
        mapView.scrollEnabled = false
        mapView.zoomEnabled = false
        mapView.pitchEnabled = false
        mapView.rotateEnabled = false
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        
    }
    
    func configPieChart() {
        
        let pieChartView = BusinessDetailView()
        pieChartView.frame = CGRectMake((self.view.frame.size.width / 3) - 50, (self.view.frame.size.height / 2) + 75,220,220)
        //let b = CGRectMakeCGRectMake((self.view.frame.size.width / 3) - 50, (self.view.frame.size.height / 2) + 40,220,220)
        //CGRectMake(<#T##x: CGFloat##CGFloat#>, <#T##y: CGFloat##CGFloat#>, <#T##width: CGFloat##CGFloat#>, <#T##height: CGFloat##CGFloat#>)
        pieChartView.segments = [
            Segment(aColor: UIColor(red: 0.9, green: 0.0, blue: 0.5, alpha: 1), aName: String(businessDictionary!["percentFemale"]!) + "%", aValue: CGFloat(businessDictionary["percentFemale"]! as! NSNumber)),
            Segment(aColor: UIColor(red: 0.2, green: 0.4, blue: 1, alpha: 1.0), aName: String(businessDictionary!["percentMale"]!) + "%", aValue: CGFloat(businessDictionary["percentMale"] as! NSNumber))
        ]
        
        view.addSubview(pieChartView)
    }
    
    func setDetails() {
        self.avgAgeLabel.text = String(businessDictionary["averageAge"]!)
        self.numOfPeopleLabel.text = String(businessDictionary["numOfPeople"]!)
        self.numOfMalesLabel.text = String(businessDictionary["numOfMales"]!)
        self.numOfFemalesLabel.text = String(businessDictionary["numOfFemales"]!)
    }
}
