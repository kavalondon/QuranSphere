//
//  BookmarksView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 20/07/2026.
//

import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // Grabs the comma-separated string of IDs saved by the Reader
    @AppStorage("bookmarkedVerseIDs") private var bookmarkedVerseIDsStr: String = ""
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    // Converts the string "1,25,80" back into an array of Integers [1, 25, 80]
    var bookmarkedIDs: [Int] {
        bookmarkedVerseIDsStr.split(separator: ",").compactMap { Int($0) }
    }
    
    var body: some View {
        ZStack {
            Group {
                if isDarkMode {
                    Color(red: 0.10, green: 0.12, blue: 0.11)
                } else {
                    Color(red: 0.97, green: 0.97, blue: 0.95)
                }
            }
            .ignoresSafeArea()
            
            if bookmarkedIDs.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Bookmarks Yet")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text("Verses you bookmark while reading will appear here.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Filters the entire Quran for only the IDs the user bookmarked
                        let verses = quranManager.verses.filter { bookmarkedIDs.contains($0.id) }
                        
                        ForEach(verses, id: \.id) { verse in
                            // Find the Surah name for this verse
                            let surahName = SurahMetadataModel.allSurahs.first(where: { $0.id == verse.surahNumber })?.nameEN ?? "Surah \(verse.surahNumber)"
                            
                            // Routes directly to the exact Surah
                            NavigationLink(destination: QuranReaderView(surahNumber: verse.surahNumber, surahName: surahName)) {
                                bookmarkCard(for: verse, surahName: surahName)
                            }
                            .buttonStyle(PlainButtonStyle()) // Prevents default list highlighting
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // Minimalist Card UI
    private func bookmarkCard(for verse: JSONVerse, surahName: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("\(surahName) • Verse \(verse.verseNumber)")
                    .font(.system(.caption, design: .monospaced)).bold()
                    .foregroundColor(sageGreen)
                Spacer()
                Image(systemName: "bookmark.fill")
                    .foregroundColor(sageGreen)
                    .font(.system(size: 14))
            }
            
            Text(verse.text)
                .font(.system(.title3, design: .serif))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(3) // Keeps the card clean by not showing massive verses entirely
            
            Text(cleanTranslation(verse.translation))
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                .lineLimit(2)
        }
        .padding(20)
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 24)
    }
    
    // Helper to strip footnotes like [1] or * out of the translation preview
    private func cleanTranslation(_ text: String) -> String {
        let pattern = "\\[\\d+\\]|[\\*\\#\\~]"
        return text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
