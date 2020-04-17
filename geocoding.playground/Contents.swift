import CoreLocation
import MapKit

func getCoordinate( addressString : String,
                    completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void )->CLLocationCoordinate2D
{
    var location1:CLLocation?
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(addressString) { (placemarks, error) in
        if error == nil {
            if let placemark = placemarks?[0] {
                location1 = placemark.location!
                completionHandler(location1?.coordinate ?? CLLocationCoordinate2D(), nil)
                print(location1?.coordinate)
            }
        }
        
        completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
    }
    return(location1?.coordinate ?? CLLocationCoordinate2D())
}
let A = getCoordinate(addressString: "70 Iroquois Court, Chesterbrook, PA, 19087") { (CLLocationCoordinate2D, NSError) in
    return(0)
}

print("hytnt",A)
