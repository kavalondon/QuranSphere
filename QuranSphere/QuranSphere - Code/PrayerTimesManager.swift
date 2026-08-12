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
    let school: Int
    let method: Int
    let isAutopilot: Bool
    let timings: PrayerTimings
}

// MARK: - Manager
@MainActor
class PrayerTimesManager: ObservableObject {
    @Published var timings: PrayerTimings?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var nextPrayerName: String?
    
    // 🌟 THE FIX: Updated cache key to force a fresh pull with the accurate settings
    private let cacheKey = "QuranSphere_CachedPrayerTimes_v2"
    
    func fetchPrayerTimes(for location: CLLocation, forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        // 1. Read User Settings
        let school = UserDefaults.standard.integer(forKey: "asrSchool")
        var method = UserDefaults.standard.integer(forKey: "calcMethod")
        if method == 0 { method = 2 } // Fallback to ISNA if not set
        
        // Check if Autopilot is enabled (defaults to true if the user hasn't toggled it yet)
        let isAutopilot = UserDefaults.standard.object(forKey: "isAutopilotEnabled") == nil ? true : UserDefaults.standard.bool(forKey: "isAutopilotEnabled")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: Date())
        
        // 2. CACHING: Prevent unnecessary network calls
        if !forceRefresh, let cachedData = loadCachedData(),
           cachedData.dateString == dateString,
           cachedData.school == school,
           cachedData.method == method,
           cachedData.isAutopilot == isAutopilot {
            
            let cachedLocation = CLLocation(latitude: cachedData.latitude, longitude: cachedData.longitude)
            if location.distance(from: cachedLocation) < 10000 {
                self.timings = cachedData.timings
                self.calculateNextPrayer(from: cachedData.timings)
                self.isLoading = false
                return
            }
        }
        
        // 3. 🌟 THE FIX: AUTOPILOT & HIGH LATITUDE LOGIC
        var methodParameter = ""
        var highLatitudeParameter = ""
        var tuneParameter = ""
        
        if isAutopilot {
            // Match Pillars exactly for UK & High Latitudes
            // 15 = Moonsighting Committee Worldwide
            methodParameter = "&method=15"
            // 3 = Angle Based / Twilight Angle Rule
            highLatitudeParameter = "&latitudeAdjustmentMethod=3"
            // Custom Offsets: +5 mins Dhuhr, +3 mins Maghrib
            tuneParameter = "&tune=0,0,0,5,0,3,0,0,0"
        } else {
            methodParameter = "&method=\(method)"
            // Always apply a high latitude fallback so the API doesn't crash during UK summers
            highLatitudeParameter = "&latitudeAdjustmentMethod=3"
            tuneParameter = ""
        }
        
        let urlString = "https://api.aladhan.com/v1/timings/\(dateString)?latitude=\(lat)&longitude=\(lon)&school=\(school)\(methodParameter)\(highLatitudeParameter)\(tuneParameter)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL constructed."
            isLoading = false
            return
        }
        
        // 4. FETCH
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PrayerApiResponse.self, from: data)
            let fetchedTimings = decodedResponse.data.timings
            
            self.timings = fetchedTimings
            self.calculateNextPrayer(from: fetchedTimings)
            
            // Save to cache including settings
            let newCache = CachedPrayerData(dateString: dateString, latitude: lat, longitude: lon, school: school, method: method, isAutopilot: isAutopilot, timings: fetchedTimings)
            saveToCache(newCache)
            
        } catch {
            if self.timings == nil {
                self.errorMessage = "Unable to fetch times. Check your connection."
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Helpers
    func to12Hour(time: String) -> String {
        let cleanTime = time.components(separatedBy: " ").first ?? time
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "HH:mm"
        guard let date = inFormatter.date(from: cleanTime) else { return time }
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "h:mm a"
        return outFormatter.string(from: date)
    }
    
    private func calculateNextPrayer(from timings: PrayerTimings) {
        let prayers = [("Fajr", timings.Fajr), ("Sunrise", timings.Sunrise), ("Dhuhr", timings.Dhuhr),
                       ("Asr", timings.Asr), ("Maghrib", timings.Maghrib), ("Isha", timings.Isha)]
        
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
        self.nextPrayerName = "Fajr"
    }
    
    // MARK: - Caching
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
