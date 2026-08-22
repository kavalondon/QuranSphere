import SwiftUI

// MARK: - Models
enum Tab {
    case home
    case qibla
    case settings
}

enum HomeTab: String, Hashable {
    case daily = "Daily"
    case khatmah = "Khatmah"
}

struct ContentView: View {
    @EnvironmentObject var quranManager: LocalQuranManager
    @EnvironmentObject var khatmahManager: KhatmahManager
    
    // MARK: - App Storage (Casual Reading)
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    
    // MARK: - App Storage (Khatmah Reading - ISOLATED)
    @AppStorage("khatmahLastReadSurah") private var khatmahSurah = 1
    @AppStorage("khatmahLastReadSurahName") private var khatmahSurahName = "Al-Fatihah"
    @AppStorage("khatmahLastReadVerse") private var khatmahVerse = 1
    
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
    @State private var selectedHomeTab: HomeTab = .daily // Controls the Home Screen Toggle
    @State private var selectedMood: String = ""
    @State private var currentComfortVerse: JSONVerse? = nil
    @State private var showingKhatmahSheet = false
    @State private var searchClearTrigger: Int = 0
    
    // Holds the 4 randomized moods shown on screen
    @State private var activeMoods: [(String, String)] = []
    
    @Namespace private var homeAnimationNamespace
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    // Master list of all emotions
    let masterMoods = [
        ("🥺 Anxious", "anxious"),
        ("😔 Sad", "sad"),
        ("😰 Stressed", "stressed"),
        ("🤲 Grateful", "grateful"),
        ("🕊️ Peace", "peace"),
        ("😊 Happy", "happy"),
        ("✨ Hopeful", "hope"),
        ("❤️ Forgiveness", "forgiveness"),
        ("😵 Overwhelmed", "overwhelmed"),
        ("😨 Fearful", "fear"),
        ("🍃 Patient", "hardship"),
        ("😔 Lonely", "lonely")
    ]
    
    // Hardcoded array of verses for all 114 Surahs for instant, 100% accurate mathematical tracking
    private let versesPerSurah = [7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6]
    
    // MARK: - Dynamic Progress Calculations
    
    private var totalVersesInCurrentSurah: Int {
        let safeSurah = max(1, min(lastReadSurah, 114))
        return versesPerSurah[safeSurah - 1]
    }
    
    private var surahProgress: Double {
        let safeVerse = Double(max(1, lastReadVerse))
        let percentage = safeVerse / Double(totalVersesInCurrentSurah)
        return min(max(percentage, 0.0), 1.0)
    }
    
