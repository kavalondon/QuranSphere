import SwiftUI

// MARK: - Models
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
    
    // Reader Settings
    @AppStorage("arabicFont") private var arabicFont: String = "Amiri"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28.0
    @AppStorage("scriptStyle") private var scriptStyle: String = "Uthmani"
    
    // Dedicated Mood Card Storage
    @AppStorage("moodArabicFont") private var moodArabicFont: String = "Amiri"
    @AppStorage("moodArabicFontSize") private var moodArabicFontSize: Double = 24.0
    @AppStorage("moodScriptStyle") private var moodScriptStyle: String = "Uthmani"
    
    // Gamification Storage
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("versesReadToday") private var versesReadToday: Int = 0
    @AppStorage("dailyVerseGoal") private var dailyVerseGoal: Int = 5
    @AppStorage("totalHasanat") private var totalHasanat: Int = 0
    
    // MARK: - State
    @State private var activeTab: Tab = .home
    @State private var selectedMood: String = ""
    @State private var currentComfortVerse: JSONVerse? = nil
    
    @State private var searchClearTrigger: Int = 0
    
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
                        case .qibla:     QiblaCompassView()
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
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                let _ = quranManager.verses.count
            }
        }
    }
}

// MARK: - Home View Subcomponents
extension ContentView {
    
    private var homeView: some View {
        VStack(alignment: .leading, spacing: 28) {
            moodAndSearchSection
                .padding(.top, 16)
            comfortVerseSection
            progressDashboard
            quickLinksGrid
            GuidesSectionView() // 🌟 Cleanly calling your separated component file
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
                            searchClearTrigger += 1
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
            
            IsolatedSearchBar(clearTrigger: $searchClearTrigger, isDarkMode: isDarkMode) { query in
                selectedMood = ""
                triggerFastSearch(for: query)
            }
        }
    }
    
    // 2. Comfort Verse Result
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
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                }
                
                Text(verse.text)
                    .font(.custom(moodArabicFont, size: moodArabicFontSize))
                    .lineSpacing(10)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(cleanTranslation(verse.translation))
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .minimalCardStyle(isDarkMode: isDarkMode)
            .padding(.horizontal, 24)
        }
    }
    
    // 3. Gamification Dashboard
    private var progressDashboard: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: QuranReaderView(surahNumber: lastReadSurah, surahName: lastReadSurahName)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue Reading")
                            .font(.system(.title3, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        Text("\(lastReadSurahName) • Verse \(lastReadVerse)")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                }
                .padding(20)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider().padding(.horizontal, 20)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(currentStreak > 0 ? Color.orange : .gray.opacity(0.3))
                        Text("\(currentStreak) \(currentStreak == 1 ? "Day" : "Days")")
                            .font(.system(.subheadline, design: .rounded)).bold()
                    }
                    Text("Current Streak")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(versesReadToday >= dailyVerseGoal ? Color.yellow : .gray.opacity(0.3))
                        Text("\(versesReadToday)/\(dailyVerseGoal)")
                            .font(.system(.subheadline, design: .rounded)).bold()
                    }
                    Text("Daily Verses")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(red: 0.83, green: 0.67, blue: 0.51))
                        Text("\(totalHasanat.formatted())")
                            .font(.system(.subheadline, design: .rounded)).bold()
                    }
                    Text("Hasanat Today")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
            .background(isDarkMode ? Color.white.opacity(0.02) : Color(red: 0.98, green: 0.98, blue: 0.96))
        }
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
    
    // 4. Quick Links
    private var quickLinksGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            NavigationLink(destination: SurahListView(showFavoritesOnly: false)) {
                pageCard(title: "The Holy Quran", icon: "book.fill", bgColor: Color(red: 0.38, green: 0.48, blue: 0.43))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: Text("Daily Duas Coming Soon")) {
                pageCard(title: "Daily Duas", icon: "sparkles", bgColor: Color(red: 0.52, green: 0.61, blue: 0.56))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: BookmarksView()) {
                pageCard(title: "Bookmarks", icon: "bookmark.fill", bgColor: Color(red: 0.38, green: 0.48, blue: 0.43))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: SurahListView(showFavoritesOnly: true)) {
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
        .contentShape(Rectangle())
        .background(bgColor)
        .cornerRadius(16)
    }
    
    private var themeToggle: some View {
        Button(action: {
            isDarkMode.toggle()
        }) {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .foregroundColor(isDarkMode ? .yellow : .orange)
                .font(.system(size: 16, weight: .semibold))
                .padding(8)
                .contentShape(Rectangle())
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
            .contentShape(Rectangle())
        }
    }
    
    private func triggerFastSearch(for term: String) {
        let cleanTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTerm.isEmpty else { return }
        
        guard QuranSearchManager.isSafe(cleanTerm) else {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentComfortVerse = nil
                searchClearTrigger += 1
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let allVerses = quranManager.verses
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

struct IsolatedSearchBar: View {
    @State private var localText: String = ""
    @Binding var clearTrigger: Int
    var isDarkMode: Bool
    var onSubmit: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search verses, topics...", text: $localText)
                .font(.system(.body, design: .serif))
                .submitLabel(.search)
                .onSubmit {
                    let query = localText
                    localText = ""
                    onSubmit(query)
                }
        }
        .padding(16)
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
        .cornerRadius(14)
        .padding(.horizontal, 24)
        .onChange(of: clearTrigger) { oldValue, newValue in
            localText = ""
        }
    }
}

