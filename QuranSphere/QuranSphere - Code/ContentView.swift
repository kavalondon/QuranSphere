import SwiftUI

// MARK: - App Navigation Tab Model
enum Tab {
    case home
    case qibla
    case settings
}

struct ContentView: View {
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // MARK: - App Storage
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    @AppStorage("readingProgress") private var readingProgress: Double = 0.0
    
    // MARK: - State
    @State private var activeTab: Tab = .home
    @State private var searchText: String = ""
    @State private var selectedMood: String = ""
    @State private var currentComfortVerse: JSONVerse? = nil
    
    let moods = [
        ("🥺 Anxious", "anxious"),
        ("😔 Sad", "sad"),
        ("😰 Stressed", "stressed"),
        ("🤲 Grateful", "grateful")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    if isDarkMode {
                        Color(red: 0.10, green: 0.12, blue: 0.11)
                    } else {
                        Color(red: 0.97, green: 0.97, blue: 0.95)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch activeTab {
                        case .home:      homeView
                        case .qibla:     qiblaPlaceholderView
                        case .settings:  SettingsView()
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                floatingTabBar
                    .padding(.bottom, 12)
            }
            .navigationTitle(activeTab == .home ? "" : (activeTab == .settings ? "Settings" : "Qibla"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { themeToggle }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Home View Subcomponents
extension ContentView {
    
    private var homeView: some View {
        VStack(alignment: .leading, spacing: 28) {
            moodAndSearchSection
                .padding(.top, 16)
            comfortVerseSection
            continueReadingCard
            quickLinksGrid
        }
    }
    
    // 1. Mood & Search
    private var moodAndSearchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How is your heart today?")
                .font(.system(.body, design: .serif))
                .foregroundColor(.gray)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Spacer().frame(width: 16)
                    ForEach(moods, id: \.1) { label, key in
                        Button(action: {
                            searchText = ""
                            selectedMood = key
                            triggerFastSearch(for: key)
                        }) {
                            Text(label)
                                .font(.system(.subheadline, design: .serif))
                                .foregroundColor(selectedMood == key ? .white : (isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20)))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    selectedMood == key ?
                                    Color(red: 0.38, green: 0.48, blue: 0.43) :
                                    (isDarkMode ? Color.white.opacity(0.08) : Color.white)
                                )
                                .clipShape(Capsule())
                        }
                    }
                    Spacer().frame(width: 16)
                }
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search verses, topics...", text: $searchText)
                    .font(.system(.body, design: .serif))
                    .submitLabel(.search)
                    .onSubmit {
                        let query = searchText
                        searchText = ""
                        selectedMood = ""
                        triggerFastSearch(for: query)
                    }
            }
            .padding(16)
            .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
            .cornerRadius(14)
            .padding(.horizontal, 24)
        }
    }
    
    // 2. Comfort Verse Result (Directly embedded safely with full unclipped layout)
    @ViewBuilder
    private var comfortVerseSection: some View {
        if let verse = currentComfortVerse {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Surah \(verse.surahNumber) : Verse \(verse.verseNumber)")
                        .font(.system(.caption, design: .monospaced)).bold()
                        .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                    Spacer()
                    Button(action: {
                        let target = selectedMood.isEmpty ? "peace" : selectedMood
                        triggerFastSearch(for: target)
                    }) {
                        Image(systemName: "arrow.clockwise").foregroundColor(.gray)
                    }
                }
                
                // Unclamped text container for Arabic text ensuring complete display without truncation
                Text(verse.text)
                    .font(.system(.title3, design: .serif))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Unclamped text container for English translation ensuring complete viewability
                Text(cleanTranslation(verse.translation))
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .minimalCardStyle(isDarkMode: isDarkMode)
            .padding(.horizontal, 24)
        }
    }
    
    private var continueReadingCard: some View {
        NavigationLink(destination: QuranReaderView(surahNumber: lastReadSurah, surahName: lastReadSurahName)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue Reading")
                            .font(.system(.title2, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        Text("\(lastReadSurahName) • Verse \(lastReadVerse)")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Overall Progress")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(readingProgress * 100))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    ProgressView(value: readingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.55, green: 0.55, blue: 0.52)))
                }
            }
            .minimalCardStyle(isDarkMode: isDarkMode)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 24)
    }
    
    private var quickLinksGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            NavigationLink(destination: SurahListView()) {
                pageCard(title: "The Holy Quran", icon: "book.fill", bgColor: Color(red: 0.38, green: 0.48, blue: 0.43))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: Text("Daily Duas Coming Soon")) {
                pageCard(title: "Daily Duas", icon: "sparkles", bgColor: Color(red: 0.52, green: 0.61, blue: 0.56))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: Text("Bookmarks Coming Soon")) {
                pageCard(title: "Bookmarks", icon: "bookmark.fill", bgColor: Color(red: 0.38, green: 0.48, blue: 0.43))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: SurahListView()) {
                pageCard(title: "Favourite Surahs", icon: "star.fill", bgColor: Color(red: 0.83, green: 0.67, blue: 0.51))
            }.buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Helpers
