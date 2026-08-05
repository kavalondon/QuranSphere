import SwiftUI

struct ThemeSettingsView: View {
    // 0 = Device Settings, 1 = Light, 2 = Dark
    @AppStorage("themePreference") private var themePreference: Int = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let backgroundColor = Color(red: 0.97, green: 0.97, blue: 0.96)
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : backgroundColor).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SETTINGS")
                            .font(.system(.caption, design: .rounded)).bold()
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        Text("Themes")
                            .font(.system(.title2, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text("Select from the following theme settings.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 12) {
                            ThemeSelectionCard(
                                title: "Device Settings",
                                subtitle: "Automatically match your iPhone's system appearance.",
                                isSelected: themePreference == 0,
                                activeColor: sageGreen
                            ) { themePreference = 0 }
                            
                            ThemeSelectionCard(
                                title: "Day Mode",
                                subtitle: "Stay fixed in day mode across the app.",
                                isSelected: themePreference == 1,
                                activeColor: sageGreen
                            ) {
                                themePreference = 1
                                isDarkMode = false
                            }
                            
                            ThemeSelectionCard(
                                title: "Night Mode",
                                subtitle: "Stay fixed in night mode across the app.",
                                isSelected: themePreference == 2,
                                activeColor: sageGreen
                            ) {
                                themePreference = 2
                                isDarkMode = true
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Themes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemeSelectionCard: View {
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
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
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
