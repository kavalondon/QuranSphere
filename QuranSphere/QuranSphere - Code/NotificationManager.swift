//
//  NotificationManager.swift
//  QuranSphere
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request permission for push notifications
    func requestPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

extension NotificationManager {
    
    // Schedule a daily uplifting verse notification at a chosen hour and minute
    func scheduleDailyVerseNotification(hour: Int, minute: Int, surah: Int, verse: Int, verseText: String) {
        let center = UNUserNotificationCenter.current()
        
        // Remove any old daily verse notification to avoid duplicates
        center.removePendingNotificationRequests(withIdentifiers: ["DailyVerseNotification"])
        
        let content = UNMutableNotificationContent()
        content.title = "Verse of the Day 📖"
        content.body = verseText
        content.sound = .default
        
        // Attach a deep link URL so tapping it opens the exact Surah/Verse
        content.userInfo = ["deepLink": "quransphere://surah?number=\(surah)&verse=\(verse)"]
        
        // Set time trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "DailyVerseNotification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error.localizedDescription)")
            } else {
                print("Daily verse notification scheduled successfully for \(hour):\(minute).")
            }
        }
    }
}
