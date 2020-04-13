//
//  ViewController.swift
//  coordinate plotter
//
//  Created by Varun Nair on 4/13/20.
//  Copyright © 2020 Varun Nair. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{

    let locManager = CLLocationManager()
     var myCurrentLoc: CLLocationCoordinate2D?
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    var valueList = [Double]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.locManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
            changeLabel()
            map.showsScale = true
            map.showsCompass = true
            map.showsUserLocation = true
        }
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.valueList.append(locValue.latitude)
        self.valueList.append(locValue.longitude)
        print("locations = \(locValue.latitude) ,  \(locValue.longitude)")
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 600, longitudinalMeters: 600)
        self.map.setRegion(viewRegion, animated: true)
        guard let locVal: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.myCurrentLoc = locVal
//        DispatchQueue.main.async {
//            self.latLabel.text = String(self.values[0])
//            self.longLabel.text = String(self.values[1])
    }
    
    
    var counter = 0
    func changeLabel()
    {
        DispatchQueue.main.asyncAfter(deadline: .now()+5)
        {
            print(self.counter)
            self.latLabel.text = "\(self.valueList[self.counter])"
            self.longLabel.text = "\(self.valueList[self.counter+1])"
            self.counter += 2
            print(self.valueList[self.counter])
            print(self.valueList[self.counter+1])
            print(self.counter)
            print("===================================")
            self.changeLabel()
        }
    }
}
