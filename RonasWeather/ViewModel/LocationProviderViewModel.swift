import CoreLocation

class LocationProviderViewModel {
    private lazy var geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    func callCityNameFromLocation(location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard
                error == nil,
                let placemarks = placemarks,
                let placemark = placemarks.first,
                let city = placemark.locality
            else {
                completion(nil)
                return
            }
            
            completion(city)
        }
    }
}
