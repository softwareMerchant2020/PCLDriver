//
//  DestinationDetailViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DestinationDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate
{
    
    @IBOutlet weak var mapViewDisplay: MKMapView!
    var myCurrentLoc: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    // the following coordinates are to be replaced with repsonses from CLgeodecoder
    
    // SM office
    let Ax: Double = 40.04343
    let Ay: Double = -75.24482
    
    // 30th street station
    let Bx: Double = 40.334340
    let By: Double = -79.841580
    
    // Drexel park
    let Cx: Double = 40.223270
    let Cy: Double = -76.883970
    
    // Upenn fine arts Library
    let Dx: Double = 39.9517559
    let Dy: Double = -75.192781
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        locationManager.delegate = self // Sets the delegate to self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Sets the accuracy of the GPS to best in this case
        locationManager.requestAlwaysAuthorization() // Asks for permission
        locationManager.requestWhenInUseAuthorization() //Asks for permission when in use
        locationManager.startUpdatingLocation() //Updates location when moving
        mapViewDisplay.delegate = self
        mapViewDisplay.showsScale = true
        mapViewDisplay.showsUserLocation = true
        // Do any additional setup after loading the view.

        let Acoord = CLLocationCoordinate2D(latitude: Ax, longitude: Ay)
        let Bcoord = CLLocationCoordinate2D(latitude: Bx, longitude: By)
        let Ccoord = CLLocationCoordinate2D(latitude: Cx, longitude: Cy)
        let Dcoord = CLLocationCoordinate2D(latitude: Dx, longitude: Dy)
        let annotArr = [["title": "location 1", "latitude": Ax, "longitude": Ay],["title": "location2", "latitude": Bx, "longitude": By],["title": "location 3", "latitude": Cx, "longitude": Cy],["title": "location4", "latitude": Dx, "longitude": Dy]]
        createAnnot(locations: annotArr)
        
        mapThis(originCoordinate: Acoord, destinationCord: Bcoord)
        mapThis(originCoordinate: Bcoord, destinationCord: Ccoord)
        mapThis(originCoordinate: Ccoord, destinationCord: Dcoord)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func mapThis(originCoordinate: CLLocationCoordinate2D, destinationCord : CLLocationCoordinate2D)
    {
        
        let soucePlaceMark = MKPlacemark(coordinate: originCoordinate) // Start point as coordinate
        let destPlaceMark = MKPlacemark(coordinate: destinationCord) // End point as coordinate
        
        let sourceItem = MKMapItem(placemark: soucePlaceMark) // Start point as placemark (MapItem)
        let destItem = MKMapItem(placemark: destPlaceMark)// Start point as placemark (MapItem)
        
        let destinationRequest = MKDirections.Request() // Initialises requests to apple Maps to get route
        destinationRequest.source = sourceItem // Requesting where to start from
        destinationRequest.destination = destItem // Requesting where to end
        destinationRequest.transportType = .walking // Requesting what mode of transport is being used
        destinationRequest.requestsAlternateRoutes = true // Requesting Alternate Routes
        
        let directions = MKDirections(request: destinationRequest) //Initialsing the directions with the request
        directions.calculate { (response, error) in // Calculates route Using MKDirections
            //            error handling for unforseen problems such as User denying location access, or start point = end point etc.
            guard let response = response else {
                if error != nil {
                    print("Something is wrong :(" + error)
                }
                return
            }
            
            let route = response.routes[0] // Retrieves useful information for plotting the route
            self.mapViewDisplay.addOverlay(route.polyline) // Creates route as a road map that is similar to that on google maps/ apple maps
            self.mapViewDisplay.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // Makes the route visible to user and animates it
        }
    }
    
    func createAnnot(locations:[[String: Any]])
    {
        for location in locations
        {
            let annot = MKPointAnnotation()
            annot.title = location["title"] as? String
            annot.coordinate = CLLocationCoordinate2D(latitude: location["latitude"] as! CLLocationDegrees, longitude: location["longitude"] as! CLLocationDegrees)
            mapViewDisplay.addAnnotation(annot)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline) // Tells hardware what the render is going to look like
        render.strokeColor = .blue // Tells hardware what colour to make the render
        return render
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let locVal: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.myCurrentLoc = locVal
        
    }

}
