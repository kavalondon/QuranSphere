import SwiftUI

// MARK: - App Navigation Tab Model
enum Tab {
    case home
    case qibla
    case settings
}

struct ContentView: View {
    // 🌟 1. CHANGED: Now correctly uses the global app environment manager
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // @AppStorage automatically saves these settings to the phone's memory
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    @AppStorage("readingProgress") private var readingProgress: Double = 0.35 // Example: 35%
    
    // Core Navigation & UI States
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
                // background color matching the clean off-white / light cream canvas
                Group {
                    if isDarkMode {
                        Color(red: 0.10, green: 0.12, blue: 0.11)
                    } else {
                        Color(red: 0.97, green: 0.97, blue: 0.95)
                    }
                }
                .ignoresSafeArea()
                
                // MARK: - Primary Tab Views
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            switch activeTab {
                            case .home:
                                homeView
                            case .qibla:
                                QiblaView()
                            case .settings:
                                SettingsView()
                            }
                        }
                        .padding(.bottom, 100) // Spacing to clear the floating bottom bar
                    }
                }
                
                // MARK: - Restored Floating Bottom Tab Bar
                floatingTabBar
                    .padding(.bottom, 12)
            }
            .navigationTitle(activeTab == .home ? "" : (activeTab == .settings ? "Settings" : "Qibla"))
            .navigationBarTitleDisplayMode(.inline)
            
            // --- MINIMALIST THEME TOGGLE ---
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // withAnimation makes the sun/moon transition smooth
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDarkMode.toggle()
                        }
                    }) {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .yellow : .orange)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
        // --- ACTIVATING THE THEME APP-WIDE ---
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // MARK: - Home View Content Template
    private var homeView: some View {
        VStack(alignment: .leading, spacing: 22) {
            
            // Header: Greeting and Branding Title
            VStack(alignment: .leading, spacing: 4) {
                Text("Assalamu Alaykum")
                    .font(.system(.subheadline))
                    .foregroundColor(.gray)
                Text("QuranSphere")
                    .font(.system(.title, design: .serif))
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.20, green: 0.25, blue: 0.22))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // --- PROGRESS BAR SECTION ---
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Quran Progress")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    Spacer()
                    Text("\(Int(readingProgress * 100))%")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                ProgressView(value: readingProgress)
                    // Styled to match your sage-green branding!
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.38, green: 0.48, blue: 0.43)))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            .padding()
            .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 24)
            
            // Heart-centered Mood Input Section
            VStack(alignment: .leading, spacing: 14) {
                Text("How is your heart today?")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.gray)
                
                // Search Input Card with Heart Icon
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                    TextField("Describe your feeling...", text: $searchText, onCommit: {
                        selectedMood = "" // 🌟 CHANGED: Clears emoji selection if they type
                        triggerSearch(for: searchText)
                    })
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white : .black)
                }
                .padding()
                .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                
                // Horizontal Scrolling Mood Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(moods, id: \.1) { label, key in
                            Button(action: {
                                searchText = "" // 🌟 CHANGED: Clears text search if they tap emoji
                                selectedMood = key
                                triggerSearch(for: key)
                            }) {
                                Text(label)
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(selectedMood == key ? .white : (isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20)))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedMood == key ?
                                        Color(red: 0.38, green: 0.48, blue: 0.43) :
                                        (isDarkMode ? Color.white.opacity(0.08) : Color.white)
                                    )
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // 🌟 2. NEW: THE MOOD BANNER SLIDES IN HERE 🌟
            let activeQuery = !selectedMood.isEmpty ? selectedMood : searchText
            if !activeQuery.isEmpty && currentComfortVerse != nil {
                MoodBannerView(query: activeQuery)
            }
            
            // Dynamic Verse Result Card (shows up on selection or search)
            if let verse = currentComfortVerse {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Surah \(verse.surahNumber) : Verse \(verse.verseNumber)")
                            .font(.system(.caption, design: .monospaced)).bold()
                            .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                        Spacer()
                        Button(action: { triggerSearch(for: selectedMood.isEmpty ? searchText : selectedMood) }) {
                            Image(systemName: "arrow.clockwise").foregroundColor(.gray)
                        }
                    }
                    Text(verse.text)
                        .font(.system(.title3, design: .serif))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    Text(verse.translation)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                }
                .padding(20)
                .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
            
            // Continue Reading Segment
            VStack(alignment: .leading, spacing: 8) {
                Text("CONTINUE READING")
                    .font(.system(.caption, design: .serif)).bold()
                    .foregroundColor(.gray)
                    .tracking(1)
                
                NavigationLink(destination: QuranReaderView(surahNumber: lastReadSurah, surahName: lastReadSurahName)) {
                    HStack {
                        Text("\(lastReadSurahName) • Verse \(lastReadVerse)")
                            .font(.system(.body, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.white)
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            
            // Sage-Green Main Quran Banner Button
            NavigationLink(destination: SurahListView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("The Holy Quran")
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.white)
                            .bold()
                        Text("Read all 114 chapters offline")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding(22)
                .background(Color(red: 0.38, green: 0.48, blue: 0.43))
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            
            // Featured Recitations / Popular Surahs Cards
            VStack(alignment: .leading, spacing: 12) {
                Text("Featured Recitations")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Card 1: Al-Fatihah
                        NavigationLink(destination: QuranReaderView(surahNumber: 1, surahName: "Al-Fatihah")) {
                            featuredCard(title: "Al-Fatihah", subtitle: "The Opening", bgColor: Color(red: 0.46, green: 0.54, blue: 0.50))
                        }
                        
                        // Card 2: Yaseen
                        NavigationLink(destination: QuranReaderView(surahNumber: 36, surahName: "Ya-Seen")) {
                            featuredCard(title: "Yaseen", subtitle: "Heart of Quran", bgColor: Color(red: 0.85, green: 0.71, blue: 0.54))
                        }
                        
                        // Card 3: Al-Mulk
                        NavigationLink(destination: QuranReaderView(surahNumber: 67, surahName: "Al-Mulk")) {
                            featuredCard(title: "Al-Mulk", subtitle: "The Sovereignty", bgColor: Color(red: 0.37, green: 0.44, blue: 0.40))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // Minimal Custom Featured Card Helper
    private func featuredCard(title: String, subtitle: String, bgColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
            Text(title)
                .font(.system(.body, design: .serif)).bold()
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(.caption2, design: .serif))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .frame(width: 130, height: 160)
        .background(bgColor)
        .cornerRadius(14)
    }
    
    // MARK: - Restored Floating Bottom Tab Bar Style
    private var floatingTabBar: some View {
        HStack {
            Spacer()
            
            // Home button
            Button(action: { activeTab = .home }) {
                tabIcon(name: "Home", systemImage: "house.fill", isSelected: activeTab == .home)
            }
            
            Spacer()
            
            // Qibla button
            Button(action: { activeTab = .qibla }) {
                tabIcon(name: "Qibla", systemImage: "safari.fill", isSelected: activeTab == .qibla)
            }
            
            Spacer()
            
            // Settings button
            Button(action: { activeTab = .settings }) {
                tabIcon(name: "Settings", systemImage: "slider.horizontal.3", isSelected: activeTab == .settings)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
    
    private func tabIcon(name: String, systemImage: String, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? Color(red: 0.38, green: 0.48, blue: 0.43) : .gray)
            Text(name)
                .font(.system(size: 11, design: .serif))
                .foregroundColor(isSelected ? Color(red: 0.38, green: 0.48, blue: 0.43) : .gray)
        }
        .frame(width: 60)
    }
    
    // Qibla Placeholder Page View layout
    private var qiblaPlaceholderView: some View {
        VStack(spacing: 20) {
            Image(systemName: "safari")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
            Text("Qibla Compass")
                .font(.system(.title2, design: .serif))
            Text("Calibration and magnetic direction-finding sensor tools coming soon.")
                .font(.system(.body, design: .serif))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
    
    private func triggerSearch(for term: String) {
        guard !term.isEmpty else { return }
        let matchedVerses = quranManager.findVerses(for: term)
        withAnimation(.easeInOut(duration: 0.2)) {
            if let randomMatch = matchedVerses.randomElement() {
                self.currentComfortVerse = randomMatch
            } else {
                self.currentComfortVerse = quranManager.verses.randomElement()
            }
        }
    }
}
