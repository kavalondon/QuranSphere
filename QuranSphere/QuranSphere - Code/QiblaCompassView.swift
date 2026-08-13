//
//  QiblaCompassView.swift
//  QuranSphere
//

import SwiftUI
internal import CoreLocation

// MARK: - Tab Enum
enum QiblaTab: String, Hashable {
    case compass
    case prayers
}

struct QiblaCompassView: View {
    @StateObject private var compassManager = QiblaCompassManager()
    @AppStorage("useLocationForQibla") private var useLocationForQibla = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Toggle State
    @State private var selectedTab: QiblaTab = .compass
    @Namespace private var animationNamespace
    
    // Core App Colors
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    // Haptic Engines
    private let selectionFeedback = UISelectionFeedbackGenerator()
    @State private var lastHapticDegree: Int = 0
    @State private var hasTriggeredAlignmentHaptic = false
    
    // Mathematical exactness for alignment
    var alignmentDifference: Double {
        var diff = abs(compassManager.qiblaDirection - compassManager.heading).truncatingRemainder(dividingBy: 360)
        if diff > 180 { diff = 360 - diff }
        return diff
    }
    
    var isAligned: Bool {
        return alignmentDifference < 2.0
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Custom Sliding Toggle
            HStack(spacing: 0) {
                toggleButton(title: "Qibla Finder", tab: .compass)
                toggleButton(title: "Prayer Times", tab: .prayers)
            }
            .padding(4)
            .background(isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.12))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // MARK: - Dynamic Content Area (No TabView Bug!)
            if selectedTab == .compass {
                compassPage
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                prayersPage
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
            
            Spacer(minLength: 40)
        }
        // Smoothly animates the page swap
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
        .onAppear {
            selectionFeedback.prepare()
            if useLocationForQibla {
                compassManager.startTracking()
            }
        }
        .onDisappear {
            compassManager.stopTracking()
        }
    }
    
    // MARK: - Toggle Button Helper
    @ViewBuilder
    private func toggleButton(title: String, tab: QiblaTab) -> some View {
        Button(action: {
            // Only trigger if they are tapping a new tab
            if selectedTab != tab {
                selectionFeedback.selectionChanged()
                selectedTab = tab
            }
        }) {
            Text(title)
                .font(.system(.subheadline, design: .serif))
                .fontWeight(selectedTab == tab ? .bold : .medium)
                .foregroundColor(selectedTab == tab ? .white : (isDarkMode ? .gray : .gray))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if selectedTab == tab {
                            Capsule()
                                .fill(sageGreen)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animationNamespace)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Page 1: Original Compass UI
    private var compassPage: some View {
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
            .padding(.top, 8)
            
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
                
                // 🌟 MINIMALIST COMPASS DISPLAY
                ZStack {
                    Circle()
                        .fill(accentGold.opacity(isAligned ? 0.35 : 0.0))
                        .frame(width: 220, height: 220)
                        .blur(radius: 35)
                        .scaleEffect(isAligned ? 1.2 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAligned)
                    
                    Circle()
                        .stroke(
                            isAligned ? accentGold.opacity(0.6) : (isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.06)),
                            lineWidth: isAligned ? 2.5 : 1.5
                        )
                        .frame(width: 280, height: 280)
                        .shadow(color: isAligned ? accentGold.opacity(0.5) : Color.clear, radius: 10)
                    
                    VStack {
                        Image(systemName: isAligned ? "checkmark.circle.fill" : "chevron.up")
                            .font(.system(size: isAligned ? 22 : 24, weight: .black))
                            .foregroundColor(isAligned ? accentGold : (isDarkMode ? Color.white.opacity(0.25) : Color.gray.opacity(0.35)))
                            .shadow(color: isAligned ? accentGold : Color.clear, radius: isAligned ? 12 : 0)
                            .offset(y: -20)
                        Spacer()
                    }
                    .frame(height: 330)
                    
                    VStack {
                        Text("N")
                            .font(.system(.caption, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .gray.opacity(0.4) : .gray.opacity(0.5))
                        Spacer()
                    }
                    .frame(height: 230)
                    .rotationEffect(.degrees(-compassManager.heading))
                    
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 0.05, green: 0.05, blue: 0.05))
                                .frame(width: 32, height: 40)
                                .shadow(color: isAligned ? accentGold : Color.black.opacity(0.25), radius: isAligned ? 20 : 4)
                            
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
                        
                        Rectangle()
                            .fill(isAligned ? accentGold : sageGreen)
                            .frame(width: isAligned ? 3.5 : 2.5, height: 100)
                            .cornerRadius(1.5)
                            .shadow(color: isAligned ? accentGold : Color.clear, radius: 8)
                        
                        Spacer()
                    }
                    .frame(height: 300)
                    .rotationEffect(.degrees(compassManager.qiblaDirection - compassManager.heading))
                    
                    Circle()
                        .fill(isAligned ? accentGold : sageGreen)
                        .frame(width: 14, height: 14)
                        .shadow(color: isAligned ? accentGold : Color.clear, radius: 8)
                        .overlay(
                            Circle().stroke(isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95), lineWidth: 3)
                        )
                }
                .frame(height: 340)
                .onChange(of: compassManager.heading) { _, newHeading in
                    let currentDegree = Int(newHeading)
                    if currentDegree != lastHapticDegree {
                        selectionFeedback.selectionChanged()
                        lastHapticDegree = currentDegree
                    }
                    if isAligned {
                        triggerAlignmentHaptic()
                    }
                }
                
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
    
    // MARK: - Page 2: Original Prayer Times View
    private var prayersPage: some View {
        VStack {
            // 🌟 Exactly your original injection!
            PrayerTimesView(location: compassManager.lastLocation)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Haptic Logic
    private func triggerAlignmentHaptic() {
        if !hasTriggeredAlignmentHaptic {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            hasTriggeredAlignmentHaptic = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                hasTriggeredAlignmentHaptic = false
            }
        }
    }
}
