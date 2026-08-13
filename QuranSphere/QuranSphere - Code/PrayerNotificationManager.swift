import Foundation
import UserNotifications
internal import Combine // 🌟 FIXED: Added 'internal' to match your other files

class PrayerNotificationManager: ObservableObject {
    static let shared = PrayerNotificationManager()
    
    @Published var isAuthorized = false
    
    init() {
        checkPermissionStatus()
    }
    
    // MARK: - 1. Request Permission
    func requestPermission() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    print("Notification permission granted.")
                } else if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - 2. Schedule a Notification
    func scheduleNotification(for prayerName: String, at date: Date) {
        // Don't schedule for times that have already passed
        guard date > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(prayerName) Prayer"
        content.body = "It is time to offer \(prayerName)."
        // If you add a custom Adhan audio file later, you change this to .soundNamed("adhan.caf")
        content.sound = .default
        
        // Extract the exact time to trigger the alert
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create a unique ID for this specific prayer
        let identifier = "prayer_\(prayerName)_\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule \(prayerName): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled \(prayerName) for \(date)")
            }
        }
    }
    
    // MARK: - 3. Clear Old Notifications
    func clearAllScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