// MARK: - Robust Search, Filter & Thematic Manager
struct QuranSearchManager {
    static let thematicVerses: [String: [(surah: Int, verse: Int)]] = [
        "anxious": [(13, 28), (2, 152), (9, 40), (94, 5), (94, 6), (8, 30), (20, 46), (3, 173), (65, 3), (2, 286)],
        "worry": [(13, 28), (3, 173), (20, 46), (9, 40), (65, 3)],
        "fear": [(2, 38), (3, 175), (20, 46), (10, 62)],
        "sad": [(12, 87), (3, 139), (94, 5), (2, 155), (9, 40), (2, 25), (2, 214), (21, 88), (39, 53), (93, 3)],
        "depressed": [(39, 53), (94, 5), (94, 6), (12, 87), (93, 3)],
        "grief": [(12, 86), (3, 139), (9, 40)],
        "stressed": [(94, 6), (2, 286), (65, 3), (13, 28), (2, 153), (40, 60), (2, 45), (3, 200), (2, 156), (23, 111)],
        "hardship": [(94, 5), (94, 6), (65, 7), (2, 214)],
        "overwhelmed": [(2, 286), (2, 153), (40, 60)],
        "grateful": [(14, 7), (2, 152), (55, 13), (31, 12), (16, 114), (27, 19), (2, 172), (3, 145)],
        "thankful": [(14, 7), (2, 152), (31, 12)],
        "happy": [(10, 58), (3, 170), (43, 70), (76, 11)],
        "peace": [(13, 28), (48, 4), (2, 45), (10, 25), (36, 58), (25, 63), (89, 27)],
        "hope": [(39, 53), (94, 5), (12, 87), (3, 139), (15, 56), (65, 4), (2, 214)],
        "despair": [(39, 53), (12, 87), (15, 56)],
        "angry": [(3, 134), (42, 37), (7, 199), (41, 34), (3, 159), (2, 153)],
        "mad": [(3, 134), (41, 34), (7, 199)],
        "frustrated": [(2, 153), (94, 5), (3, 200)],
        "lonely": [(50, 16), (2, 186), (57, 4), (9, 40), (20, 46), (6, 59), (93, 3)],
        "alone": [(50, 16), (2, 186), (57, 4), (20, 46)],
        "abandoned": [(93, 3), (12, 87), (20, 46)],
        "guilt": [(39, 53), (4, 110), (3, 135), (2, 222), (42, 25), (8, 33)],
        "sin": [(39, 53), (4, 110), (3, 135)],
        "forgiveness": [(39, 53), (3, 135), (7, 153), (11, 90)],
        "isa": [(3, 45), (19, 30), (19, 33), (5, 110), (4, 171)],
        "jesus": [(3, 45), (19, 30), (19, 33), (5, 110), (4, 171)],
        "musa": [(20, 25), (20, 46), (28, 7), (28, 24)],
        "moses": [(20, 25), (20, 46), (28, 7), (28, 24)],
        "muhammad": [(33, 40), (48, 29), (3, 144), (47, 2)],
        "mary": [(19, 17), (3, 42), (19, 27)],
        "maryam": [(19, 17), (3, 42), (19, 27)]
    ]
    
    static let bannedWords: Set<String> = [
        "slag", "slags", "hoe", "hoes", "thot", "thots", "sket", "simp", "incel",
        "milf", "onlyfans", "nsfw", "hentai", "smut", "erotica", "sugar daddy",
        "sugar baby", "baddie", "masturbate", "masturbation", "wank", "wanking",
        "wanker", "wankers", "shag", "shagging", "fuck", "fucked", "fucker", "fucking",
        "motherfucker", "blowjob", "handjob", "anal", "orgy", "orgies", "orgasm",
        "ejaculate", "ejaculation", "cum", "semen", "threesome", "gangbang", "bukkake",
        "bdsm", "dick", "dicks", "cock", "cocks", "prick", "pricks", "schlong",
        "pecker", "boner", "pussy", "cunt", "twat", "clit", "vagina", "penis",
        "boob", "boobs", "tit", "tits", "titties", "ass", "asses", "asshole",
        "arse", "arsehole", "booty", "dildo", "vibrator", "bitch", "bitches",
        "bastard", "shit", "shitty", "bullshit", "crap", "piss", "pissed", "douche",
        "douchebag", "dickhead", "shithead", "dumbass", "jackass", "bugger",
        "bollocks", "fag", "faggot", "dyke", "tranny", "porn", "porno", "pornography",
        "nude", "nudes", "fetish", "kink", "kinky", "escort", "hooker", "hookers",
        "slut", "sluts", "slutty", "whore", "whores", "skank", "pedophile",
        "pedophilia", "pedo", "incest", "nympho", "horny", "suicide", "suicidal",
        "overdose", "self-harm", "slit"
    ]
    
    static func isSafe(_ query: String) -> Bool {
        let cleanQuery = query.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: " ")
        let words = Set(cleanQuery.lowercased().components(separatedBy: .whitespacesAndNewlines))
        return words.isDisjoint(with: bannedWords)
    }
    
    static func findBestVerse(for query: String, from allVerses: [JSONVerse]) -> JSONVerse? {
        guard !allVerses.isEmpty else { return nil }
        let lowQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        var matchedThematicVerses: [(surah: Int, verse: Int)] = []
        
        for (key, versesList) in thematicVerses {
            if lowQuery.contains(key) {
                matchedThematicVerses.append(contentsOf: versesList)
            }
        }
        
        if !matchedThematicVerses.isEmpty {
            if let target = matchedThematicVerses.randomElement(),
               let found = allVerses.first(where: { $0.surahNumber == target.surah && $0.verseNumber == target.verse }) {
                return found
            }
        }
        
        let matchedText = allVerses.filter {
            $0.translation.localizedCaseInsensitiveContains(lowQuery) ||
            $0.text.localizedCaseInsensitiveContains(lowQuery)
        }
        
        return matchedText.randomElement() ?? allVerses.randomElement()
    }
}
