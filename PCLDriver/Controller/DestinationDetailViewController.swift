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

class DestinationDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    var customerDetails:[Customer]?
    var addressForGeocoding : String?
    var location1:CLLocation?
    
    @IBOutlet weak var statusPicker: UIPickerView!
    
    @IBOutlet weak var mapViewDisplay: MKMapView!
    var myCurrentLoc: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    // the following coordinates are to be replaced with repsonses from CLgeodecoder
    
    var tempVar: CLLocationCoordinate2D?
    
    
    func loadOverlayForRegionWithLatitude(latitude: Double, longitude: Double)
    {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let circle = MKCircle(center: coordinates, radius: 300)
        self.mapViewDisplay.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        self.mapViewDisplay.addOverlay(circle)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusPicker.delegate = self
        getLocs(RouteNumber: 11)
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
        
        requestPermissionNotifications()
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
                    print("Something is wrong :(")
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
    
    func postLocalNotifications(eventTitle:String)
    {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "You've entered a new region"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    var positionStatus = Bool()
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        positionStatus = true
        print("entered")
        postLocalNotifications(eventTitle: "entered Office")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        positionStatus = false
        print("exited")
        postLocalNotifications(eventTitle: "exited Office")
    }
    
    func requestPermissionNotifications()
    {
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    //MARK: getting data for the routes
    
    
    
    func getLocs(RouteNumber: Int)
    {
        RestManager.APIData(url: baseURL + getRouteDetail + "?RouteNumber=" + String(RouteNumber), httpMethod: RestManager.HttpMethod.post.self.rawValue, body: nil){
            (Data, Error) in
            if Error == nil{
                do {
                    self.customerDetails = try JSONDecoder().decode([Customer].self, from: Data as! Data )
                    self.getAllCoordsForRoute()
                } catch let JSONErr{
                    print(JSONErr.localizedDescription)
                }
            }
        }
    }
    
    func createAddress(entry: Int)-> String
    {
        let streetAddress: String = (customerDetails?[entry].StreetAddress ?? "this was empty ")
        let city: String = (customerDetails?[entry].City) ?? " this was empty "
        let state: String = (customerDetails?[entry].State) ?? " this was empty "
        let ZIPint = (customerDetails?[entry].Zip) ?? 0
        let ZIP = String(ZIPint)
        let Seperator: String = ", "
        
        
        let addressToGeocode: String = (streetAddress+Seperator+state+Seperator+city+Seperator+ZIP)
        return(addressToGeocode)
    }
    // Picker View Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        CollectionStatus.statusList.count
       }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CollectionStatus.statusList[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = CollectionStatus.statusList[row]
        pickerLabel?.textColor = UIColor(named: "Your Color Name")

        return pickerLabel!
    }
    
    var locationAsArray = [CLLocationCoordinate2D]()
    
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void )
    {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString){ (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    self.location1 = placemark.location!
                    completionHandler(self.location1?.coordinate ?? CLLocationCoordinate2D(), nil)
                    return
                }
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    var listOfLocs = [CLLocationCoordinate2D]()
    func getAllCoordsForRoute()
    {
        
        var addressToAdd = String()
        var coordsOfATA = [CLLocationCoordinate2D]()
        var ListOfAddresses = [String]()
        var coordToAppend = CLLocationCoordinate2D()
        for i in Range(0...(customerDetails!.count-1))
        {
            addressToAdd = createAddress(entry: i)
            ListOfAddresses.append(addressToAdd)
        }
        
        for j in ListOfAddresses
        {
            getCoordinate(addressString: j) { (CLLocationCoordinate2D, NSError) in
                coordToAppend = CLLocationCoordinate2D
                coordsOfATA.append(coordToAppend)
                print("yf",coordsOfATA)
                self.listOfLocs = coordsOfATA
                if self.listOfLocs.count>0
                {
                    for k in self.listOfLocs
                    {
                        let listOfDropOffs = [["title":"Pick Up Here!", "latitude":k.latitude, "longitude":k.longitude]]
                        self.createAnnot(locations: listOfDropOffs)
                        let geoFenceRegion = CLCircularRegion(center: k, radius: 100, identifier: "PickUp Location")
                        geoFenceRegion.notifyOnEntry = true
                        geoFenceRegion.notifyOnExit = true
                        self.locationManager.startMonitoring(for: geoFenceRegion)
                    }
                    if self.listOfLocs.count>2
                    {
                        for z in Range(0...self.listOfLocs.count-2)
                        {
                            self.mapThis(originCoordinate: self.listOfLocs[z], destinationCord: self.listOfLocs[z+1])
                        }
                    }
                }
            }
        }
    }
}
