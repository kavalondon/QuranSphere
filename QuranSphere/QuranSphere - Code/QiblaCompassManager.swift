//
//  QiblaCompassManager.swift
//  QuranSphere
//

import Foundation
internal import CoreLocation
internal import Combine

class QiblaCompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private let geocoder = CLGeocoder() // 🌟 ADDED: For reverse geocoding
    
    @Published var heading: Double = 0.0
    @Published var qiblaDirection: Double = 0.0
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Locating..." // 🌟 ADDED: Stores the city/town name
    
    // Coordinates for the Kaaba in Makkah
    private let kaabaLatitude = 21.4225
    private let kaabaLongitude = 39.8262
    
    override init() {
        super.init()
    }
    
    // Start services only when entering the Qibla screen to protect the battery
    func startTracking() {
        if locationManager == nil {
            let manager = CLLocationManager()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // Low accuracy to preserve battery
            manager.headingFilter = 1.0 // Filter out minor movements
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
    
    // Completely shut down GPS and Gyro sensors to eliminate background battery drain
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
        calculateQibla(from: location)
        
        // 🌟 BATTERY SAVER: Only reverse geocode if we haven't found the city yet
        if locationName == "Locating..." {
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self, let placemark = placemarks?.first, error == nil else { return }
                
                // Extract Town/City and Country
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
