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
                if granted {
                    // Automatically schedule the smart engagement reminders if they say yes!
                    self.scheduleQuranSphereStyleNotifications()
                }
                completion(granted)
            }
        }
    }
}

extension NotificationManager {
    
    // MARK: - QuranSphere Dynamic Notification Engine
    func scheduleQuranSphereStyleNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // 1. Clear ONLY the dynamic QuranSphere reminders, leaving the user's custom daily verse intact
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { $0.identifier.hasPrefix("quransphere_") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
        
        // 2. Curated Pools of Dynamic Content
        let morningMessages = [
            "And paradise 🥥🌴🍋🍓 will be brought near to the righteous not far (50:31).",
            "A new day is a new blessing. Start it by connecting with your Creator 📖",
            "\"So remember Me; I will remember you.\" (2:152) Take a moment to read today.",
            "Start your morning with light. A single verse can change your entire day ✨",
            "\"And whoever relies upon Allah - then He is sufficient for him.\" (65:3) 🕊️"
        ]
        
        let afternoonVerses = [
            "\"To Allah 'alone' belongs the kingdom of the heavens and the earth.\" (3:189)",
            "\"With hardship comes ease.\" (94:5) Take a deep breath and read a verse.",
            "\"And He found you lost and guided you.\" (93:7) 💫",
            "\"Allah does not burden a soul beyond that it can bear.\" (2:286) ❤️",
            "\"Call upon Me; I will respond to you.\" (40:60) 🤲"
        ]
        
        let eveningPrompts = [
            "Your reading streak is at risk! ⚠️ Don't let your heart grow weaker—read a verse now.",
            "Grow Stronger with Every Verse 💖💪 Keep your daily reading habit alive before bed.",
            "Don't end your day without the Quran. Even one ayah makes a difference! 🌙",
            "End your night with peace. Open QuranSphere and read a few verses to protect your streak 🛡️"
        ]
        
        // 3. Schedule unique notifications for the next 14 days
        for dayOffset in 1...14 {
            guard let triggerDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            
            // Morning Reminder (9:00 AM)
            scheduleDynamicNotification(
                id: "quransphere_morning_\(dayOffset)",
                title: "🔔 Morning Quran Reminder",
                body: morningMessages.randomElement() ?? morningMessages[0],
                targetDate: triggerDate,
                hour: 9, minute: 0
            )
            
            // Afternoon Verse Drop (3:15 PM)
            scheduleDynamicNotification(
                id: "quransphere_afternoon_\(dayOffset)",
                title: "Dose Of Quran ✨",
                body: afternoonVerses.randomElement() ?? afternoonVerses[0],
                targetDate: triggerDate,
                hour: 15, minute: 15
            )
            
            // Evening Urgency / Streak (9:00 PM)
            scheduleDynamicNotification(
                id: "quransphere_evening_\(dayOffset)",
                title: "Before you sleep... 🌙",
                body: eveningPrompts.randomElement() ?? eveningPrompts[0],
                targetDate: triggerDate,
                hour: 21, minute: 0
            )
        }
        
        // Schedule the static repeating Friday Al-Kahf reminder
        scheduleFridayKahfReminder()
    }
    
    // Helper function to schedule specific dynamic dates
    private func scheduleDynamicNotification(id: String, title: String, body: String, targetDate: Date, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Friday Al-Kahf Reminder
    private func scheduleFridayKahfReminder() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "🔔 QuranSphere Reminder 📖"
        content.body = "It's Friday - Time for Surah Al-Kahf! 🌿"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 6 // Friday
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "quransphere_friday_kahf", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    // MARK: - Existing Custom Verse Scheduler (User Configured)
    func scheduleDailyVerseNotification(hour: Int, minute: Int, surah: Int, verse: Int, verseText: String) {
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: ["DailyVerseNotification"])
        
        let content = UNMutableNotificationContent()
        content.title = "Verse of the Day 📖"
        content.body = verseText
        content.sound = .default
        content.userInfo = ["deepLink": "quransphere://surah?number=\(surah)&verse=\(verse)"]
        
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
