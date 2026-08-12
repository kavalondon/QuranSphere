import Foundation
internal import CoreLocation
internal import Combine
import MapKit

class QiblaCompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    
    @Published var heading: Double = 0.0
    @Published var qiblaDirection: Double = 0.0
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Locating..."
    @Published var lastLocation: CLLocation?
    
    // Coordinates for the Kaaba in Makkah
    private let kaabaLatitude = 21.4225
    private let kaabaLongitude = 39.8262
    
    // 🌟 THE FIX: This tracks continuous rotation to prevent the 360° spin glitch
    private var lastHeading: Double = 0.0
    
    override init() {
        super.init()
    }
    
    func startTracking() {
        if locationManager == nil {
            let manager = CLLocationManager()
            manager.delegate = self
            
            // 🌟 THE FIX: Increased accuracy slightly for a better initial lock
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            // 🌟 THE FIX: Remove the 1-degree threshold so sensor updates stream continuously at ~60fps
            manager.headingFilter = kCLHeadingFilterNone
            
            self.locationManager = manager
        }
        
        self.authStatus = locationManager?.authorizationStatus ?? .notDetermined
        
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func stopTracking() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
        locationManager = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authStatus = manager.authorizationStatus
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 🌟 THE FIX: Reject cached, old, or highly inaccurate locations
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 2000 { return }
        if abs(location.timestamp.timeIntervalSinceNow) > 10 { return }
        
        self.lastLocation = location
        calculateQibla(from: location)
        
        // Safe to stop updating now that we have a solid, current lock
        manager.stopUpdatingLocation()
        
        if locationName == "Locating..." {
            guard let request = MKReverseGeocodingRequest(location: location) else { return }
            
            request.getMapItems { [weak self] items, error in
                guard let self = self, let mapItem = items?.first, error == nil else { return }
                
                let placemark = mapItem.placemark
                let city = placemark.locality ?? placemark.subAdministrativeArea ?? "Unknown Area"
                let country = placemark.country ?? ""
                
                DispatchQueue.main.async {
                    if country.isEmpty {
                        self.locationName = city
                    } else {
                        self.locationName = "\(city), \(country)"
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let rawHeading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        // 🌟 THE FIX: Calculate shortest path difference to prevent 360-degree snap
        var diff = rawHeading - self.lastHeading
        if diff > 180 { diff -= 360 }
        else if diff < -180 { diff += 360 }
        
        let continuousHeading = self.lastHeading + diff
        self.lastHeading = continuousHeading
        
        DispatchQueue.main.async {
            self.heading = continuousHeading
        }
    }
    
    private func calculateQibla(from userLocation: CLLocation) {
        let lat1 = userLocation.coordinate.latitude * .pi / 180.0
        let lon1 = userLocation.coordinate.longitude * .pi / 180.0
        
        let lat2 = kaabaLatitude * .pi / 180.0
        let lon2 = kaabaLongitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var qiblaRad = atan2(y, x)
        if qiblaRad < 0 { qiblaRad += 2 * .pi }
        
        DispatchQueue.main.async {
            self.qiblaDirection = qiblaRad * 180.0 / .pi
        }
    }
}
