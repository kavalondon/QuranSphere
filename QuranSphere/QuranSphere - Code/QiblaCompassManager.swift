//
//  QiblaCompassManager.swift
//  QuranSphere
//

import Foundation
internal import CoreLocation
internal import Combine
import MapKit // 🌟 ADDED: Required for iOS 26.0+ Geocoding

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
    
    override init() {
        super.init()
    }
    
    func startTracking() {
        if locationManager == nil {
            let manager = CLLocationManager()
            manager.delegate = self
            // LOW POWER: 3km accuracy is perfect. It gives the same Qibla angle globally.
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            manager.headingFilter = 1.0
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
        
        // 🌟 ADDED: Save the location so the PrayerTimesManager can use it
        self.lastLocation = location
        
        calculateQibla(from: location)
        
        // EXTREME BATTERY SAVER: Shut down the GPS antenna immediately after getting a lock.
        manager.stopUpdatingLocation()
        
        // 🌟 UPDATED: MapKit implementation for iOS 26.0+
        if locationName == "Locating..." {
            // Initiate the modern MapKit geocoding request
            guard let request = MKReverseGeocodingRequest(location: location) else { return }
            
            request.getMapItems { [weak self] items, error in
                guard let self = self, let mapItem = items?.first, error == nil else { return }
                
                // Extract MapKit's placemark from the map item
                let placemark = mapItem.placemark
                
                // Extract Town/City and Country natively
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
        // True Heading (or magnetic heading if unavailable)
        self.heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }
    
    // Spherical trigonometry calculation to align direction to Kaaba
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
        
        self.qiblaDirection = qiblaRad * 180.0 / .pi
    }
}
