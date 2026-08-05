//
//  PrayerSettingsView.swift
//  QuranSphere
//

import SwiftUI

struct PrayerSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // Core Settings
    @AppStorage("asrSchool") private var asrSchool: Int = 0
    @AppStorage("calcMethod") private var calcMethod: Int = 2
    @AppStorage("isAutopilotEnabled") private var isAutopilotEnabled: Bool = true // 🌟 Autopilot Toggle
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Core App Colors (Matching the Home Screen)
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    let backgroundColor = Color(red: 0.97, green: 0.97, blue: 0.96)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                (isDarkMode ? Color.black : backgroundColor)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // MARK: - Madhab Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PRAYER TIMES")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            Text("Madhab")
                                .font(.system(.title2, design: .serif)).bold()
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            Text("Please select your school of thought (Madhab). This will affect which Asr time is displayed.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 12) {
                                // Shafi Option
                                SelectionCard(
                                    title: "Earlier Asr Time - Shafi'i, Maliki & Hanbali",
                                    subtitle: "Mithl 1",
                                    isSelected: asrSchool == 0,
                                    activeColor: sageGreen
                                ) {
                                    asrSchool = 0
                                }
                                
                                // Hanafi Option
                                SelectionCard(
                                    title: "Later Asr Time - Hanafi",
                                    subtitle: "Mithl 2",
                                    isSelected: asrSchool == 1,
                                    activeColor: sageGreen
                                ) {
                                    asrSchool = 1
                                }
                            }
                        }
                        
                        Divider().background(Color.gray.opacity(0.2))
                        
                        // MARK: - Calculation Method Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Prayer Calculation Method")
                                .font(.system(.title3, design: .serif)).bold()
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            // 🌟 AUTOPILOT TOGGLE CARD
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle(isOn: $isAutopilotEnabled) {
                                    Text("Autopilot")
                                        .font(.system(.headline, design: .serif))
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                                .tint(sageGreen)
                                
                                Text("Ensures auto-detect & automatic locations are enabled allowing accurate prayer times using valid methodology for the country you are in.")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.trailing, 20)
                            }
                            .padding(18)
                            .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 10, x: 0, y: 4)
                            
                            // 🌟 MANUAL METHOD SELECTION (Disabled if Autopilot is ON)
                            VStack(spacing: 0) {
                                MethodRow(title: "Islamic Society of North America", isSelected: calcMethod == 2, activeColor: sageGreen) { calcMethod = 2 }
                                Divider().padding(.leading, 16).opacity(0.5)
                                MethodRow(title: "Muslim World League", isSelected: calcMethod == 3, activeColor: sageGreen) { calcMethod = 3 }
                                Divider().padding(.leading, 16).opacity(0.5)
                                MethodRow(title: "Umm Al-Qura University, Makkah", isSelected: calcMethod == 4, activeColor: sageGreen) { calcMethod = 4 }
                                Divider().padding(.leading, 16).opacity(0.5)
                                MethodRow(title: "Moonsighting Committee Worldwide", isSelected: calcMethod == 15, activeColor: sageGreen) { calcMethod = 15 }
                            }
                            .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 10, x: 0, y: 4)
                            // Greys out the list when Autopilot takes control
                            .opacity(isAutopilotEnabled ? 0.4 : 1.0)
                            .disabled(isAutopilotEnabled)
                            
                            if isAutopilotEnabled {
                                Text("Prayer times are currently being managed automatically based on your location.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(sageGreen)
                                    .padding(.top, 4)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(sageGreen)
                    }
                }
            }
        }
    }
}

// MARK: - Reusable UI Components

// The custom card for selecting the Madhab (matches your app's home screen style)
struct SelectionCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let activeColor: Color
    let action: () -> Void
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(isSelected ? .white : (isDarkMode ? .white : .black))
                
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(isSelected ? activeColor : (isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .white))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// The clean list row for selecting Calculation Methods
struct MethodRow: View {
    let title: String
    let isSelected: Bool
    let activeColor: Color
    let action: () -> Void
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(activeColor)
                        .font(.system(size: 22))
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
