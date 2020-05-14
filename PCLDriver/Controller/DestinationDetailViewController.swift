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

class DestinationDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    
    @IBOutlet weak var statusPicker: UIPickerView!
    
    // MARK: Map stuff
    var selectedCustomer:Customer?
    var routeDetails:[RouteDetail]!
    var routeNumber:Int?
    var addressForGeocoding : String?
    var location1:CLLocation?
    var result: RequestResult?
    var driverNumber: Int?
    let driverId: Int? = (UserDefaults.standard.value(forKey: "DriverId") as! Int)
    var delegate:RouteListViewController?
    var customerNumber: Int?
    
    @IBOutlet weak var labAddress: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var specimenCountField: UITextField!
    @IBOutlet weak var mapViewDisplay: MKMapView!
    var myCurrentLoc: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var locationAsArray = [CLLocationCoordinate2D]()
    
    var positionStatus = Bool()

    
    // the following coordinates are to be replaced with repsonses from CLgeodecoder
    
    var tempVar: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getLocs(RouteNumber: self.routeNumber ?? 0)
        specimenCountField.isHidden = true
        specimenCountField.delegate = self
        logoutButton()
        addLabName()
        statusPicker.delegate = self
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
//        requestPermissionNotifications()
        self.getAllCoordsForRoute()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func addLabName()  {
        labName.text = selectedCustomer?.customerName
        let address:String = String(format: "%@, %@, %@, %d", selectedCustomer?.streetAddress ?? "",selectedCustomer?.city ?? "", selectedCustomer?.state ?? "", selectedCustomer?.zip ?? 0)
        labAddress.text = address
    }
    // Picker delegate
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
        pickerLabel?.textColor = UIColor.systemRed
        if pickerLabel?.text == CollectionStatus.statusList[1] {
            specimenCountField.isHidden = false
        }
        else {
            specimenCountField.isHidden = true
        }
        
        return pickerLabel!
    }
    
    func loadOverlayForRegionWithLatitude(latitude: Double, longitude: Double)
    {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let circle = MKCircle(center: coordinates, radius: 100)
        self.mapViewDisplay.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        self.mapViewDisplay.addOverlay(circle)
    }
    
    
   func logoutButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(powerButtonClicked(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    @objc func powerButtonClicked(_ sender: Any) {
        let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func updateStatusClicked(_ sender: Any) {
/*       0    NotCollected
1    Collected
2    Rescheduled
3    Missed
4    Closed
5    Other
        */
        if let location = self.myCurrentLoc{
        
        let count = Int(specimenCountField.text!) ?? 0
        guard let driverNumber = UserDefaults.standard.value(forKey: "DriverId") as? Int else { return }
        var specStat:Int!
        if positionStatus {
            specStat = 6
        }
        else {
            specStat = statusPicker.selectedRow(inComponent: 0)
        }
        let jsonBody:Dictionary<String,Any> = [
            "CustomerId": selectedCustomer?.customerID as Any,
            "RouteId": routeNumber ?? 0,
           "NumberOfSpecimens": count,
           "Status": specStat as Any,
           "UpdateBy": driverNumber
        ]
        RestManager.APIData(url: baseURL + addUpdateTransactionStatus, httpMethod: RestManager.HttpMethod.post.self.rawValue, body: Utilities.SerializedData(JSONObject: jsonBody)){
            (Data, Error) in
            if Error == nil{
                do {
                    let result = try JSONDecoder().decode(RequestResult.self, from: Data as! Data )
                    if result.Result == "Success" {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: result.Result, message: nil, preferredStyle: .alert)
                             self.present(alert, animated: true, completion: {
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_ ) in
                                    self.dismiss(animated: true, completion: {
                                        self.delegate?.refreshTable()
                                        self.sendDriverLoc(driverID: self.driverId!)
                                    self.navigationController?.popViewController(animated: true)
                                    }) }
                            })
                        }
                    }
                    
                } catch let JSONErr{
                    print(JSONErr.localizedDescription)
                }
            }
        }
        } else {
            self.present(Alert(message: "Please allow location access in the settings for the app."), animated: true)
        }
    }
    
    
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
        guard let driverId = UserDefaults.standard.value(forKey: "DriverId") as? Int else { return }
        
        let delayTime = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute:{
            self.sendDriverLoc(driverID: driverId)})
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        positionStatus = true
        updateStatusClicked(self)
        sendDriverLoc(driverID: self.driverId ?? 3 )
