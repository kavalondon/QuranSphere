//
//  QiblaPrayerTimesView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 20/07/2026.
//
import SwiftUI
internal import CoreLocation
internal import Combine

struct QiblaPrayerTimesView: View {
    @StateObject private var locationManager = QiblaLocationManager()
    @StateObject private var prayerFetcher = PrayerTimeFetcher()
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var bgColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95)
    }
    
    var cardColor: Color {
        isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // MARK: - Minimalist Qibla Compass
                    compassSection
                    
                    // MARK: - Prayer Times
                    prayerTimesSection
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Qibla & Times")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        // 🌟 BATTERY SAVER: Only run sensors when looking at this view
        .onAppear {
            locationManager.requestPermission()
            locationManager.start()
        }
        .onDisappear {
            locationManager.stop()
        }
        // 🌟 FIX: Updated for iOS 17+ (Accepts oldValue and newValue)
        .onChange(of: locationManager.location) { oldValue, newLocation in
            if let loc = newLocation, prayerFetcher.timings.isEmpty && !prayerFetcher.isLoading {
                prayerFetcher.fetchTimes(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            }
        }
    }
    
    // MARK: - Compass UI
    private var compassSection: some View {
        VStack(spacing: 20) {
            Text("Qibla Direction")
                .font(.system(.subheadline, design: .serif)).bold()
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            ZStack {
                // Outer Dial
                Circle()
                    .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 2)
                    .frame(width: 260, height: 260)
                
                // Cardinal Directions
                let cardinals = ["N", "E", "S", "W"]
                ForEach(0..<4) { i in
                    Text(cardinals[i])
                        .font(.system(.caption, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .gray : .gray)
                        .offset(y: -110)
                        .rotationEffect(.degrees(Double(i) * 90))
                }
                
                // Qibla Arrow
                Image(systemName: "location.north.fill")
                    .font(.system(size: 64))
                    .foregroundColor(sageGreen)
                    // The magic calculation: Qibla Bearing minus our True Heading
                    .rotationEffect(.degrees(locationManager.qiblaBearing - locationManager.currentHeading))
                    .shadow(color: sageGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: locationManager.heading?.trueHeading)
                
                // Center Dot
                Circle()
                    .fill(isDarkMode ? Color.white : Color.black)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 260, height: 260)
            .padding(.top, 16)
            
            // Status Text
            if locationManager.location == nil {
                Text("Locating...")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.gray)
            } else {
                Text("Bearing: \(Int(locationManager.qiblaBearing))°")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(sageGreen)
            }
        }
        .padding(24)
        .background(cardColor)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Prayer Times UI
    private var prayerTimesSection: some View {
        VStack(spacing: 16) {
            Text("Today's Prayers")
                .font(.system(.subheadline, design: .serif)).bold()
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            
            if prayerFetcher.isLoading {
                ProgressView()
                    .tint(sageGreen)
                    .padding()
            } else if prayerFetcher.timings.isEmpty {
                Text("Waiting for location...")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 12) {
                    let requiredPrayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
                    
                    ForEach(requiredPrayers, id: \.self) { prayer in
                        if let time = prayerFetcher.timings[prayer] {
                            HStack {
                                Text(prayer)
                                    .font(.system(.body, design: .serif)).bold()
                                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                
                                Spacer()
                                
                                Text(time)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(sageGreen)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(sageGreen.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .padding(16)
                            .background(cardColor)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - CoreLocation Manager
class QiblaLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var qiblaBearing: Double = 0.0
    
    // Robust helper to handle missing true north indoors
    var currentHeading: Double {
        guard let heading = heading else { return 0 }
        return heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
    }
    
    override init() {
        super.init()
        manager.delegate = self
        
        // 🌟 EXTREME BATTERY SAVER: 3km accuracy yields the exact same Qibla bearing globally.
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.headingFilter = 1.0
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func start() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        self.location = latestLocation
        
        // 🌟 EXTREME BATTERY SAVER: Immediately shut down GPS once a coordinate is locked.
        // The magnetometer (heading) will continue running on its own.
        manager.stopUpdatingLocation()
        
        // Calculate exact mathematical bearing to the Kaaba
        self.qiblaBearing = calculateQiblaBearing(userLat: latestLocation.coordinate.latitude,
                                                  userLon: latestLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading
    }
    
    private func calculateQiblaBearing(userLat: Double, userLon: Double) -> Double {
        let kaabaLat = 21.422487 * .pi / 180.0
        let kaabaLon = 39.826206 * .pi / 180.0
        let lat = userLat * .pi / 180.0
        let lon = userLon * .pi / 180.0
        
        let dLon = kaabaLon - lon
        
        let y = sin(dLon) * cos(kaabaLat)
        let x = cos(lat) * sin(kaabaLat) - sin(lat) * cos(kaabaLat) * cos(dLon)
        
        var qibla = atan2(y, x) * 180.0 / .pi
        if qibla < 0 {
            qibla += 360.0
        }
        return qibla
    }
}

// MARK: - API Fetcher for Aladhan
// 🌟 FIX: Marked as @MainActor and upgraded to async/await to satisfy Swift 6 thread safety
@MainActor
class PrayerTimeFetcher: ObservableObject {
    @Published var timings: [String: String] = [:]
    @Published var isLoading = false
    
    func fetchTimes(lat: Double, lon: Double) {
        guard timings.isEmpty else { return }
        self.isLoading = true
        
        let urlString = "https://api.aladhan.com/v1/timings?latitude=\(lat)&longitude=\(lon)&method=2"
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(AladhanResponse.self, from: data)
                self.timings = decodedResponse.data.timings
                self.isLoading = false
            } catch {
                print("Failed to decode prayer times: \(error)")
                self.isLoading = false
            }
        }
    }
}

// MARK: - JSON Models for Aladhan API
// 🌟 FIX: Placed globally and explicitly marked as `Sendable` to clear Swift 6 decoding errors
struct AladhanResponse: Codable, Sendable {
    let data: AladhanData
}

struct AladhanData: Codable, Sendable {
    let timings: [String: String]
}
