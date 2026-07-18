import SwiftUI

struct SettingsView: View {
    // These @AppStorage variables automatically save the user's choices forever
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("preferredScript") private var preferredScript = "uthmani"
    @AppStorage("locationEnabled") private var locationEnabled = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - Header
                HStack {
                    Text("Settings")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.20, green: 0.25, blue: 0.22))
                        .bold()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // MARK: - Appearance Section
                settingsSection(title: "Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        settingRow(icon: isDarkMode ? "moon.stars.fill" : "sun.max.fill",
                                   title: "Dark Mode",
                                   color: isDarkMode ? .yellow : .orange)
                    }
                    // Matches your app's sage-green branding
                    .tint(Color(red: 0.38, green: 0.48, blue: 0.43))
                }
                
                // MARK: - Quran Preferences Section
                settingsSection(title: "Reading Preferences") {
                    HStack {
                        settingRow(icon: "text.book.closed.fill", title: "Arabic Script", color: .brown)
                        
                        Spacer()
                        
                        // Elegant minimalist dropdown picker
                        Picker("Script", selection: $preferredScript) {
                            Text("Uthmani").tag("uthmani")
                            Text("IndoPak").tag("indopak")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(.gray)
                    }
                }
                
                // MARK: - Privacy & Permissions Section
                settingsSection(title: "Permissions") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $locationEnabled) {
                            settingRow(icon: "location.fill", title: "Location Services", color: .blue)
                        }
                        .tint(Color(red: 0.38, green: 0.48, blue: 0.43))
                        
                        Text("Required for the Qibla compass to accurately calculate the direction of the Kaaba based on your current coordinate.")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                // MARK: - App Footer
                VStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43).opacity(0.5))
                        .font(.system(size: 20))
                    Text("QuranScape v1.0")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.gray)
                    Text("Made with peace")
                        .font(.system(.caption2, design: .serif))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding(.top, 24)
                
            }
            .padding(.bottom, 120) // Spacing to clear the floating bottom bar
        }
    }
    
    // MARK: - Minimalist UI Components
    
    // Helper to create beautiful floating card sections
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(.caption, design: .serif))
                .bold()
                .foregroundColor(.gray)
                .tracking(1)
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                content()
            }
            .padding(20)
            .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 24)
        }
    }
    
    // Helper to create clean, uniform icon rows
    private func settingRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(title)
                .font(.system(.body, design: .serif))
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
        }
    }
}
