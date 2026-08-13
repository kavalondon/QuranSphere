import WidgetKit
import SwiftUI

// 1. Standalone Data Model
struct PrayerTimings {
    var Fajr: String
    var Sunrise: String
    var Dhuhr: String
    var Asr: String
    var Maghrib: String
    var Isha: String
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let timings: PrayerTimings
    let nextPrayerName: String
}

// 2. Standalone Timeline Provider
struct PrayerTimelineProvider: TimelineProvider {
    let dummyTimings = PrayerTimings(Fajr: "03:59", Sunrise: "06:00", Dhuhr: "13:19", Asr: "18:19", Maghrib: "20:45", Isha: "21:49")
    
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), timings: dummyTimings, nextPrayerName: "Dhuhr")
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let entry = PrayerEntry(date: Date(), timings: dummyTimings, nextPrayerName: "Dhuhr")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = PrayerEntry(date: Date(), timings: dummyTimings, nextPrayerName: "Dhuhr")
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// 3. The Widget View (Pillars Layout with QuranSphere Colors)
struct QuransphereWidgetEntryView : View {
    var entry: PrayerTimelineProvider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    // Helper to dynamically show the correct time next to the large title
    func timeForNextPrayer() -> String {
        switch entry.nextPrayerName {
        case "Fajr": return entry.timings.Fajr
        case "Dhuhr": return entry.timings.Dhuhr
        case "Asr": return entry.timings.Asr
        case "Maghrib": return entry.timings.Maghrib
        case "Isha": return entry.timings.Isha
        default: return "--:--"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- TOP HALF: Next Prayer ---
            HStack(alignment: .center) {
                Text(entry.nextPrayerName)
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.1, blue: 0.1))
                
                Spacer()
                
                Image(systemName: "moon.stars.fill") // Dynamic icon
                    .font(.system(size: 20))
                    .foregroundColor(Color.pillarsAccentGold)
                
                Spacer()
                
                Text(timeForNextPrayer())
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.1, blue: 0.1))
            }
            .padding(.top, 16)
            .padding(.horizontal, 8)
            
            Spacer()
            
            // --- BOTTOM HALF: 5 Prayer Timeline ---
            HStack {
                MiniPrayerColumn(name: "Fajr", time: entry.timings.Fajr, isActive: entry.nextPrayerName == "Fajr")
                Spacer()
                MiniPrayerColumn(name: "Dhuhr", time: entry.timings.Dhuhr, isActive: entry.nextPrayerName == "Dhuhr")
                Spacer()
                MiniPrayerColumn(name: "Asr", time: entry.timings.Asr, isActive: entry.nextPrayerName == "Asr")
                Spacer()
                MiniPrayerColumn(name: "Maghrib", time: entry.timings.Maghrib, isActive: entry.nextPrayerName == "Maghrib")
                Spacer()
                MiniPrayerColumn(name: "Isha", time: entry.timings.Isha, isActive: entry.nextPrayerName == "Isha")
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 4)
        }
        // iOS 17 Background setup
        .containerBackground(for: .widget) {
            ZStack {
                // Main Background (QuranSphere Theme)
                (colorScheme == .dark ? Color.pillarsBackgroundDark : Color.pillarsWarmSand)
                
                // Recreating the subtle two-tone split from Pillars for the bottom row
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.pillarsSage.opacity(0.08))
                        .frame(height: 60)
                }
            }
        }
        // 🌟 ADDED: Tells the widget what URL to open when tapped
        .widgetURL(URL(string: "quransphere://qibla"))
    }
}

// 4. Custom Column for the 5-Prayer Timeline
struct MiniPrayerColumn: View {
    let name: String
    let time: String
    let isActive: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.system(size: 12, weight: .medium, design: .serif))
                // 🌟 FIX: Explicitly writing Color.white and Color.black
                .foregroundColor(isActive ? Color.pillarsAccentGold : (colorScheme == .dark ? Color.white : Color.black).opacity(0.9))
            
            // The subtle dot bridging the name and time
            Circle()
                .fill(isActive ? Color.pillarsAccentGold : Color.gray.opacity(0.3))
                .frame(width: 4, height: 4)
            
            Text(time)
                .font(.system(size: 12, design: .rounded))
                // 🌟 FIX: Explicitly writing Color.white and Color.black
                .foregroundColor(isActive ? Color.pillarsAccentGold : (colorScheme == .dark ? Color.white : Color.black).opacity(0.7))
        }
    }
}

// 5. Configuration
struct QuransphereWidget: Widget {
    let kind: String = "QuransphereWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            QuransphereWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Times")
        .description("Keep track of your daily prayers.")
        .supportedFamilies([.systemMedium])
    }
}
