//
//  QiblaManager.swift
//  QuranSphere
//
//  Created by Khaver Javed on 16/07/2026.
//

import Foundation
internal import CoreLocation
internal import Combine

class QiblaManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var heading: Double = 0.0
    @Published var qiblaDirection: Double = 0.0
    @Published var locationError: Bool = false
    
    // Coordinates for the Kaaba
    let kaabaLatitude = 21.422487
    let kaabaLongitude = 39.826206
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        // BATTERY SAVER: We only need approximate location to calculate a global bearing.
        // This prevents the GPS chip from draining the battery.
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // Call this ONLY when the Qibla view appears
    func startUpdating() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // Call this when the Qibla view disappears
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        calculateQibla(userLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Use true heading if available, otherwise magnetic
        self.heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = true
    }
    
    // Great Circle Bearing Formula
    private func calculateQibla(userLocation: CLLocation) {
        let userLat = userLocation.coordinate.latitude.toRadians()
        let userLon = userLocation.coordinate.longitude.toRadians()
        let meccaLat = kaabaLatitude.toRadians()
        let meccaLon = kaabaLongitude.toRadians()
        
        let dLon = meccaLon - userLon
        
        let y = sin(dLon) * cos(meccaLat)
        let x = cos(userLat) * sin(meccaLat) - sin(userLat) * cos(meccaLat) * cos(dLon)
        
        var qibla = atan2(y, x).toDegrees()
        if qibla < 0 {
            qibla += 360
        }
        
        self.qiblaDirection = qibla
    }
}

// Math Extensions for the bearing calculation
extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
}
