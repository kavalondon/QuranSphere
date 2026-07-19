import SwiftUI

struct SurahListView: View {
    // 🌟 1. Added the environment object so this view can read your JSON data!
    @EnvironmentObject var quranManager: LocalQuranManager
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var searchText = ""
    
    // We'll keep the popular Surahs manually defined here so you can
    // preserve those beautiful custom subtitles ("Heart of Quran", etc.)
    let popularSurahs = [
        (36, "Ya-Seen", "يس", "Heart of Quran"),
        (67, "Al-Mulk", "الملك", "The Sovereignty"),
        (18, "Al-Kahf", "الكهف", "The Cave"),
        (56, "Al-Waqi'ah", "الواقعة", "The Inevitable")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Group {
                if isDarkMode {
                    Color(red: 0.10, green: 0.12, blue: 0.11)
                } else {
                    Color(red: 0.97, green: 0.97, blue: 0.95)
                }
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search Surah...", text: $searchText)
                            .font(.system(.body, design: .serif))
                            .disableAutocorrection(true)
                    }
                    .padding(16)
                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    
                    // Popular Surahs Section (Horizontal Scroll)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Popular")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                Spacer().frame(width: 8) // Inset spacing
                                
                                ForEach(popularSurahs, id: \.0) { surah in
                                    NavigationLink(destination: QuranReaderView(surahNumber: surah.0, surahName: surah.1)) {
                                        popularSurahCard(number: surah.0, englishName: surah.1, arabicName: surah.2, subtitle: surah.3)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Spacer().frame(width: 8)
                            }
                        }
                    }
                    
                    // All Surahs List Section (Vertical Scroll)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Surahs")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                        
                        LazyVStack(spacing: 16) {
                            
                            // 🌟 2. Real-time Search Filtering Logic
                            let searchResults = searchText.isEmpty ? quranManager.chapters : quranManager.chapters.filter {
                                $0.transliteration.localizedCaseInsensitiveContains(searchText) ||
                                $0.translation.localizedCaseInsensitiveContains(searchText) ||
                                "\($0.id)" == searchText
                            }
                            
                            // 🌟 3. Maps through your ACTUAL 114 Surahs from the JSON
                            ForEach(searchResults, id: \.id) { chapter in
                                NavigationLink(destination: QuranReaderView(surahNumber: chapter.id, surahName: chapter.transliteration)) {
                                    surahListRow(
                                        number: chapter.id,
                                        englishName: chapter.transliteration,
                                        arabicName: chapter.name,
                                        translation: chapter.translation,
                                        verses: chapter.totalVerses
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Adds the divider unless it's the very last item in the list
                                if chapter.id != searchResults.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                        .padding(.leading, 80) // Indents the divider nicely
                                        .padding(.trailing, 24)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Surahs")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Minimalist Subviews
    
    private func popularSurahCard(number: Int, englishName: String, arabicName: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.38, green: 0.48, blue: 0.43).opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("\(number)")
                        .font(.system(.caption, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                }
                Spacer()
                Text(arabicName)
                    .font(.system(.title3, design: .serif))
                    .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(englishName)
                    .font(.system(.body, design: .serif)).bold()
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                Text(subtitle)
                    .font(.system(.caption2, design: .serif))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(width: 150)
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
    
    private func surahListRow(number: Int, englishName: String, arabicName: String, translation: String, verses: Int) -> some View {
        HStack(spacing: 16) {
            // Number Badge
            ZStack {
                Circle()
                    .fill(isDarkMode ? Color.white.opacity(0.06) : Color(red: 0.38, green: 0.48, blue: 0.43).opacity(0.1))
                    .frame(width: 44, height: 44)
                Text("\(number)")
                    .font(.system(.subheadline, design: .serif)).bold()
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.38, green: 0.48, blue: 0.43))
            }
            
            // English Info
            VStack(alignment: .leading, spacing: 4) {
                Text(englishName)
                    .font(.system(.body, design: .serif)).bold()
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                Text(translation)
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Arabic Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(arabicName)
                    .font(.system(.title3, design: .serif))
                    .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                Text("\(verses) Verses")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 4)
        // This makes the entire invisible row clickable, not just the text!
        .contentShape(Rectangle())
    }
}
