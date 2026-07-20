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
        VStack {
            Text("Qibla Finder")
                .font(.system(.title2, design: .serif)).bold()
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.top)
            
            Text("Rotate your phone until the Kaaba aligns with the top target.")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Accurate Global Location Display
            if compassManager.authStatus == .authorizedWhenInUse || compassManager.authStatus == .authorizedAlways {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(sageGreen)
                            .font(.system(size: 14))
                        Text(compassManager.locationName)
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    }
                }
                .padding(.top, 16)
            }
            
            Spacer()
            
            if useLocationForQibla && (compassManager.authStatus == .authorizedWhenInUse || compassManager.authStatus == .authorizedAlways) {
                
                // Beautiful Minimal Compass Display
                ZStack {
                    // Outer Degree Ring
                    Circle()
                        .stroke(isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.08), lineWidth: 2)
                        .frame(width: 300, height: 300)
                    
                    // Fixed Phone Forward Target (Top of the screen)
                    VStack {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(isAligned ? accentGold : (isDarkMode ? Color.white.opacity(0.3) : Color.gray.opacity(0.4)))
                            .offset(y: -24)
                        Spacer()
                    }
                    .frame(height: 350)
                    
                    // North Marker (Rotates to show physical North for context)
                    VStack {
                        Text("N")
                            .font(.system(.headline, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .gray.opacity(0.6) : .gray.opacity(0.6))
                        Spacer()
                    }
                    .frame(height: 250)
                    .rotationEffect(.degrees(-compassManager.heading)) // North is always mathematically negative to heading
                    
                    // The Rotating Kaaba & Needle
                    VStack(spacing: 0) {
                        // 🌟 Custom Minimalist Kaaba Icon
                        ZStack {
                            // Deep black core
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 0.05, green: 0.05, blue: 0.05))
                                .frame(width: 34, height: 42)
                                .shadow(color: isAligned ? accentGold.opacity(0.8) : Color.black.opacity(0.3), radius: isAligned ? 15 : 5)
                            
                            // Gold Band
                            Rectangle()
                                .fill(accentGold)
                                .frame(width: 34, height: 4)
                                .offset(y: -8)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(accentGold.opacity(0.8), lineWidth: 1.5)
                        )
                        .padding(.bottom, 6)
                        
                        // Connecting Needle Line
                        Rectangle()
                            .fill(isAligned ? accentGold : sageGreen)
                            .frame(width: 3, height: 110)
                            .cornerRadius(1.5)
                        
                        Spacer()
                    }
                    .frame(height: 330)
                    // The actual bearing of Qibla relative to the top of the phone
                    .rotationEffect(.degrees(compassManager.qiblaDirection - compassManager.heading))
                    
                    // Center Pivot
                    Circle()
                        .fill(isAligned ? accentGold : sageGreen)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle().stroke(isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95), lineWidth: 3)
                        )
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: compassManager.heading)
                .onChange(of: compassManager.heading) { _, _ in
                    if isAligned {
                        triggerHapticFeedback()
                    }
                }
                
                Spacer()
                
                // Live reading coordinates
                HStack(spacing: 50) {
                    VStack(spacing: 6) {
                        Text("Heading")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        Text("\(Int(compassManager.heading))°")
                            .font(.system(.title3, design: .monospaced)).bold()
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    VStack(spacing: 6) {
                        Text("Qibla Angle")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        Text("\(Int(compassManager.qiblaDirection))°")
                            .font(.system(.title3, design: .monospaced)).bold()
                            .foregroundColor(sageGreen)
                    }
                }
                .padding(.bottom, 40)
                
            } else {
                // Permissions UI
                VStack(spacing: 16) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Location Access Required")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text("We calculate the precise mathematical angle to the Kaaba using coordinates from your device's location sensor. This is done locally on your device.")
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
                Spacer()
            }
        }
        .frame(minHeight: 600)
        .onAppear {
            if useLocationForQibla {
                compassManager.startTracking()
            }
        }
        .onDisappear {
            compassManager.stopTracking()
        }
    }
    
    // Limits haptics so it doesn't vibrate constantly while inside the 2-degree threshold
    @State private var hasTriggeredHaptic = false
    private func triggerHapticFeedback() {
        if !hasTriggeredHaptic {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            hasTriggeredHaptic = true
            
            // Reset after 1 second so it can trigger again if they move away and come back
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                hasTriggeredHaptic = false
            }
        }
    }
}
