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
    @AppStorage("readingProgress") private var readingProgress: Double = 0.35
    
    // MARK: - State
    @State private var activeTab: Tab = .home
    @State private var selectedMood: String = ""
    @State private var currentComfortVerse: JSONVerse? = nil
    
    let moods = [
        ("🥺 Anxious", "anxious"),
        ("😔 Sad", "sad"),
        ("😰 Stressed", "stressed"),
        ("🤲 Grateful", "grateful")
    ]
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                Group {
                    if isDarkMode {
                        Color(red: 0.10, green: 0.12, blue: 0.11)
                    } else {
                        Color(red: 0.97, green: 0.97, blue: 0.95)
                    }
                }
                .ignoresSafeArea()
                
                // Tab Content
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
                
                // Floating Bar
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
                .padding(.top, 16) // Removed titles, starts right at the mood tracker
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
                            selectedMood = key
                            triggerSearch(for: key)
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
            
            // 🌟 FIXED: Lag-Free Search Bar Component
            MinimalSearchBar(isDarkMode: isDarkMode) { submittedText in
                selectedMood = ""
                triggerSearch(for: submittedText)
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
                    Button(action: { triggerSearch(for: selectedMood.isEmpty ? "peace" : selectedMood) }) {
                        Image(systemName: "arrow.clockwise").foregroundColor(.gray)
                    }
                }
                Text(verse.text)
                    .font(.system(.title3, design: .serif))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text(verse.translation)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
            }
            .padding(20)
            .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 24)
        }
    }
    
    // 3. Continue Reading Card
    private var continueReadingCard: some View {
        NavigationLink(destination: QuranReaderView(surahNumber: lastReadSurah, surahName: lastReadSurahName)) {
            VStack(alignment: .leading, spacing: 20) {
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
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(readingProgress * 100))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                    }
                    ProgressView(value: readingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.38, green: 0.48, blue: 0.43)))
                }
            }
            .padding(20)
            .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 24)
    }
    
    // 4. Grid Links
    private var quickLinksGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            
            // 🌟 FIXED: Changed to "The Holy Quran"
            NavigationLink(destination: SurahListView()) {
                pageCard(title: "The Holy Quran", icon: "book.fill", bgColor: Color(red: 0.38, green: 0.48, blue: 0.43))
            }.buttonStyle(PlainButtonStyle())
            
            // 🌟 FIXED: Added Daily Duas
            NavigationLink(destination: Text("Duas View Coming Soon")) {
                pageCard(title: "Daily Duas", icon: "hands.sparkles.fill", bgColor: Color(red: 0.55, green: 0.65, blue: 0.60))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: Text("Bookmarks Coming Soon")) {
                pageCard(title: "Bookmarks", icon: "bookmark.fill", bgColor: Color(red: 0.46, green: 0.54, blue: 0.50))
            }.buttonStyle(PlainButtonStyle())
            
            // Kept Ya-Seen to round out the grid nicely
            NavigationLink(destination: QuranReaderView(surahNumber: 36, surahName: "Ya-Seen")) {
                pageCard(title: "Ya-Seen", icon: "heart.fill", bgColor: Color(red: 0.85, green: 0.71, blue: 0.54))
            }.buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Reusable UI Components
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
        .frame(height: 100)
        .background(bgColor)
        .cornerRadius(14)
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
    
    private func triggerSearch(for term: String) {
        guard !term.isEmpty else { return }
        let matchedVerses = quranManager.findVerses(for: term)
        withAnimation(.easeInOut(duration: 0.2)) {
            if let randomMatch = matchedVerses.randomElement() {
                currentComfortVerse = randomMatch
            } else {
                currentComfortVerse = quranManager.verses.randomElement()
            }
        }
    }
}

// MARK: - 🌟 FIXED: Independent Search Bar
// This stops the keyboard from lagging while typing!
struct MinimalSearchBar: View {
    @State private var typedText: String = ""
    var isDarkMode: Bool
    var onSearch: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search verses, topics...", text: $typedText)
                .font(.system(.body, design: .serif))
                .submitLabel(.search)
                .onSubmit {
                    onSearch(typedText)
                }
            
            if !typedText.isEmpty {
                Button(action: {
                    typedText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
        .cornerRadius(14)
        .padding(.horizontal, 24)
    }
}
