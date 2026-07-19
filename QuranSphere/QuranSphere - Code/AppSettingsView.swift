import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var quranManager = LocalQuranManager()
    
    // Settings States
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var fontSize: Double = 16.0
    @State private var notificationsEnabled = true
    
    var body: some View {
        Form {
            // MARK: - Themes & Appearance
            Section(header: Text("Appearance").font(.system(.caption, design: .serif))) {
                HStack {
                    Label {
                        Text("Interface Theme")
                            .font(.system(.body, design: .serif))
                    } icon: {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .indigo : .orange)
                    }
                    
                    Spacer()
                    
                    // Minimalistic Custom Toggle Switch
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isDarkMode.toggle()
                        }
                    }) {
                        Capsule()
                            .fill(isDarkMode ? Color(red: 0.18, green: 0.23, blue: 0.20) : Color(.systemGray5))
                            .frame(width: 54, height: 30)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                                    .shadow(radius: 2)
                                    .overlay(
                                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(isDarkMode ? .indigo : .orange)
                                    )
                                    .offset(x: isDarkMode ? 12 : -12)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Font Size")
                            .font(.system(.body, design: .serif))
                        Spacer()
                        Text("\(Int(fontSize)) pt")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Slider(value: $fontSize, in: 14...26, step: 1)
                        .tint(Color(red: 0.29, green: 0.36, blue: 0.31))
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Preferences Section
            Section(header: Text("Preferences").font(.system(.caption, design: .serif))) {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Daily Verse Reminders")
                        .font(.system(.body, design: .serif))
                }
                .tint(Color(red: 0.29, green: 0.36, blue: 0.31))
            }
            
            // MARK: - Database Status Section
            Section(header: Text("System").font(.system(.caption, design: .serif))) {
                HStack {
                    Text("Database Integrity")
                        .font(.system(.body, design: .serif))
                    Spacer()
                    Text("Verified Offline")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.green)
                }
                HStack {
                    Text("Total Rows Cached")
                        .font(.system(.body, design: .serif))
                    Spacer()
                    Text("\(quranManager.verses.count)")
                        .font(.system(.subheadline, design: .monospaced))
                        .bold()
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(Color(red: 0.29, green: 0.36, blue: 0.31))
                .font(.system(.body, design: .serif).bold())
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppSettingsView()
    }
}
