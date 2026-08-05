//
//  QiblaCompassView.swift
//  QuranSphere
//

import SwiftUI
internal import CoreLocation

struct QiblaCompassView: View {
    @StateObject private var compassManager = QiblaCompassManager()
    @AppStorage("useLocationForQibla") private var useLocationForQibla = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Core App Colors
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    // Mathematical exactness for alignment
    var alignmentDifference: Double {
        var diff = abs(compassManager.qiblaDirection - compassManager.heading).truncatingRemainder(dividingBy: 360)
        if diff > 180 { diff = 360 - diff }
        return diff
    }
    
    var isAligned: Bool {
        return alignmentDifference < 2.0 // 2 degrees of forgiveness
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Qibla Finder")
                        .font(.system(.title2, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    
                    Text("Rotate your phone to align with the Kaaba")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Location Name Display
                if compassManager.authStatus == .authorizedWhenInUse || compassManager.authStatus == .authorizedAlways {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(sageGreen)
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text(compassManager.locationName)
                            .font(.system(.subheadline, design: .serif))
                            .fontWeight(.medium)
                            .foregroundColor(isDarkMode ? .white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.2))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.03))
                    .clipShape(Capsule())
                }
                
                if useLocationForQibla && (compassManager.authStatus == .authorizedWhenInUse || compassManager.authStatus == .authorizedAlways) {
                    
                    // 🌟 MINIMALIST COMPASS DISPLAY WITH ENHANCED GLOW
                    ZStack {
                        // 1. Radiant Aura Halo (Visible only when aligned)
                        Circle()
                            .fill(accentGold.opacity(isAligned ? 0.35 : 0.0))
                            .frame(width: 220, height: 220)
                            .blur(radius: 35)
                            .scaleEffect(isAligned ? 1.2 : 0.8)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAligned)
                        
                        // 2. Outer Degree Ring
                        Circle()
                            .stroke(
                                isAligned ? accentGold.opacity(0.6) : (isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.06)),
                                lineWidth: isAligned ? 2.5 : 1.5
                            )
                            .frame(width: 280, height: 280)
                            .shadow(color: isAligned ? accentGold.opacity(0.5) : Color.clear, radius: 10)
                        
                        // 3. Top Alignment Target Indicator
                        VStack {
                            Image(systemName: isAligned ? "checkmark.circle.fill" : "chevron.up")
                                .font(.system(size: isAligned ? 22 : 24, weight: .black))
                                .foregroundColor(isAligned ? accentGold : (isDarkMode ? Color.white.opacity(0.25) : Color.gray.opacity(0.35)))
                                .shadow(color: isAligned ? accentGold : Color.clear, radius: isAligned ? 12 : 0)
                                .offset(y: -20)
                            Spacer()
                        }
                        .frame(height: 330)
                        
                        // 4. North Marker (Soft Contextual Indicator)
                        VStack {
                            Text("N")
                                .font(.system(.caption, design: .serif)).bold()
                                .foregroundColor(isDarkMode ? .gray.opacity(0.4) : .gray.opacity(0.5))
                            Spacer()
                        }
                        .frame(height: 230)
                        .rotationEffect(.degrees(-compassManager.heading))
                        
                        // 5. The Rotating Kaaba & Needle
                        VStack(spacing: 0) {
                            // Custom Minimalist Kaaba Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(red: 0.05, green: 0.05, blue: 0.05))
                                    .frame(width: 32, height: 40)
                                    .shadow(color: isAligned ? accentGold : Color.black.opacity(0.25), radius: isAligned ? 20 : 4)
                                
                                // Gold Band
                                Rectangle()
                                    .fill(accentGold)
                                    .frame(width: 32, height: 4)
                                    .offset(y: -7)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(accentGold.opacity(isAligned ? 1.0 : 0.7), lineWidth: isAligned ? 2 : 1)
                            )
                            .padding(.bottom, 6)
                            
                            // Connecting Needle Line
                            Rectangle()
                                .fill(isAligned ? accentGold : sageGreen)
                                .frame(width: isAligned ? 3.5 : 2.5, height: 100)
                                .cornerRadius(1.5)
                                .shadow(color: isAligned ? accentGold : Color.clear, radius: 8)
                            
                            Spacer()
                        }
                        .frame(height: 300)
                        .rotationEffect(.degrees(compassManager.qiblaDirection - compassManager.heading))
                        
                        // 6. Center Pivot
                        Circle()
                            .fill(isAligned ? accentGold : sageGreen)
                            .frame(width: 14, height: 14)
                            .shadow(color: isAligned ? accentGold : Color.clear, radius: 8)
                            .overlay(
                                Circle().stroke(isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95), lineWidth: 3)
                            )
                    }
                    .frame(height: 340)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: compassManager.heading)
                    .onChange(of: compassManager.heading) { _, _ in
                        if isAligned {
                            triggerHapticFeedback()
                        }
                    }
                    
                    // 🌟 DAILY PRAYERS INTEGRATED DIRECTLY BELOW THE COMPASS
                    PrayerTimesView(location: compassManager.lastLocation)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    
                } else {
                    // Permissions UI
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.gray)
                        
                        Text("Location Access Required")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text("We calculate the precise mathematical angle to the Kaaba using coordinates from your device's location sensor.")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button("Grant Permission") {
                            compassManager.startTracking()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(sageGreen)
                        .foregroundColor(.white)
                        .font(.system(.headline, design: .rounded))
                        .clipShape(Capsule())
                        .padding(.top, 12)
                    }
                    .padding(.top, 40)
                }
            }
        }
        .onAppear {
            if useLocationForQibla {
                compassManager.startTracking()
            }
        }
        .onDisappear {
            compassManager.stopTracking()
        }
    }
    
    @State private var hasTriggeredHaptic = false
    private func triggerHapticFeedback() {
        if !hasTriggeredHaptic {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            hasTriggeredHaptic = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                hasTriggeredHaptic = false
            }
        }
    }
}
