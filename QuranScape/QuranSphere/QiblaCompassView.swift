//
//  QiblaCompassView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 16/07/2026.
//

import SwiftUI
internal import CoreLocation

struct QiblaCompassView: View {
    @StateObject private var compassManager = QiblaCompassManager()
    @AppStorage("useLocationForQibla") private var useLocationForQibla = true
    
    var body: some View {
        VStack {
            Text("Qibla Finder")
                .font(.title2)
                .bold()
                .padding(.top)
            
            Text("Align both needles to find the Kaaba")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if useLocationForQibla && (compassManager.authStatus == .authorizedWhenInUse || compassManager.authStatus == .authorizedAlways) {
                
                // Beautiful Minimal Compass Display
                ZStack {
                    // Outer Degree Ring
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 2)
                        .frame(width: 280, height: 280)
                    
                    // North Indicator Needle
                    Image(systemName: "triangle.fill")
                        .resizable()
                        .foregroundColor(.primary)
                        .frame(width: 15, height: 25)
                        .offset(y: -130)
                        .rotationEffect(.init(degrees: -compassManager.heading))
                    
                    // Green Qibla Arrow
                    Image(systemName: "location.north.line.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.pillarsSage)
                        .frame(width: 40, height: 160)
                        // Align needle rotation by subtracting actual heading
                        .rotationEffect(.init(degrees: compassManager.qiblaDirection - compassManager.heading))
                    
                    // Golden Center Target
                    Circle()
                        .fill(Color.pillarsAccentGold)
                        .frame(width: 14, height: 14)
                }
                .animation(.linear(duration: 0.15), value: compassManager.heading)
                .onChange(of: compassManager.heading) { oldValue, newValue in
                    let difference = abs((compassManager.qiblaDirection - newValue).truncatingRemainder(dividingBy: 360))
                    // When user aligns perfectly within 2 degrees, trigger light haptic feedback
                    if difference < 2.0 || difference > 358.0 {
                        triggerHapticFeedback()
                    }
                }
                
                Spacer()
                
                // Live reading coordinates
                HStack(spacing: 40) {
                    VStack {
                        Text("Heading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(compassManager.heading))°")
                            .font(.title3)
                            .bold()
                    }
                    VStack {
                        Text("Qibla Angle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(compassManager.qiblaDirection))°")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.pillarsSage)
                    }
                }
                .padding(.bottom, 40)
                
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Location Access Required")
                        .font(.headline)
                    Text("We calculate the precise mathematical angle to the Kaaba using coordinates from your device's location sensor. This is done locally on your device.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Grant Permission") {
                        compassManager.startTracking()
                    }
                    .padding()
                    .background(Color.pillarsSage)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Spacer()
            }
        }
        .onAppear {
            if useLocationForQibla {
                compassManager.startTracking()
            }
        }
        .onDisappear {
            // Pillars style battery saving execution logic: kill sensors immediately
            compassManager.stopTracking()
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
