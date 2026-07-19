import SwiftUI

struct SettingsView: View {
    // 🌟 ADDED: arabicFontSize so the slider works here too
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("arabicFont") private var arabicFont = "KFGQPCUthmanTahaNaskh"
    @AppStorage("preferredScript") private var preferredScript = "uthmani"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 38.0
    @AppStorage("locationEnabled") private var locationEnabled = false
    
    // Core brand color
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    // Dynamic preview text based on the selected script
    var previewText: String {
        preferredScript == "indopak" ? "بِسۡمِ اللّٰهِ الرَّحۡمٰنِ الرَّحِيۡمِ" : "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                    .tint(sageGreen)
                }
                
                // MARK: - Live Preview Section
                settingsSection(title: "Live Preview") {
                    Text(previewText)
                        .font(.custom(arabicFont, size: arabicFontSize))
                        .multilineTextAlignment(.center)
                        .lineSpacing(18)
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        // Rigid height and clipping to prevent jumping
                        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                        .clipped()
                        // Forces instant redraw on any change
                        .id(arabicFont + preferredScript + String(arabicFontSize))
                }
                
                // MARK: - Quran Typography Section
                settingsSection(title: "Typography & Script") {
                    
                    // Script Selection
                    VStack(alignment: .leading, spacing: 12) {
                        settingRow(icon: "text.book.closed.fill", title: "Quran Script", color: .brown)
                        
                        Picker("Script", selection: $preferredScript) {
                            Text("Uthmani").tag("uthmani")
                            Text("IndoPak").tag("indopak")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                        .padding(.vertical, 4)
                    
                    // Font Selection
                    VStack(alignment: .leading, spacing: 12) {
                        settingRow(icon: "character.book.closed", title: "Arabic Font", color: sageGreen)
                        
                        Picker("Font", selection: $arabicFont) {
                            Text("Amiri").tag("AmiriQuran-Regular")
                            Text("Madinah").tag("KFGQPCUthmanTahaNaskh")
                            Text("Saleem").tag("_PDMS_Saleem_QuranFont")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                        .padding(.vertical, 4)
                        
                    // 🌟 ADDED: Font Size Slider exactly like the reader
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            settingRow(icon: "textformat.size", title: "Text Size", color: .indigo)
                            Spacer()
                            Text("\(Int(arabicFontSize))")
                                .font(.system(.subheadline, design: .rounded)).bold()
                                .foregroundColor(sageGreen)
                        }
                        
                        HStack(spacing: 16) {
                            Text("A").font(.system(size: 14))
                            Slider(value: $arabicFontSize, in: 24...64, step: 2)
                                .tint(sageGreen)
                            Text("A").font(.system(size: 24))
                        }
                        .foregroundColor(.gray)
                    }
                }
                
                // MARK: - Permissions Section
                settingsSection(title: "Permissions") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $locationEnabled) {
                            settingRow(icon: "location.fill", title: "Location Services", color: .blue)
                        }
                        .tint(sageGreen)
                        
                        Text("Required for the Qibla compass to calculate the direction of the Kaaba.")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.bottom, 120) // Extra padding for the custom tab bar
        }
    }
    
    // MARK: - UI Components
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