//        postLocalNotifications(eventTitle: "Reached customer")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        positionStatus = false
        sendDriverLoc(driverID: self.driverId ?? 3) //get rid of hard code
//        postLocalNotifications(eventTitle: "Leaving customer")

    }
    
    
    
    //MARK: getting data for the routes
    
    func sendDriverLoc(driverID: Int)
    {
        let bodyParamsRaw = ["driverId": driverID, "Lat": Double(self.myCurrentLoc!.latitude), "log":Double(self.myCurrentLoc!.longitude), "Geofence":positionStatus] as [String : Any]
        let bodyParams = SerializedData(JSONObject: bodyParamsRaw)
        
        RestManager.APIData(url: baseURL + addDriverLocation, httpMethod: RestManager.HttpMethod.post.self.rawValue, body: bodyParams){
            (Data, Error) in
            if Error == nil{
                do {
                    self.result = try JSONDecoder().decode(RequestResult.self, from: Data as! Data )
                } catch let JSONErr{
                    print(JSONErr.localizedDescription)
                }
            }
        }
    }
    
    
    
    
    
    func createAddress(entry: Int)-> String
    {
        let streetAddress: String = (routeDetails[0].customer[entry].streetAddress )
        let city: String = (routeDetails[0].customer[entry].city)
        let state: String = (routeDetails[0].customer[entry].state)
        let ZIPint = (routeDetails[0].customer[entry].zip)
        let ZIP = String(ZIPint)
        let Seperator: String = ", "
        
        
        let addressToGeocode: String = (streetAddress+Seperator+state+Seperator+city+Seperator+ZIP)
        return(addressToGeocode)
    }
        
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
        for i in Range(0...((routeDetails[0].customer.count)-1))
        {
            addressToAdd = createAddress(entry: i)
            ListOfAddresses.append(addressToAdd)
        }
        
        for j in ListOfAddresses
        {
            getCoordinate(addressString: j) { (CLLocationCoordinate2D, NSError) in
                coordToAppend = CLLocationCoordinate2D
                coordsOfATA.append(coordToAppend)
                if ListOfAddresses.count>0
                {
                    for k in coordsOfATA
                    {
                        let listOfDropOffs = [["title":"Pick Up Here!", "latitude":k.latitude, "longitude":k.longitude]]
                        self.createAnnot(locations: listOfDropOffs)
                    }
                    
                    let customerForGeofence = self.selectedCustomer
                    let centerOfGeofence = CLLocationCoordinate2DMake(customerForGeofence?.custLat ?? 0, customerForGeofence?.custLog ?? 0)
                    let geoFenceRegion = CLCircularRegion(center: centerOfGeofence, radius: 100, identifier: "PickUp Location")
                    geoFenceRegion.notifyOnEntry = true
                    geoFenceRegion.notifyOnExit = true
                    self.locationManager.startMonitoring(for: geoFenceRegion)
                    
                    if coordsOfATA.count>1
                    {
                        for z in Range(0...coordsOfATA.count-2)
                        {
                            self.mapThis(originCoordinate: coordsOfATA[z], destinationCord: coordsOfATA[z+1])
                        }
                    }
                }
            }
        }
    }
    @IBAction func getDirections(_ sender: UIButton)
    {
        let customerLocX = selectedCustomer?.custLat ?? 0
        let customerLocY = selectedCustomer?.custLog ?? 0
        let cutomerLocCoord = CLLocationCoordinate2DMake(customerLocX, customerLocY)
        
            let destPlaceMark = MKPlacemark(coordinate: cutomerLocCoord)
            let destItem = MKMapItem(placemark: destPlaceMark)
            destItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking])
    }
}
