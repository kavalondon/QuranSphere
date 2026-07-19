import SwiftUI
import AVFoundation

struct QuranReaderView: View {
    let surahNumber: Int
    let surahName: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // Core Progress Trackers
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    @AppStorage("readingProgress") private var readingProgress: Double = 0.0
    
    // Feature Storage: Bookmarks (stored as comma-separated integers)
    @AppStorage("bookmarkedVerseIDs") private var bookmarkedVerseIDsStr: String = ""
    
    // Typography AppStorage variables
    @AppStorage("arabicFont") private var arabicFont = "KFGQPCUthmanTahaNaskh"
    @AppStorage("preferredScript") private var preferredScript = "uthmani"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 38.0
    
    @State private var surahVerses: [JSONVerse] = []
    @State private var currentVerseIndex: Int = 0
    @State private var showSettings = false
    
    // Audio Player State
    @State private var audioPlayer: AVPlayer?
    @State private var isPlayingAudio = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
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
            
            if surahVerses.isEmpty {
                ProgressView()
                    .tint(sageGreen)
            } else {
                VStack(spacing: 0) {
                    headerSection
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer().frame(height: 24)
                            
                            verseCard(verse: surahVerses[currentVerseIndex])
                            
                            Text(surahVerses[currentVerseIndex].translation)
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 32)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer().frame(height: 40)
                        }
                    }
                    
                    bottomControls
                }
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadVerses() }
        // Stop audio when the verse finishes playing
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            isPlayingAudio = false
        }
        .sheet(isPresented: $showSettings) {
            ReaderSettingsSheet()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    stopAudio()
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(12)
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(sageGreen)
                    Text("Daily Reading")
                        .font(.system(.subheadline, design: .rounded)).bold()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .clipShape(Capsule())
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            let totalVerses = surahVerses.count
            let currentVerseNum = currentVerseIndex + 1
            let progress = Double(currentVerseNum) / Double(totalVerses)
            
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: sageGreen))
                    .padding(.horizontal, 24)
                
                HStack {
                    Text("\(currentVerseNum) / \(totalVerses)")
                        .font(.system(.caption, design: .rounded)).bold()
                    Spacer()
                    Text("\(totalVerses - currentVerseNum) Verses left")
                        .font(.system(.caption, design: .rounded))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(.caption, design: .rounded)).bold()
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func verseCard(verse: JSONVerse) -> some View {
        let isBookmarked = bookmarkedIDs.contains(verse.id)
        
        return VStack(spacing: 24) {
            HStack {
                // Play Audio Button
                Button(action: { toggleAudio(for: verse) }) {
                    Image(systemName: isPlayingAudio ? "stop.fill" : "play.fill")
                        .foregroundColor(sageGreen)
                        .padding(10)
                        .background(sageGreen.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("\(surahNumber). \(surahName)")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text("\(verse.verseNumber) / \(surahVerses.count)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Bookmark Button
                Button(action: { toggleBookmark(for: verse.id) }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isBookmarked ? sageGreen : .gray)
                }
            }
            
            Text(verse.arabicText(for: preferredScript))
                .font(.custom(arabicFont, size: arabicFontSize))
                .multilineTextAlignment(.center)
                .lineSpacing(18)
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                .frame(maxWidth: .infinity, minHeight: 150)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 16)
                .id(arabicFont + preferredScript + "\(verse.id)")
            
            HStack {
                // Native ShareLink replacing empty button
                let shareText = "\(verse.arabicText(for: preferredScript))\n\n\(verse.translation)\n\n— Quran \(surahNumber):\(verse.verseNumber) (\(surahName))"
                
                ShareLink(item: shareText) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Removed the unused book/pencil icons here to clean up the interface
            }
        }
        .padding(24)
        .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 24)
    }
    
    private var bottomControls: some View {
        HStack {
            Button(action: {
                if currentVerseIndex > 0 {
                    stopAudio()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentVerseIndex -= 1
                        saveProgress()
                    }
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(currentVerseIndex > 0 ? (isDarkMode ? .white : .black) : .gray.opacity(0.3))
                    .frame(width: 60, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(currentVerseIndex > 0 ? .gray.opacity(0.3) : .clear, lineWidth: 1)
                    )
            }
            .disabled(currentVerseIndex == 0)
            
            Spacer()
            
            Button(action: {
                stopAudio()
                dismiss()
            }) {
                Text("I'm Done")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(isDarkMode ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isDarkMode ? Color.white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    .cornerRadius(25)
            }
            
            Spacer()
            
            Button(action: {
                if currentVerseIndex < surahVerses.count - 1 {
                    stopAudio()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentVerseIndex += 1
                        saveProgress()
                    }
                }
            }) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(currentVerseIndex < surahVerses.count - 1 ? (isDarkMode ? .black : .white) : .gray.opacity(0.3))
                    .frame(width: 60, height: 50)
                    .background(currentVerseIndex < surahVerses.count - 1 ? sageGreen : sageGreen.opacity(0.2))
                    .cornerRadius(25)
            }
            .disabled(currentVerseIndex == surahVerses.count - 1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Logic Helpers
    
    private func loadVerses() {
        let filtered = quranManager.verses.filter { $0.surahNumber == surahNumber }
        surahVerses = filtered.sorted { $0.verseNumber < $1.verseNumber }
        
        if lastReadSurah == surahNumber {
            if let index = surahVerses.firstIndex(where: { $0.verseNumber == lastReadVerse }) {
                currentVerseIndex = index
            }
        } else {
            currentVerseIndex = 0
        }
    }
    
    private func saveProgress() {
        guard !surahVerses.isEmpty else { return }
        lastReadSurah = surahNumber
        lastReadSurahName = surahName
        lastReadVerse = surahVerses[currentVerseIndex].verseNumber
        
        let totalVersesInQuran = 6236.0
        readingProgress = min(readingProgress + (1.0 / totalVersesInQuran), 1.0)
    }
    
    // MARK: - Audio Logic
    
    private func toggleAudio(for verse: JSONVerse) {
        if isPlayingAudio {
            stopAudio()
        } else {
            // Uses global verse ID for standard API audio fetching (Mishary Alafasy)
            let urlString = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/\(verse.id).mp3"
            guard let url = URL(string: urlString) else { return }
            
            let playerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: playerItem)
            audioPlayer?.play()
            isPlayingAudio = true
        }
    }
    
    private func stopAudio() {
        audioPlayer?.pause()
        isPlayingAudio = false
    }
    
    // MARK: - Bookmark Logic
    
    private var bookmarkedIDs: [Int] {
        bookmarkedVerseIDsStr.split(separator: ",").compactMap { Int($0) }
    }
    
    private func toggleBookmark(for id: Int) {
        var current = bookmarkedIDs
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        bookmarkedVerseIDsStr = current.map { String($0) }.joined(separator: ",")
    }
}

// MARK: - Reader Settings Sheet
struct ReaderSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("arabicFont") private var arabicFont = "KFGQPCUthmanTahaNaskh"
    @AppStorage("preferredScript") private var preferredScript = "uthmani"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 38.0
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var previewText: String {
        preferredScript == "indopak" ? "بِسۡمِ اللّٰهِ الرَّحۡمٰنِ الرَّحِيۡمِ" : "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    if isDarkMode {
                        Color(red: 0.10, green: 0.12, blue: 0.11)
                    } else {
                        Color(red: 0.97, green: 0.97, blue: 0.95)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 16) {
                            Text("Live Preview")
                                .font(.system(.caption, design: .serif)).bold()
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(previewText)
                                .font(.custom(arabicFont, size: arabicFontSize))
                                .multilineTextAlignment(.center)
                                .lineSpacing(18)
                                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
                                .clipped()
                                .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                                .id(arabicFont + preferredScript)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            
                            Toggle(isOn: $isDarkMode) {
                                HStack {
                                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                        .foregroundColor(isDarkMode ? .yellow : .orange)
                                    Text("Dark Mode")
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                            }
                            .tint(sageGreen)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Script Style")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Picker("Script", selection: $preferredScript) {
                                    Text("Uthmani").tag("uthmani")
                                    Text("IndoPak").tag("indopak")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 16)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Arabic Font")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Picker("Font", selection: $arabicFont) {
                                    Text("Amiri").tag("AmiriQuran-Regular")
                                    Text("Madinah").tag("KFGQPCUthmanTahaNaskh")
                                    Text("Saleem").tag("_PDMS_Saleem_QuranFont")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 16)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Text Size")
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("\(Int(arabicFontSize))")
                                        .font(.system(.subheadline, design: .rounded)).bold()
                                        .foregroundColor(sageGreen)
                                }
                                
                                HStack(spacing: 16) {
                                    Text("A").font(.system(size: 14))
                                    Slider(value: $arabicFontSize, in: 24...64, step: 2)
                                        .tint(sageGreen)
                                    Text("A").font(.system(size: 24))
                                }
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 16)
                        }
                        .padding(.horizontal, 20)
                        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Reader Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(sageGreen)
                    }
                }
            }
        }
        // 🌟 FIX: Placing this modifier ON the NavigationView forces the Navigation Bar to update its title color immediately!
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