    private var khatmahProgress: Double {
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
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background Layer (Dismisses keyboard if tapped)
                Group {
                    if isDarkMode {
                        Color(red: 0.10, green: 0.12, blue: 0.11)
                    } else {
                        Color(red: 0.97, green: 0.97, blue: 0.95)
                    }
                }
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch activeTab {
                        case .home:      homeView
                        case .qibla:     QiblaCompassView()
                        case .settings:  SettingsView()
                        }
                    }
                    .padding(.bottom, 140)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    hideKeyboard()
                }
                
                floatingTabBar
                    .padding(.bottom, 12)
            }
            .navigationTitle(activeTab == .home ? "" : (activeTab == .settings ? "Settings" : "Qibla"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            activeMoods = Array(masterMoods.shuffled().prefix(4))
            
            DispatchQueue.global(qos: .background).async {
                let _ = quranManager.verses.count
            }
        }
        .onOpenURL { url in
            let urlString = url.absoluteString
            if urlString.contains("qibla") || url.host == "qibla" {
                activeTab = .qibla
            } else if urlString.contains("settings") || url.host == "settings" {
                activeTab = .settings
            } else if urlString.contains("surah") {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems,
                   let surahStr = queryItems.first(where: { $0.name == "number" })?.value,
                   let surahNum = Int(surahStr) {
                    activeTab = .home
                }
            } else {
                activeTab = .home
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Home View Subcomponents
extension ContentView {
    
    private var homeView: some View {
        VStack(alignment: .leading, spacing: 28) {
            moodAndSearchSection
                .padding(.top, 16)
            comfortVerseSection
            
            // The Master Toggle for the Dashboard
            homeTabToggle
            
            // Dynamic Dashboard Swapping
            if selectedHomeTab == .daily {
                dailyDashboard
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                khatmahDashboard
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
            
            quickLinksGrid
            learningAreaButton
        }
        .animation(.easeInOut(duration: 0.3), value: selectedHomeTab)
        .sheet(isPresented: $showingKhatmahSheet) {
            KhatmahSettingsSheet()
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Home Tab Toggle UI
    private var homeTabToggle: some View {
        HStack(spacing: 0) {
            homeTabButton(title: "Daily Focus", tab: .daily)
            homeTabButton(title: "Khatmah", tab: .khatmah)
        }
        .padding(4)
        .background(isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.12))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func homeTabButton(title: String, tab: HomeTab) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedHomeTab = tab
            }
            hideKeyboard()
        }) {
            Text(title)
                .font(.system(.subheadline, design: .serif))
                .fontWeight(selectedHomeTab == tab ? .bold : .medium)
                .foregroundColor(selectedHomeTab == tab ? .white : (isDarkMode ? .gray : .gray))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .background(
                    ZStack {
                        if selectedHomeTab == tab {
                            Capsule()
                                .fill(sageGreen)
                                .matchedGeometryEffect(id: "HOME_TAB", in: homeAnimationNamespace)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 1. Mood & Search (Strictly Uniform 4-Emotion Row)
    private var moodAndSearchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("How is your heart today?")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.gray)
                
                Spacer()
                
                themeToggle
            }
            .padding(.horizontal, 24)
            
            // 🌟 Exactly 4 uniform columns spanning the screen width identically
            HStack(spacing: 8) {
                ForEach(activeMoods, id: \.1) { label, key in
                    Button(action: {
                        hideKeyboard()
                        searchClearTrigger += 1
                        selectedMood = key
                        triggerFastSearch(for: key)
                    }) {
                        Text(label)
                            .font(.system(size: 11, weight: .semibold, design: .serif))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5) // Scales down cleanly if text is long
                            .foregroundColor(selectedMood == key ? .white : (isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20)))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42) // 🌟 Strict fixed height ensures absolute uniformity
                            .background(
                                selectedMood == key ?
                                Color(red: 0.38, green: 0.48, blue: 0.43) :
                                (isDarkMode ? Color.white.opacity(0.08) : Color.white)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 24)
            
            IsolatedSearchBar(clearTrigger: $searchClearTrigger, isDarkMode: isDarkMode) { query in
                selectedMood = ""
                triggerFastSearch(for: query)
            }
        }
    }
    
    // MARK: - 2. Comfort Verse Result
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
                        hideKeyboard()
                        let target = selectedMood.isEmpty ? "peace" : selectedMood
                        triggerFastSearch(for: target)
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                    }
                    
                    Button(action: {
                        hideKeyboard()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentComfortVerse = nil
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(.leading, 4)
                            .padding(.vertical, 8)
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
    
    // MARK: - 3A. Daily Dashboard
    private var dailyDashboard: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: QuranReaderView(surahNumber: lastReadSurah, surahName: lastReadSurahName)) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Casual Reading")
                                .font(.system(.title3, design: .serif)).bold()
                                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                            
                            Text("\(lastReadSurahName) • \(lastReadVerse) / \(totalVersesInCurrentSurah)")
                                .font(.system(.subheadline, design: .serif))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(sageGreen)
                    }
                    
                    HStack(spacing: 12) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(sageGreen)
                                    .frame(width: geo.size.width * CGFloat(surahProgress), height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(Int(surahProgress * 100))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(sageGreen)
                    }
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
                    Text("Streak")
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
                    Text("Daily Goal")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(accentGold)
                        Text("\(totalHasanat.formatted())")
                            .font(.system(.subheadline, design: .rounded)).bold()
                    }
                    Text("Hasanat")
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
    
    // MARK: - 3B. Khatmah Dashboard
    private var khatmahDashboard: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 16)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(khatmahProgress))
                    .stroke(
                        LinearGradient(colors: [sageGreen, accentGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 140, height: 140)
                    .shadow(color: sageGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 4) {
                    Text(String(format: "%.1f%%", khatmahProgress * 100))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    Text("Completed")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                }
            }
            .padding(.top, 16)
            
            VStack(spacing: 16) {
                if khatmahManager.isKhatmahActive {
                    VStack(spacing: 4) {
                        Text("\(khatmahSurahName) • Verse \(khatmahVerse)")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text("\(khatmahManager.daysRemaining) days remaining to hit your goal")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 12) {
                        NavigationLink(destination: KhatmahReaderView()) {
                            Text("Continue Reading")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(sageGreen)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { showingKhatmahSheet = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isDarkMode ? .white : .black)
                                .padding(14)
                                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 8)
                    
                } else {
                    VStack(spacing: 4) {
                        Text("Start a New Khatmah")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text("Commit to completing the entire Quran.")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: { showingKhatmahSheet = true }) {
                        Text("Configure Goal")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(accentGold)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(24)
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
    }
    
    // MARK: - 4. Quick Links
    private var quickLinksGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            NavigationLink(destination: SurahListView(showFavoritesOnly: false)) {
                compactCard(title: "The Quran", icon: "book.fill", bgColor: sageGreen)
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: DailyDuasView()) {
                compactCard(title: "Daily Duas", icon: "hands.sparkles.fill", bgColor: Color(red: 0.52, green: 0.61, blue: 0.56))
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: BookmarksView()) {
                compactCard(title: "Bookmarks", icon: "bookmark.fill", bgColor: sageGreen)
            }.buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: SurahListView(showFavoritesOnly: true)) {
                compactCard(title: "Favorites", icon: "heart.fill", bgColor: accentGold, iconColor: .red)
            }.buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - 5. Guides & Learning Big Button
    private var learningAreaButton: some View {
        NavigationLink(destination: LearningAreaContainerView(isDarkMode: isDarkMode)) {
            HStack(spacing: 16) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Guides & Learning")
                        .font(.system(.title3, design: .serif)).bold()
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(sageGreen)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 24)
    }
}

// MARK: - Khatmah Settings Sheet Component
struct KhatmahSettingsSheet: View {
    @EnvironmentObject var khatmahManager: KhatmahManager
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("khatmahLastReadSurah") private var khatmahSurah = 1
    @AppStorage("khatmahLastReadSurahName") private var khatmahSurahName = "Al-Fatihah"
    @AppStorage("khatmahLastReadVerse") private var khatmahVerse = 1
    
    @AppStorage("lastReadSurah") private var casualSurah = 1
    @AppStorage("lastReadSurahName") private var casualSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var casualVerse = 1
    
    @State private var selectedDays: Int = 30
    @State private var startFromBeginning: Bool = true
    @State private var enableReminders: Bool = false
    @State private var reminderTime: Date = Date()
    
    let presetDays = [7, 15, 30, 60, 90, 120]
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    private var targetDateString: String {
        guard let targetDate = Calendar.current.date(byAdding: .day, value: selectedDays, to: Date()) else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: targetDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Khatmah Duration")) {
                    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(presetDays, id: \.self) { days in
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                selectedDays = days
                            }) {
                                Text("\(days) Days")
                                    .font(.system(size: 14, weight: selectedDays == days ? .bold : .medium, design: .serif))
                                    .foregroundColor(selectedDays == days ? .white : (isDarkMode ? .white : .black))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedDays == days ? sageGreen : (isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.1)))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(sageGreen)
                        Text("Target Completion: ")
                            .foregroundColor(.gray)
                        + Text(targetDateString)
                            .foregroundColor(sageGreen)
                            .bold()
                    }
                    .font(.system(.caption, design: .serif))
                    .padding(.top, 4)
                }
                
                Section(header: Text("Starting Point")) {
                    Toggle("Start from Al-Fatihah", isOn: $startFromBeginning)
                        .tint(sageGreen)
                    
                    if !startFromBeginning {
                        Text("You will start from your current casual reading position: \(casualSurahName), Verse \(casualVerse).")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Daily Habit")) {
                    Toggle("Enable Daily Reminder", isOn: $enableReminders)
                        .tint(sageGreen)
                    
                    if enableReminders {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section {
                    Button(action: {
                        if startFromBeginning {
                            khatmahSurah = 1
                            khatmahVerse = 1
                            khatmahSurahName = "Al-Fatihah"
                        } else {
                            khatmahSurah = casualSurah
                            khatmahVerse = casualVerse
                            khatmahSurahName = casualSurahName
                        }
                        
                        khatmahManager.startKhatmah(days: selectedDays)
                        dismiss()
                    }) {
                        Text(khatmahManager.isKhatmahActive ? "Update Khatmah Goal" : "Begin Khatmah")
                            .font(.system(.body, design: .serif)).bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(sageGreen)
                    
                    if khatmahManager.isKhatmahActive {
                        Button(role: .destructive, action: {
                            khatmahManager.resetKhatmah()
                            dismiss()
                        }) {
                            Text("Cancel Active Khatmah")
                                .font(.system(.body, design: .serif))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Manage Khatmah")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                selectedDays = khatmahManager.khatmahDaysTarget == 0 ? 30 : khatmahManager.khatmahDaysTarget
            }
        }
    }
}

// MARK: - Helpers
extension ContentView {
    private func compactCard(title: String, icon: String, bgColor: Color, iconColor: Color = .white) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(bgColor)
        .cornerRadius(14)
    }
    
    private var themeToggle: some View {
        Button(action: {
            isDarkMode.toggle()
        }) {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .foregroundColor(isDarkMode ? .yellow : .orange)
                .font(.system(size: 16, weight: .semibold))
                .padding(8)
                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .clipShape(Circle())
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
                    .foregroundColor(activeTab == tab ? sageGreen : .gray)
                Text(name)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(activeTab == tab ? sageGreen : .gray)
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

// MARK: - Learning Area Destination View
struct LearningAreaContainerView: View {
    var isDarkMode: Bool
    
    var body: some View {
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
                VStack(alignment: .leading, spacing: 28) {
                    GuidesSectionView()
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Guides & Learning")
        .navigationBarTitleDisplayMode(.inline)
    }
}
