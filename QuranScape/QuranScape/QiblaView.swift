//
//  QiblaView.swift
//  QuranScape
//
//  Created by Khaver Javed on 16/07/2026.
//

import SwiftUI

struct QiblaView: View {
    // This connects to the battery-saving location manager we built
    @StateObject private var qiblaManager = QiblaManager()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Qibla Compass")
                .font(.system(.title2, design: .serif))
                .fontWeight(.bold)
            
            if qiblaManager.locationError {
                Text("Please enable location services in your iPhone settings to find the Qibla.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ZStack {
                    // The outer compass ring
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                        .frame(width: 300, height: 300)
                    
                    // The Needle pointing to Mecca
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43)) // Your sage green
                        // The magic happens here: we subtract the heading from the destination
                        .rotationEffect(Angle(degrees: qiblaManager.qiblaDirection - qiblaManager.heading))
                        // Smooth animation as you spin
                        .animation(.easeOut(duration: 0.2), value: qiblaManager.heading)
                }
                
                Text("Point the needle forward")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.gray)
            }
        }
        // BATTERY SAVER: Only run GPS when looking at this specific page
        .onAppear {
            qiblaManager.startUpdating()
        }
        .onDisappear {
            qiblaManager.stopUpdating()
        }
    }
}
