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
    
    @State private var showSettings = false
    @State private var currentDate = Date() // Allows toggling days like the reference layout
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    let dummyTimings = PrayerTimings(Fajr: "03:57", Sunrise: "05:42", Dhuhr: "13:19", Asr: "18:21", Maghrib: "20:47", Isha: "21:51")
    
    var body: some View {
        ZStack {
            // Background color matching your app theme
            (isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95))
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - TOP HEADER (Next Prayer & Status)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(prayerManager.nextPrayerName ?? "Dhuhr")
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                
                                Text("3 hrs 44 mins until next")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Settings Button
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(sageGreen)
                                    .padding(10)
                                    .background(sageGreen.opacity(0.12))
                                    .clipShape(Circle())
                            }
                        }
                        
                        // Location & Date Pill Badge
                        HStack(spacing: 6) {
                            Text("TODAY")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                            Text("|")
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text("Rochdale")
                        }
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(sageGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(sageGreen.opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    
                    // MARK: - DATE SELECTOR BAR
                    HStack {
                        Button(action: { changeDay(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text(formattedDate(currentDate))
                                .font(.system(.headline, design: .serif))
                                .fontWeight(.bold)
                                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                            
                            Text("29 Safar 1448") // Hijri estimation placeholder or dynamic string
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(accentGold)
                        }
                        
                        Spacer()
                        
                        Button(action: { changeDay(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(isDarkMode ? Color.white.opacity(0.04) : Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    
                    // MARK: - PRAYER TIMES LIST CARD
                    let displayTimings = prayerManager.timings ?? dummyTimings
                    let isSkeleton = prayerManager.isLoading && prayerManager.timings == nil
                    
                    VStack(spacing: 0) {
                        PrayerRowNew(name: "Fajr", time: prayerManager.to12Hour(time: displayTimings.Fajr), isActive: prayerManager.nextPrayerName == "Fajr", isLast: false, sageGreen: sageGreen, accentGold: accentGold, isDarkMode: isDarkMode)
                        PrayerRowNew(name: "Sunrise", time: prayerManager.to12Hour(time: displayTimings.Sunrise), isActive: prayerManager.nextPrayerName == "Sunrise", isLast: false, sageGreen: sageGreen, accentGold: accentGold, isDarkMode: isDarkMode)
                        PrayerRowNew(name: "Dhuhr", time: prayerManager.to12Hour(time: displayTimings.Dhuhr), isActive: prayerManager.nextPrayerName == "Dhuhr", isLast: false, sageGreen: sageGreen, accentGold: accentGold, isDarkMode: isDarkMode)
                        PrayerRowNew(name: "Asr", time: prayerManager.to12Hour(time: displayTimings.Asr), isActive: prayerManager.nextPrayerName == "Asr", isLast: false, sageGreen: sageGreen, accentGold: accentGold, isDarkMode: isDarkMode)
                        PrayerRowNew(name: "Maghrib", time: prayerManager.to12Hour(time: displayTimings.Maghrib), isActive: prayerManager.nextPrayerName == "Maghrib", isLast: false, sageGreen: sageGreen, accentGold: accentGold, isDarkMode: isDarkMode)
                        PrayerRowNew(name: "Isha", time: prayerManager.to12Hour(time: displayTimings.Isha), isActive: prayerManager.nextPrayerName == "Isha", isLast: true, sageGreen: sageGreen, accentGold: accentGold, isDarkMode: isDarkMode)
                    }
                    .padding(16)
                    .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 15, x: 0, y: 6)
                    .padding(.horizontal, 20)
                    .redacted(reason: isSkeleton ? .placeholder : [])
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            if let location = location {
                Task { await prayerManager.fetchPrayerTimes(for: location, forceRefresh: true) }
            }
        }) {
            PrayerSettingsView()
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
            PrayerNotificationManager.shared.requestPermission()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        return formatter.string(from: date)
    }
    
    private func changeDay(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}

// MARK: - Refactored Clean Prayer Row matching the Reference Layout Style
struct PrayerRowNew: View {
    let name: String
    let time: String
    let isActive: Bool
    let isLast: Bool
    let sageGreen: Color
    let accentGold: Color
    let isDarkMode: Bool
    
    @State private var isMuted = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.system(.headline, design: .serif))
                    .fontWeight(isActive ? .bold : .medium)
                    .foregroundColor(isActive ? (isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20)) : (isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7)))
                
                Spacer()
                
                Text(time)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(isActive ? .bold : .semibold)
                    .foregroundColor(isActive ? accentGold : (isDarkMode ? Color.white.opacity(0.8) : Color.black.opacity(0.6)))
                
                // Notification Bell Toggle Button matching the reference image layout
                Button(action: { isMuted.toggle() }) {
                    Image(systemName: isMuted ? "bell.slash.fill" : "bell.fill")
                        .font(.system(size: 14))
                        .foregroundColor(isMuted ? .gray.opacity(0.4) : sageGreen)
                        .padding(.leading, 12)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            // Active prayer outlined selection border like the reference image
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isActive ? (isDarkMode ? Color.white.opacity(0.05) : sageGreen.opacity(0.05)) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isActive ? sageGreen : Color.clear, lineWidth: 1.5)
            )
            
            if !isLast {
                Divider()
                    .padding(.horizontal, 16)
                    .opacity(isDarkMode ? 0.1 : 0.4)
                    .padding(.vertical, 2)
            }
        }
    }
}
