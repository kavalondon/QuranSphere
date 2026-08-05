//
//  PrayerTimesManager.swift
//  QuranSphere
//

import Foundation
internal import CoreLocation
internal import Combine

// MARK: - API Models
struct PrayerApiResponse: Codable {
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: PrayerTimings
}

struct PrayerTimings: Codable, Equatable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

// MARK: - Cache Model
struct CachedPrayerData: Codable {
    let dateString: String
    let latitude: Double
    let longitude: Double
    let timings: PrayerTimings
}

// MARK: - Manager
@MainActor
class PrayerTimesManager: ObservableObject {
    @Published var timings: PrayerTimings?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var nextPrayerName: String?
    
    private let cacheKey = "QuranSphere_CachedPrayerTimes"
    
    func fetchPrayerTimes(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: Date())
        
        // 1. CACHING: Check if we already have today's times for this approximate location
        if let cachedData = loadCachedData(),
           cachedData.dateString == dateString {
            
            let cachedLocation = CLLocation(latitude: cachedData.latitude, longitude: cachedData.longitude)
            let distanceInMeters = location.distance(from: cachedLocation)
            
            // If the user hasn't moved more than 10km (approx 6 miles), use cached times
            if distanceInMeters < 10000 {
                self.timings = cachedData.timings
                self.calculateNextPrayer(from: cachedData.timings)
                self.isLoading = false
                return
            }
        }
        
        // 2. FETCH: If no valid cache, fetch from network
        let urlString = "https://api.aladhan.com/v1/timings/\(dateString)?latitude=\(lat)&longitude=\(lon)&method=2"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL constructed."
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PrayerApiResponse.self, from: data)
            let fetchedTimings = decodedResponse.data.timings
            
            self.timings = fetchedTimings
            self.calculateNextPrayer(from: fetchedTimings)
            
            // Save to cache
            let newCache = CachedPrayerData(dateString: dateString, latitude: lat, longitude: lon, timings: fetchedTimings)
            saveToCache(newCache)
            
        } catch {
            if self.timings == nil { // Only show error if we have no fallback data
                self.errorMessage = "Unable to fetch times. Check your connection."
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Format & Logic Helpers
    
    // Helper to format AlAdhan's 24hr "15:45 (BST)" into a clean 12hr "3:45 PM"
    func to12Hour(time: String) -> String {
        // Strip timezone string if present
        let cleanTime = time.components(separatedBy: " ").first ?? time
        
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "HH:mm"
        guard let date = inFormatter.date(from: cleanTime) else { return time }
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "h:mm a"
        return outFormatter.string(from: date)
    }
    
    // Determine the next upcoming prayer based on current time
    private func calculateNextPrayer(from timings: PrayerTimings) {
        let prayers = [
            ("Fajr", timings.Fajr),
            ("Sunrise", timings.Sunrise),
            ("Dhuhr", timings.Dhuhr),
            ("Asr", timings.Asr),
            ("Maghrib", timings.Maghrib),
            ("Isha", timings.Isha)
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let nowString = formatter.string(from: Date())
        
        for prayer in prayers {
            let cleanTime = prayer.1.components(separatedBy: " ").first ?? prayer.1
            if nowString < cleanTime {
                self.nextPrayerName = prayer.0
                return
            }
        }
        
        // If all prayers have passed today, the next prayer is Fajr tomorrow
        self.nextPrayerName = "Fajr"
    }
    
    // MARK: - UserDefaults Caching
    private func saveToCache(_ data: CachedPrayerData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }
    
    private func loadCachedData() -> CachedPrayerData? {
        if let savedData = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode(CachedPrayerData.self, from: savedData) {
            return decoded
        }
        return nil
    }
}
