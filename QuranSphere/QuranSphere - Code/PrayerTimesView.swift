//
//  PrayerTimesView.swift
//  QuranSphere
//

import SwiftUI
internal import CoreLocation

struct PrayerTimesView: View {
    @StateObject private var prayerManager = PrayerTimesManager()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var location: CLLocation?
    
    @State private var showSettings = false // 🌟 ADDED: Controls the settings sheet
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    let dummyTimings = PrayerTimings(Fajr: "04:30", Sunrise: "06:00", Dhuhr: "13:00", Asr: "16:45", Maghrib: "20:00", Isha: "21:30")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 🌟 ADDED: HStack to place the Settings gear icon next to the title
            HStack {
                Text("Daily Prayers")
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Spacer()
                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "slider.horizontal.3") // Elegant settings icon
                        .font(.system(size: 18))
                        .foregroundColor(sageGreen)
                        .padding(8)
                        .background(sageGreen.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            // 🌟 ADDED: Show the new settings sheet and refresh times when dismissed
            .sheet(isPresented: $showSettings, onDismiss: {
                if let location = location {
                    Task {
                        // Force refresh so Asr times update instantly if changed
                        await prayerManager.fetchPrayerTimes(for: location, forceRefresh: true)
                    }
                }
            }) {
                PrayerSettingsView()
            }
            
            if let error = prayerManager.errorMessage, prayerManager.timings == nil {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(.subheadline))
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                let displayTimings = prayerManager.timings ?? dummyTimings
                let isSkeleton = prayerManager.isLoading && prayerManager.timings == nil
                
                VStack(spacing: 0) {
                    PrayerRow(name: "Fajr", time: prayerManager.to12Hour(time: displayTimings.Fajr), icon: "sun.and.horizon.fill", isActive: prayerManager.nextPrayerName == "Fajr", isLast: false)
                    PrayerRow(name: "Sunrise", time: prayerManager.to12Hour(time: displayTimings.Sunrise), icon: "sunrise.fill", isActive: prayerManager.nextPrayerName == "Sunrise", isLast: false)
                    PrayerRow(name: "Dhuhr", time: prayerManager.to12Hour(time: displayTimings.Dhuhr), icon: "sun.max.fill", isActive: prayerManager.nextPrayerName == "Dhuhr", isLast: false)
                    PrayerRow(name: "Asr", time: prayerManager.to12Hour(time: displayTimings.Asr), icon: "sun.min.fill", isActive: prayerManager.nextPrayerName == "Asr", isLast: false)
                    PrayerRow(name: "Maghrib", time: prayerManager.to12Hour(time: displayTimings.Maghrib), icon: "sunset.fill", isActive: prayerManager.nextPrayerName == "Maghrib", isLast: false)
                    PrayerRow(name: "Isha", time: prayerManager.to12Hour(time: displayTimings.Isha), icon: "moon.stars.fill", isActive: prayerManager.nextPrayerName == "Isha", isLast: true)
                }
                .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 15, x: 0, y: 6)
                .padding(.horizontal, 20)
                .redacted(reason: isSkeleton ? .placeholder : [])
                .animation(.easeInOut(duration: 0.4), value: isSkeleton)
            }
        }
        .onChange(of: location) { newLocation in
            if let newLocation = newLocation {
                Task { await prayerManager.fetchPrayerTimes(for: newLocation) }
            }
        }
        .onAppear {
            if let location = location {
                Task { await prayerManager.fetchPrayerTimes(for: location) }
            }
        }
    }
}

// 🌟 Updated Reusable Subview supporting highlighting
struct PrayerRow: View {
    let name: String
    let time: String
    let icon: String
    let isActive: Bool // Triggers the dynamic highlighting
    let isLast: Bool
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 18) {
                // Soft tinted circular background for the icon
                ZStack {
                    Circle()
                        .fill(isActive ? accentGold.opacity(0.18) : sageGreen.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .foregroundColor(isActive ? accentGold : sageGreen)
                        .font(.system(size: 18, weight: .medium))
                        // Gentle pulse animation if it's the next prayer
                        .scaleEffect(isActive ? 1.08 : 1.0)
                        .animation(isActive ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: isActive)
                }
                
                Text(name)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                
                if isActive {
                    Text("Next")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(accentGold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(accentGold.opacity(0.15))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(time)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? accentGold : (isDarkMode ? Color.white.opacity(0.8) : Color.black.opacity(0.6)))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(isActive ? accentGold.opacity(0.04) : Color.clear)
            
            if !isLast {
                Divider()
                    .padding(.leading, 78)
                    .padding(.trailing, 16)
                    .opacity(0.7)
            }
        }
    }
}
