import Foundation

class GamificationManager {
    static let shared = GamificationManager()
    
    private let defaults = UserDefaults.standard
    
    // These keys match your ContentView @AppStorage perfectly
    private let streakKey = "currentStreak"
    private let versesTodayKey = "versesReadToday"
    private let hasanatKey = "totalHasanat"
    private let lastDateKey = "lastReadDate"
    
    func logVerseRead(arabicText: String) {
        checkAndResetDailyStats()
        
        // 1. Increment verses read today
        let currentVerses = defaults.integer(forKey: versesTodayKey)
        defaults.set(currentVerses + 1, forKey: versesTodayKey)
        
        // 2. Calculate Hasanat
        let letterCount = arabicText.replacingOccurrences(of: " ", with: "").count
        
        // 🌟 The Ramadan Multiplier: 9 is the 9th month (Ramadan)
        let hasanatPerLetter = isRamadan() ? 700 : 10
        let earnedHasanat = letterCount * hasanatPerLetter
        
        let currentHasanat = defaults.integer(forKey: hasanatKey)
        defaults.set(currentHasanat + earnedHasanat, forKey: hasanatKey)
    }
    
    // 🌟 Native Islamic Calendar Check
    private func isRamadan() -> Bool {
        let islamicCalendar = Calendar(identifier: .islamicUmmAlQura)
        let currentMonth = islamicCalendar.component(.month, from: Date())
        return currentMonth == 9
    }
    
    private func checkAndResetDailyStats() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        let lastDateString = defaults.string(forKey: lastDateKey) ?? ""
        
        if lastDateString != todayString {
            // It is a new day! Let's check the streak.
            if let lastDate = formatter.date(from: lastDateString) {
                let calendar = Calendar.current
                if calendar.isDateInYesterday(lastDate) {
                    // Read yesterday, keep the streak going!
                    let currentStreak = defaults.integer(forKey: streakKey)
                    defaults.set(currentStreak + 1, forKey: streakKey)
                } else {
                    // Missed a day, streak resets to 1
                    defaults.set(1, forKey: streakKey)
                }
            } else {
                // First time ever reading
                defaults.set(1, forKey: streakKey)
            }
            
            // Reset daily stats to 0 for the new day
            defaults.set(0, forKey: versesTodayKey)
            defaults.set(0, forKey: hasanatKey)
            
            // Save today as the last read date
            defaults.set(todayString, forKey: lastDateKey)
        }
    }
}