extension ContentView {
    private func pageCard(title: String, icon: String, bgColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            Spacer()
            Text(title)
                .font(.system(.body, design: .serif)).bold()
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 110, maxHeight: 110)
        .background(bgColor)
        .cornerRadius(16)
    }
    
    private var themeToggle: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) { isDarkMode.toggle() }
        }) {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .foregroundColor(isDarkMode ? .yellow : .orange)
                .font(.system(size: 16, weight: .semibold))
        }
    }
    
    private var floatingTabBar: some View {
        HStack {
            Spacer()
            tabButton(tab: .home, name: "Home", icon: "house.fill")
            Spacer()
            tabButton(tab: .qibla, name: "Qibla", icon: "safari.fill")
            Spacer()
            tabButton(tab: .settings, name: "Settings", icon: "slider.horizontal.3")
            Spacer()
        }
        .padding(.vertical, 12)
        .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
    
    private func tabButton(tab: Tab, name: String, icon: String) -> some View {
        Button(action: { activeTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(activeTab == tab ? Color(red: 0.38, green: 0.48, blue: 0.43) : .gray)
                Text(name)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(activeTab == tab ? Color(red: 0.38, green: 0.48, blue: 0.43) : .gray)
            }
            .frame(width: 60)
        }
    }
    
    private var qiblaPlaceholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "safari")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
            Text("Qibla Compass")
                .font(.system(.title2, design: .serif))
            Text("Direction-finding sensor tools coming soon.")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.gray)
        }
        .padding(.top, 100)
    }
    
    // MARK: - Reliable Direct Match Search Logic
    private func triggerFastSearch(for term: String) {
        let cleanTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTerm.isEmpty else { return }
        guard QuranSearchManager.isSafe(cleanTerm) else { return }
        
        let allVerses = quranManager.verses
        
        DispatchQueue.global(qos: .userInitiated).async {
            let selectedVerse = QuranSearchManager.findBestVerse(for: cleanTerm, from: allVerses)
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentComfortVerse = selectedVerse
                }
            }
        }
    }
    
    private func cleanTranslation(_ text: String) -> String {
        let pattern = "\\[\\d+\\]|[\\*\\#\\~]"
        return text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - View Modifiers
extension View {
    func minimalCardStyle(isDarkMode: Bool) -> some View {
        self
            .padding(20)
            .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Robust Search & Thematic Manager
struct QuranSearchManager {
    static let thematicVerses: [String: [(surah: Int, verse: Int)]] = [
        "anxious": [(13, 28), (2, 152), (9, 40), (94, 5), (94, 6)],
        "sad": [(12, 87), (3, 139), (94, 5), (2, 155)],
        "stressed": [(94, 6), (2, 286), (65, 3), (13, 28)],
        "grateful": [(14, 7), (2, 152), (55, 13), (31, 12)],
        "peace": [(13, 28), (48, 4), (2, 45)],
        "hope": [(39, 53), (94, 5), (12, 87)]
    ]
    
    static let bannedWords: Set<String> = [
        "suicide", "kill", "die", "death"
    ]
    
    static func isSafe(_ query: String) -> Bool {
        let words = Set(query.lowercased().components(separatedBy: .whitespacesAndNewlines))
        return words.isDisjoint(with: bannedWords)
    }
    
    static func findBestVerse(for query: String, from allVerses: [JSONVerse]) -> JSONVerse? {
        guard !allVerses.isEmpty else { return nil }
        let lowQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Direct thematic match lookup
        for (key, versesList) in thematicVerses {
            if lowQuery.contains(key) || key.contains(lowQuery) {
                if let target = versesList.randomElement(),
                   let found = allVerses.first(where: { $0.surahNumber == target.surah && $0.verseNumber == target.verse }) {
                    return found
                }
            }
        }
        
        // 2. Fallback text search
        let matched = allVerses.filter {
            $0.translation.localizedCaseInsensitiveContains(lowQuery) ||
            $0.text.localizedCaseInsensitiveContains(lowQuery)
        }
        
        return matched.randomElement() ?? allVerses.randomElement()
    }
}
