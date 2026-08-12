//
//  PrayerGuideListView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 23/07/2026.
//

import SwiftUI

// MARK: - THE PRAYER GUIDE HUB
struct PrayerGuideListView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var bgColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95)
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 42))
                            .foregroundColor(accentGold)
                        Text("The Complete Prayer Guide")
                            .font(.system(.title2, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        Text("The second pillar of Islam")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                    // Menu Cards
                    VStack(spacing: 16) {
                        NavigationLink(destination: IntroToSalahView()) {
                            menuCard(title: "Introduction to Salah", icon: "info.circle.fill", color: sageGreen)
                        }
                        
                        NavigationLink(destination: TimesAndRakahsView()) {
                            menuCard(title: "Prayer Times & Rak'ahs", icon: "clock.fill", color: accentGold)
                        }
                        
                        NavigationLink(destination: WuduGuideView()) {
                            menuCard(title: "Purification (Wudu')", icon: "drop.fill", color: sageGreen)
                        
                        }
                        
                        NavigationLink(destination: SalahStepsView()) {
                            menuCard(title: "How to Perform Salah", icon: "figure.mind.and.body", color: accentGold)
                        }
                        
                       // NavigationLink(destination: Text("Surahs Coming Soon")) {
                         //   menuCard(title: "Short Qur'anic Chapters", icon: "book.fill", color: sageGreen)
                        //}
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Prayer Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func menuCard(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(.headline, design: .serif)).bold()
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .contentShape(Rectangle())
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

/// MARK: - SUB-PAGE 1: INTRO TO SALAH
struct IntroToSalahView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var bgColor: Color { isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95) }
    var cardColor: Color { isDarkMode ? Color.white.opacity(0.06) : Color.white }
    var textColor: Color { isDarkMode ? .white.opacity(0.9) : Color(red: 0.18, green: 0.23, blue: 0.20) }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Card 1: Meaning
                    standardCard(
                        title: "The Meaning of Salah",
                        content: "The word 'Salah' stems from the Arabic root 'silah', which translates to connection or link. In Islam, Salah is far more than a mere physical ritual; it is a profound, direct communion between the believer and their Creator, Allah (SWT).\n\nPerformed five times daily, it serves as a spiritual anchor, purifying the heart, instilling tranquility, and constantly realigning the believer’s focus toward the Divine.",
                        color: sageGreen
                    )
                    
                    // Card 2: 2nd Pillar
                    standardCard(
                        title: "The Second Pillar",
                        content: "Salah stands as the second and most vital pillar of Islam, established immediately after the declaration of faith (Shahadah). Prophet Muhammad (peace and blessings be upon him) emphasized that prayer is the foundational pillar of the religion.\n\nIt is of such paramount importance that it remains a divine obligation in all circumstances—whether one is traveling, ill, or in times of fear. Furthermore, it is the very first action a believer will be held accountable for on the Day of Judgment.",
                        color: accentGold
                    )
                    
                    // Card 3: Fruits of Prayer
                    standardCard(
                        title: "The Fruits of Prayer",
                        content: "Beyond fulfilling a divine command, Salah brings immense spiritual blessings. It shields the believer from sinful acts, cultivates deep humility, and serves as a continuous source of forgiveness and spiritual renewal.\n\nAs Allah (SWT) mentions in the Holy Qur'an: \"Indeed, prayer prohibits immorality and wrongdoing.\" (Surah Al-Ankabut, 29:45).",
                        color: sageGreen
                    )
                    
                    // Card 4: Age of Accountability (Custom layout for bullets)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("The Age of Accountability")
                            .font(.system(.title3, design: .serif)).bold()
                            .foregroundColor(accentGold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("The observance of Salah is a noble responsibility upon every sane, adult Muslim. In Islamic jurisprudence, religious accountability (Balugh) is attained upon reaching puberty. The recognized signs of reaching this stage include any of the following:")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(textColor)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint("1. The occurrence of wet dreams (Ihtilam)")
                            bulletPoint("2. The physical growth of pubic hair")
                            bulletPoint("3. The onset of menstruation (for young women)")
                            bulletPoint("4. Reaching the age of 15 lunar years (if the above signs have not yet appeared)")
                        }
                        .padding(.top, 4)
                        .padding(.leading, 8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentGold.opacity(0.3), lineWidth: 1))
                    
                }
                .padding(24)
            }
        }
        .navigationTitle("Introduction")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Self-contained helper for text-only cards
    private func standardCard(title: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(.title3, design: .serif)).bold()
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(content)
                .font(.system(.body, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    // Self-contained helper for bullet points
    private func bulletPoint(_ text: String) -> some View {
        Text(text)
            .font(.system(.body, design: .serif))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - SUB-PAGE 2: TIMES & RAK'AHS
struct TimesAndRakahsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var bgColor: Color { isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95) }
    var cardColor: Color { isDarkMode ? Color.white.opacity(0.06) : Color.white }
    var textColor: Color { isDarkMode ? .white.opacity(0.9) : Color(red: 0.18, green: 0.23, blue: 0.20) }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // SECTION 1: Fard Emphasis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("The Absolute Obligation of Fard")
                            .font(.system(.title3, design: .serif)).bold()
                            .foregroundColor(sageGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("The **Fard** (Obligatory) units of prayer are a direct divine command from Allah (SWT). They are the absolute core of the prayer and **cannot be missed, skipped, or compromised under any circumstances**.\n\nWhile Sunnah and Nafl prayers bring immense spiritual reward, serve as a beautiful shield, and make up for shortcomings in the obligatory prayers, the Fard remains your primary, uncompromising duty.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(textColor)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .background(cardColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(sageGreen.opacity(0.5), lineWidth: 1.5))
                    
                    // SECTION 2: The 5 Daily Prayers
                    Text("The 5 Daily Prayers")
                        .font(.system(.title2, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .padding(.bottom, -4)
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        prayerTimeCard(name: "Fajr", desc: "The Dawn Prayer is performed after dawn and before sunrise.") {
                            unitBadge(title: "Sunnah", count: "2", isFard: false)
                            unitBadge(title: "Fard", count: "2", isFard: true)
                        }
                        
                        prayerTimeCard(name: "Dhuhr", desc: "The Noon Prayer is performed when the sun begins to decline from the zenith point.") {
                            unitBadge(title: "Sunnah", count: "4", isFard: false)
                            unitBadge(title: "Fard", count: "4", isFard: true)
                            unitBadge(title: "Sunnah", count: "2", isFard: false)
                            unitBadge(title: "Nafl", count: "2", isFard: false)
                        }
                        
                        prayerTimeCard(name: "Asr", desc: "The Afternoon Prayer is performed midway between noon and sunset.") {
                            unitBadge(title: "Sunnah", count: "4", isFard: false)
                            unitBadge(title: "Fard", count: "4", isFard: true)
                        }
                        
                        prayerTimeCard(name: "Maghrib", desc: "The Sunset Prayer is performed immediately after sunset.") {
                            unitBadge(title: "Fard", count: "3", isFard: true)
                            unitBadge(title: "Sunnah", count: "2", isFard: false)
                            unitBadge(title: "Nafl", count: "2", isFard: false)
                        }
                        
                        prayerTimeCard(name: "Isha'", desc: "The Night Prayer is performed after twilight up until Fajr.") {
                            unitBadge(title: "Sunnah", count: "4", isFard: false)
                            unitBadge(title: "Fard", count: "4", isFard: true)
                            unitBadge(title: "Sunnah", count: "2", isFard: false)
                            unitBadge(title: "Witr", count: "3", isWitr: true)
                        }
                    }
                    
                    // SECTION 3: Detailed Table
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detailed Unit Breakdown")
                            .font(.system(.title3, design: .serif)).bold()
                            .foregroundColor(accentGold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("The table below shows the chronological order of units. The **Witr** prayer (performed after Isha) is highly emphasized (Wajib) and should not be missed.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(textColor)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Symmetrical, Clean Table Layout
                        VStack(spacing: 14) {
                            tableRow(prayer: "Prayer", before: "Before", fard: "Fard", after: "After", extra: "Extra", isHeader: true)
                            Divider()
                            tableRow(prayer: "Fajr", before: "2", fard: "2*", after: "-", extra: "-")
                            tableRow(prayer: "Dhuhr", before: "4", fard: "4", after: "2", extra: "2 Nafl")
                            tableRow(prayer: "Asr", before: "4", fard: "4", after: "-", extra: "-")
                            tableRow(prayer: "Maghrib", before: "-", fard: "3*", after: "2", extra: "2 Nafl")
                            tableRow(prayer: "Isha'", before: "4", fard: "4*", after: "2", extra: "3 Witr")
                        }
                        .padding(.top, 8)
                        
                        Text("* The Qur'anic recitation in the first two Fard units of the prayers with an asterisk should be read aloud.")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentGold.opacity(0.3), lineWidth: 1))
                    
                    // SECTION 4: Missed Prayers
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Praying on Time & Missed")
                            .font(.system(.title3, design: .serif)).bold()
                            .foregroundColor(sageGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("It is beloved to Allah that each of the five obligatory prayers is performed as soon as its time commences. If a prayer is forgotten or slept through, it must be made up (Qada) as soon as it is remembered, performed exactly as it would be in its specified time.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(textColor)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(sageGreen.opacity(0.3), lineWidth: 1))
                    
                }
                .padding(24)
            }
        }
        .navigationTitle("Times & Rak'ahs")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Views
    
    // Upgraded Prayer Time Card leveraging @ViewBuilder for dynamic badges
    private func prayerTimeCard<Content: View>(name: String, desc: String, @ViewBuilder units: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(name)
                .font(.system(.title3, design: .serif)).bold()
                .foregroundColor(sageGreen)
            
            Text(desc)
                .font(.system(.body, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
            
            // Unit Breakdown Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    units()
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(sageGreen.opacity(0.3), lineWidth: 1))
    }
    
    // Little Pill Badges for the Units
    private func unitBadge(title: String, count: String, isFard: Bool = false, isWitr: Bool = false) -> some View {
        let badgeColor = isFard ? sageGreen : (isWitr ? accentGold : Color.clear)
        let border = isFard ? sageGreen : (isWitr ? accentGold : .gray.opacity(0.3))
        let textCol = (isFard || isWitr) ? Color.white : textColor
        let subTextCol = (isFard || isWitr) ? Color.white.opacity(0.9) : Color.gray
        
        return VStack(spacing: 4) {
            Text(count)
                .font(.system(.headline, design: .rounded)).bold()
                .foregroundColor(textCol)
            Text(title)
                .font(.system(.caption2, design: .serif)).bold()
                .foregroundColor(subTextCol)
        }
        .frame(minWidth: 55)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(badgeColor)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
    }
    
    // Upgraded Table Row with highlighted Fard Column
    private func tableRow(prayer: String, before: String, fard: String, after: String, extra: String, isHeader: Bool = false) -> some View {
        HStack {
            Text(prayer)
                .frame(width: 70, alignment: .leading)
            Spacer()
            Text(before)
                .frame(width: 45, alignment: .center)
            Spacer()
            Text(fard)
                .frame(width: 45, height: 26, alignment: .center)
                .background(isHeader ? Color.clear : sageGreen)
                .foregroundColor(isHeader ? .gray : .white)
                .cornerRadius(6)
                .bold(!isHeader)
            Spacer()
            Text(after)
                .frame(width: 45, alignment: .center)
            Spacer()
            Text(extra)
                .frame(width: 55, alignment: .trailing)
        }
        .font(.system(isHeader ? .caption : .subheadline, design: .serif))
        .foregroundColor(isHeader ? .gray : textColor)
        .bold(isHeader)
    }
}
