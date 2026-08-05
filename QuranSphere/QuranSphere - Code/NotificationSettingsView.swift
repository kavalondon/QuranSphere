import SwiftUI
import UserNotifications // 🌟 ADDED: For real Apple notification requests

struct NotificationSettingsView: View {
    @AppStorage("prayerNotificationsEnabled") private var prayerNotificationsEnabled = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var showSettingsAlert = false // To direct users to iOS settings if denied
    
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
                        
                        Text("Notifications")
                            .font(.system(.title2, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text("Please select which types of notifications you would like to receive.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(isOn: $prayerNotificationsEnabled) {
                                Text("Prayer Times")
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                            .tint(sageGreen)
                            // 🌟 Request permissions when toggled
                            .onChange(of: prayerNotificationsEnabled) { newValue in
                                if newValue {
                                    requestNotificationPermission()
                                }
                            }
                        }
                        .padding(18)
                        .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 10, x: 0, y: 4)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        // 🌟 Alert if user previously denied permissions
        .alert("Notifications Disabled", isPresented: $showSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications for QuranSphere in your iPhone Settings to receive prayer alerts.")
        }
    }
    
    // 🌟 Check and Request iOS Permissions
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    // Turn toggle back off and show alert if permission is denied
                    prayerNotificationsEnabled = false
                    showSettingsAlert = true
                }
            }
        }
    }
}
