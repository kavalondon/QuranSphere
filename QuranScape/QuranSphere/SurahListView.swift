import SwiftUI

struct SurahListView: View {
    @StateObject private var quranManager = LocalQuranManager()
    
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    
    // We group them nicely by categorizing popular quick-access chapters
    private var popularSurahs: [SurahMetadata] {
        quranManager.surahs.filter { [2, 36, 55, 56, 67].contains($0.id) }
    }
    
    private var otherSurahs: [SurahMetadata] {
        quranManager.surahs.filter { ![2, 36, 55, 56, 67].contains($0.id) }
    }
    
    var body: some View {
        List {
            if !popularSurahs.isEmpty {
                Section(header: Text("Featured Surahs").font(.system(.caption, design: .serif)).bold()) {
                    ForEach(popularSurahs) { surah in
                        navigationLinkRow(for: surah)
                    }
                }
            }
            
            Section(header: Text("All Surahs").font(.system(.caption, design: .serif)).bold()) {
                ForEach(otherSurahs) { surah in
                    navigationLinkRow(for: surah)
                }
            }
        }
        .navigationTitle("Holy Quran")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Beautifully styled navigation card row matching your exact minimalist aesthetic
    private func navigationLinkRow(for surah: SurahMetadata) -> some View {
        NavigationLink(destination: QuranReaderView(surahNumber: surah.id, surahName: surah.nameEN)) {
            HStack(spacing: 16) {
                Text("\(surah.id)")
                    .font(.system(.caption, design: .monospaced))
                    .bold()
                    .frame(width: 32, height: 32)
                    .background(Color(red: 0.93, green: 0.95, blue: 0.93))
                    .foregroundColor(Color(red: 0.29, green: 0.36, blue: 0.31))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(surah.nameEN)
                        .font(.system(.body, design: .serif)).bold()
                        .foregroundColor(Color(red: 0.18, green: 0.23, blue: 0.20))
                    Text("\(surah.totalVerses) Verses • \(surah.type)")
                        .font(.system(.caption2, design: .serif)).foregroundColor(.gray)
                }
                Spacer()
                Text(surah.nameAR)
                    .font(.system(.title3, design: .serif))
                    .foregroundColor(Color(red: 0.29, green: 0.36, blue: 0.31))
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            lastReadSurah = surah.id
            lastReadSurahName = surah.nameEN
        })
    }
}
