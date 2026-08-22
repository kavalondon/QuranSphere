//
//  KhatmahReaderView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 21/08/2026.
//

import SwiftUI

struct KhatmahReaderView: View {
    @EnvironmentObject var quranManager: LocalQuranManager
    @EnvironmentObject var khatmahManager: KhatmahManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Dedicated Khatmah Storage
    // These are COMPLETELY isolated from the casual reading variables
    @AppStorage("khatmahLastReadSurah") private var khatmahSurah = 1
    @AppStorage("khatmahLastReadSurahName") private var khatmahSurahName = "Al-Fatihah"
    @AppStorage("khatmahLastReadVerse") private var khatmahVerse = 1
    
    // Shared Aesthetics
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("arabicFont") private var arabicFont: String = "Amiri"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28.0
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    // Array of verses strictly for the current Surah being read
    @State private var currentSurahVerses: [JSONVerse] = []
    
    private let versesPerSurah = [7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6]
    
    // MARK: - Live Khatmah Progress Math
    private var trueReadingProgress: Double {
        let totalVersesInQuran = 6236.0
        let safeSurah = max(1, min(khatmahSurah, 114))
        
        var completedVerses = 0
        for i in 0..<(safeSurah - 1) {
            completedVerses += versesPerSurah[i]
        }
        completedVerses += max(0, khatmahVerse - 1)
        
        let percentage = Double(completedVerses) / totalVersesInQuran
        return min(max(percentage, 0.0), 1.0)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Color
            (isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95))
                .ignoresSafeArea()
            
            // Verses List
            ScrollViewReader { proxy in
                ScrollView {
                    // Padding at top so verses don't hide under the sticky header
                    Spacer().frame(height: 90)
                    
                    LazyVStack(spacing: 24) {
                        ForEach(currentSurahVerses, id: \.verseNumber) { verse in
                            verseCard(for: verse)
                                .id(verse.verseNumber)
                                .onAppear {
                                    // LIVE TRACKING: As the user scrolls, it updates the saved Khatmah verse instantly
                                    if verse.verseNumber >= khatmahVerse {
                                        khatmahVerse = verse.verseNumber
                                    }
                                }
                        }
                        
                        // Next Surah Button
                        if khatmahSurah < 114 {
                            Button(action: {
                                goToNextSurah()
                                proxy.scrollTo(1, anchor: .top) // Snap back to the top
                            }) {
                                HStack {
                                    Text("Continue to Next Surah")
                                        .font(.system(.headline, design: .serif))
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(sageGreen)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 40)
                        } else {
                            // Reached the end of the Quran!
                            Text("Khatmah Complete. Alhamdulillah.")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(accentGold)
                                .padding(.vertical, 40)
                        }
                    }
                    .padding(.bottom, 60)
                }
                .onAppear {
                    loadVerses()
                    // Auto-scroll to where they left off when they open the page
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(khatmahVerse, anchor: .top)
                    }
                }
            }
            
            // MARK: - Sticky Gamification Header
            stickyHeader
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(sageGreen)
                    Text("Home")
                        .foregroundColor(sageGreen)
                }
            }
        }
    }
    
    // MARK: - Sticky Header UI
    private var stickyHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Khatmah Mission")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(accentGold)
                        .textCase(.uppercase)
                    
                    Text("\(khatmahSurahName) • Verse \(khatmahVerse)")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                
                Spacer()
                
                Text(String(format: "%.2f%%", trueReadingProgress * 100))
                    .font(.system(.headline, design: .rounded).bold())
                    .foregroundColor(sageGreen)
            }
            
            // Live Global Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    
                    Capsule()
                        .fill(LinearGradient(colors: [sageGreen, accentGold], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(trueReadingProgress))
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(
            (isDarkMode ? Color(red: 0.12, green: 0.14, blue: 0.13) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Verse Card UI
    @ViewBuilder
    private func verseCard(for verse: JSONVerse) -> some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                // Verse Number Badge
                ZStack {
                    Circle()
                        .stroke(sageGreen.opacity(0.5), lineWidth: 1)
                        .frame(width: 32, height: 32)
                    Text("\(verse.verseNumber)")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .foregroundColor(sageGreen)
                }
                Spacer()
            }
            
            Text(verse.text)
                .font(.custom(arabicFont, size: arabicFontSize))
                .multilineTextAlignment(.trailing)
                .lineSpacing(12)
                .foregroundColor(isDarkMode ? .white : .black)
            
            Text(cleanTranslation(verse.translation))
                .font(.system(.body, design: .serif))
                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
        }
        .padding(20)
        .background(isDarkMode ? Color.white.opacity(0.04) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helper Logic
    private func loadVerses() {
        // Fetches only the verses for the currently tracked Khatmah Surah
        currentSurahVerses = quranManager.verses.filter { $0.surahNumber == khatmahSurah }
    }
    
    private func goToNextSurah() {
        if khatmahSurah < 114 {
            khatmahSurah += 1
            khatmahVerse = 1 // Reset to verse 1 for the new Surah
            
            // Try to find the name of the new Surah
            if let firstVerseOfNewSurah = quranManager.verses.first(where: { $0.surahNumber == khatmahSurah }) {
                // Assuming you have a way to get the Surah name. If not mapped, keep the old or add a mapper.
                // For now, updating the state to trigger reload
                khatmahSurahName = "Surah \(khatmahSurah)"
            }
            
            loadVerses()
        }
    }
    
    private func cleanTranslation(_ text: String) -> String {
        let pattern = "\\[\\d+\\]|[\\*\\#\\~]"
        return text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
