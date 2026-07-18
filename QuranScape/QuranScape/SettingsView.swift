//
//  SettingsView.swift
//  QuranScape
//
//  Created by Khaver Javed on 16/07/2026.
//

import SwiftUI

struct SettingsView: View {
    // These automatically save to the device's memory
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 18.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(.teal) // Matches your premium branding
                }
                
                Section(header: Text("Typography")) {
                    VStack(alignment: .leading) {
                        Text("Reading Font Size: \(Int(fontSize))")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        
                        Slider(value: $fontSize, in: 14...36, step: 1)
                            .tint(.teal)
                    }
                    
                    // Live Preview
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.system(size: fontSize))
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
