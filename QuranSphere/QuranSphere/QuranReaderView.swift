import SwiftUI

struct QuranReaderView: View {
    let surahNumber: Int
    let surahName: String
    
    @StateObject private var quranManager = LocalQuranManager()
    
    // Core Bookmarks synced across app modules
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    
    private var surahVerses: [JSONVerse] {
        quranManager.verses.filter { $0.surahNumber == surahNumber }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    
                    // Surah Header Header
                    VStack(spacing: 8) {
                        Text(surahName)
                            .font(.system(.title, design: .serif))
                            .bold()
                        Text("Surah \(surahNumber)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    
                    ForEach(surahVerses) { verse in
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Verse \(verse.verseNumber)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            Text(verse.text)
                                .font(.system(.title2, design: .serif))
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(verse.translation)
                                .font(.system(.body, design: .serif))
                                .foregroundColor(.gray)
                            
                            Divider()
                        }
                        .id(verse.verseNumber) // Assign ID for auto-scrolling targets
                        .onAppear {
                            // Update active bookmark dynamically as user reads down the page
                            lastReadSurah = surahNumber
                            lastReadSurahName = surahName
                            lastReadVerse = verse.verseNumber
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                // If opening the current bookmark Surah, instantly scroll them right down to their last read verse location!
                if lastReadSurah == surahNumber {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(lastReadVerse, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
