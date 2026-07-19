import SwiftUI

struct SurahListView: View {
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // Bring in the Dark Mode setting
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("favoriteSurahIDs") private var favoriteSurahIDsStr: String = ""
    
    @State private var searchText: String = ""
    @State private var selectedFilter: SurahFilter = .all
    
    enum SurahFilter {
        case all, featured, favorites
    }
    
    // Dynamic Colors based on Dark Mode
    var bgColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95)
    }
    
    var cardColor: Color {
        isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header & Filter Pills
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search Surah name or number...", text: $searchText)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                .padding(12)
                .background(cardColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                
                HStack(spacing: 10) {
                    filterButton(title: "All", filter: .all)
                    filterButton(title: "Featured", filter: .featured)
                    filterButton(title: "Favourites", filter: .favorites)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(bgColor)
            
            // MARK: - Surahs List
            List {
                ForEach(filteredSurahs, id: \.id) { surah in
                    surahRow(for: surah)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background(bgColor)
        }
        .navigationTitle("The Holy Quran")
        .navigationBarTitleDisplayMode(.inline)
        // 🌟 Magic fix: Links the system UI to your custom toggle!
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func filterButton(title: String, filter: SurahFilter) -> some View {
        Button(action: { selectedFilter = filter }) {
            Text(title)
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(selectedFilter == filter ? .white : (isDarkMode ? .gray : Color(red: 0.29, green: 0.36, blue: 0.31)))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedFilter == filter ? Color(red: 0.38, green: 0.48, blue: 0.43) : cardColor)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
    }
    
    private var filteredSurahs: [SurahMetadataModel] {
        let all = SurahMetadataModel.allSurahs
        
        let categoryFiltered: [SurahMetadataModel] = {
            switch selectedFilter {
            case .all:
                return all
            case .featured:
                return all.filter { [2, 36, 55, 56, 67].contains($0.id) }
            case .favorites:
                let favIDs = favoriteIDs
                return all.filter { favIDs.contains($0.id) }
            }
        }()
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter {
                $0.nameEN.localizedCaseInsensitiveContains(searchText) ||
                $0.nameAR.localizedCaseInsensitiveContains(searchText) ||
                String($0.id) == searchText
            }
        }
    }
    
    private func surahRow(for surah: SurahMetadataModel) -> some View {
        let isFav = favoriteIDs.contains(surah.id)
        
        return ZStack {
            HStack(spacing: 16) {
                Text("\(surah.id)")
                    .font(.system(.caption, design: .monospaced))
                    .bold()
                    .frame(width: 36, height: 36)
                    .background(isDarkMode ? Color.white.opacity(0.1) : Color(red: 0.91, green: 0.94, blue: 0.91))
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.29, green: 0.36, blue: 0.31))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(surah.nameEN)
                        .font(.system(.body, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    Text("\(surah.totalVerses) Verses • \(surah.type)")
                        .font(.system(.caption2, design: .serif))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 14) {
                    Text(surah.nameAR)
                        .font(.system(.title3, design: .serif))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.29, green: 0.36, blue: 0.31))
                    
                    Button(action: {
                        toggleFavorite(surah.id)
                    }) {
                        Image(systemName: isFav ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundColor(isFav ? Color(red: 0.83, green: 0.67, blue: 0.51) : .gray.opacity(0.5))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(16)
            .background(cardColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
            .padding(.vertical, 4)
            
            NavigationLink(destination: QuranReaderView(surahNumber: surah.id, surahName: surah.nameEN)) {
                Color.clear
            }
            .opacity(0)
            .simultaneousGesture(TapGesture().onEnded {
                lastReadSurah = surah.id
                lastReadSurahName = surah.nameEN
            })
        }
    }
    
    private var favoriteIDs: [Int] {
        favoriteSurahIDsStr.split(separator: ",").compactMap { Int($0) }
    }
    
    private func toggleFavorite(_ id: Int) {
        var current = favoriteIDs
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        favoriteSurahIDsStr = current.map { String($0) }.joined(separator: ",")
    }
}

// MARK: - Complete 114 Surahs Metadata Model Dataset
struct SurahMetadataModel: Identifiable {
    let id: Int
    let nameEN: String
    let nameAR: String
    let type: String
    let totalVerses: Int
    
    static let allSurahs: [SurahMetadataModel] = [
        SurahMetadataModel(id: 1, nameEN: "Al-Fatihah", nameAR: "الفاتحة", type: "Meccan", totalVerses: 7),
        SurahMetadataModel(id: 2, nameEN: "Al-Baqarah", nameAR: "البقرة", type: "Medinan", totalVerses: 286),
        SurahMetadataModel(id: 3, nameEN: "Ali 'Imran", nameAR: "آل عمران", type: "Medinan", totalVerses: 200),
        SurahMetadataModel(id: 4, nameEN: "An-Nisa'", nameAR: "النساء", type: "Medinan", totalVerses: 176),
        SurahMetadataModel(id: 5, nameEN: "Al-Ma'idah", nameAR: "المائدة", type: "Medinan", totalVerses: 120),
        SurahMetadataModel(id: 6, nameEN: "Al-An'am", nameAR: "الأنعام", type: "Meccan", totalVerses: 165),
        SurahMetadataModel(id: 7, nameEN: "Al-A'raf", nameAR: "الأعراف", type: "Meccan", totalVerses: 206),
        SurahMetadataModel(id: 8, nameEN: "Al-Anfal", nameAR: "الأنفال", type: "Medinan", totalVerses: 75),
        SurahMetadataModel(id: 9, nameEN: "At-Tawbah", nameAR: "التوبة", type: "Medinan", totalVerses: 129),
        SurahMetadataModel(id: 10, nameEN: "Yunus", nameAR: "يونس", type: "Meccan", totalVerses: 109),
        SurahMetadataModel(id: 11, nameEN: "Hud", nameAR: "هود", type: "Meccan", totalVerses: 123),
        SurahMetadataModel(id: 12, nameEN: "Yusuf", nameAR: "يوسف", type: "Meccan", totalVerses: 111),
        SurahMetadataModel(id: 13, nameEN: "Ar-Ra'd", nameAR: "الرعد", type: "Medinan", totalVerses: 43),
        SurahMetadataModel(id: 14, nameEN: "Ibrahim", nameAR: "إبراهيم", type: "Meccan", totalVerses: 52),
        SurahMetadataModel(id: 15, nameEN: "Al-Hijr", nameAR: "الحجر", type: "Meccan", totalVerses: 99),
        SurahMetadataModel(id: 16, nameEN: "An-Nahl", nameAR: "النحل", type: "Meccan", totalVerses: 128),
        SurahMetadataModel(id: 17, nameEN: "Al-Isra'", nameAR: "الإسراء", type: "Meccan", totalVerses: 111),
        SurahMetadataModel(id: 18, nameEN: "Al-Kahf", nameAR: "الكهف", type: "Meccan", totalVerses: 110),
        SurahMetadataModel(id: 19, nameEN: "Maryam", nameAR: "مريم", type: "Meccan", totalVerses: 98),
        SurahMetadataModel(id: 20, nameEN: "Ta-Ha", nameAR: "طه", type: "Meccan", totalVerses: 135),
        SurahMetadataModel(id: 21, nameEN: "Al-Anbiya'", nameAR: "الأنبياء", type: "Meccan", totalVerses: 112),
        SurahMetadataModel(id: 22, nameEN: "Al-Hajj", nameAR: "الحج", type: "Medinan", totalVerses: 78),
        SurahMetadataModel(id: 23, nameEN: "Al-Mu'minun", nameAR: "المؤمنون", type: "Meccan", totalVerses: 118),
        SurahMetadataModel(id: 24, nameEN: "An-Nur", nameAR: "النور", type: "Medinan", totalVerses: 64),
        SurahMetadataModel(id: 25, nameEN: "Al-Furqan", nameAR: "الفرقان", type: "Meccan", totalVerses: 77),
        SurahMetadataModel(id: 26, nameEN: "Ash-Shu'ara", nameAR: "الشعراء", type: "Meccan", totalVerses: 227),
        SurahMetadataModel(id: 27, nameEN: "An-Naml", nameAR: "النمل", type: "Meccan", totalVerses: 93),
        SurahMetadataModel(id: 28, nameEN: "Al-Qasas", nameAR: "القصص", type: "Meccan", totalVerses: 88),
        SurahMetadataModel(id: 29, nameEN: "Al-'Ankabut", nameAR: "العنكبوت", type: "Meccan", totalVerses: 69),
        SurahMetadataModel(id: 30, nameEN: "Ar-Rum", nameAR: "الروم", type: "Meccan", totalVerses: 60),
        SurahMetadataModel(id: 31, nameEN: "Luqman", nameAR: "لقمان", type: "Meccan", totalVerses: 34),
        SurahMetadataModel(id: 32, nameEN: "As-Sajdah", nameAR: "السجدة", type: "Meccan", totalVerses: 30),
        SurahMetadataModel(id: 33, nameEN: "Al-Ahzab", nameAR: "الأحزاب", type: "Medinan", totalVerses: 73),
        SurahMetadataModel(id: 34, nameEN: "Saba'", nameAR: "سبأ", type: "Meccan", totalVerses: 54),
        SurahMetadataModel(id: 35, nameEN: "Fatir", nameAR: "فاطر", type: "Meccan", totalVerses: 45),
        SurahMetadataModel(id: 36, nameEN: "Ya-Sin", nameAR: "يس", type: "Meccan", totalVerses: 83),
        SurahMetadataModel(id: 37, nameEN: "As-Saffat", nameAR: "الصافات", type: "Meccan", totalVerses: 182),
        SurahMetadataModel(id: 38, nameEN: "Sad", nameAR: "ص", type: "Meccan", totalVerses: 88),
        SurahMetadataModel(id: 39, nameEN: "Az-Zumar", nameAR: "الزمر", type: "Meccan", totalVerses: 75),
        SurahMetadataModel(id: 40, nameEN: "Ghafir", nameAR: "غافر", type: "Meccan", totalVerses: 85),
        SurahMetadataModel(id: 41, nameEN: "Fussilat", nameAR: "فصلت", type: "Meccan", totalVerses: 54),
        SurahMetadataModel(id: 42, nameEN: "Ash-Shura", nameAR: "الشورى", type: "Meccan", totalVerses: 53),
        SurahMetadataModel(id: 43, nameEN: "Az-Zukhruf", nameAR: "الزخرف", type: "Meccan", totalVerses: 89),
        SurahMetadataModel(id: 44, nameEN: "Ad-Dukhan", nameAR: "الدخان", type: "Meccan", totalVerses: 59),
        SurahMetadataModel(id: 45, nameEN: "Al-Jathiyah", nameAR: "الجاثية", type: "Meccan", totalVerses: 37),
        SurahMetadataModel(id: 46, nameEN: "Al-Ahqaf", nameAR: "الأحقاف", type: "Meccan", totalVerses: 35),
        SurahMetadataModel(id: 47, nameEN: "Muhammad", nameAR: "محمد", type: "Medinan", totalVerses: 38),
        SurahMetadataModel(id: 48, nameEN: "Al-Fath", nameAR: "الفتح", type: "Medinan", totalVerses: 29),
        SurahMetadataModel(id: 49, nameEN: "Al-Hujurat", nameAR: "الحجرات", type: "Medinan", totalVerses: 18),
        SurahMetadataModel(id: 50, nameEN: "Qaf", nameAR: "ق", type: "Meccan", totalVerses: 45),
        SurahMetadataModel(id: 51, nameEN: "Ad-Dhariyat", nameAR: "الذاريات", type: "Meccan", totalVerses: 60),
        SurahMetadataModel(id: 52, nameEN: "At-Tur", nameAR: "الطور", type: "Meccan", totalVerses: 49),
        SurahMetadataModel(id: 53, nameEN: "An-Najm", nameAR: "النجم", type: "Meccan", totalVerses: 62),
        SurahMetadataModel(id: 54, nameEN: "Al-Qamar", nameAR: "القمر", type: "Meccan", totalVerses: 55),
        SurahMetadataModel(id: 55, nameEN: "Ar-Rahman", nameAR: "الرحمن", type: "Medinan", totalVerses: 78),
        SurahMetadataModel(id: 56, nameEN: "Al-Waqi'ah", nameAR: "الواقعة", type: "Meccan", totalVerses: 96),
        SurahMetadataModel(id: 57, nameEN: "Al-Hadid", nameAR: "الحديد", type: "Medinan", totalVerses: 29),
        SurahMetadataModel(id: 58, nameEN: "Al-Mujadila", nameAR: "المجادلة", type: "Medinan", totalVerses: 22),
        SurahMetadataModel(id: 59, nameEN: "Al-Hashr", nameAR: "الحشر", type: "Medinan", totalVerses: 24),
        SurahMetadataModel(id: 60, nameEN: "Al-Mumtahana", nameAR: "الممتحنة", type: "Medinan", totalVerses: 13),
        SurahMetadataModel(id: 61, nameEN: "As-Saff", nameAR: "الصف", type: "Medinan", totalVerses: 14),
        SurahMetadataModel(id: 62, nameEN: "Al-Jumu'ah", nameAR: "الجمعة", type: "Medinan", totalVerses: 11),
        SurahMetadataModel(id: 63, nameEN: "Al-Munafiqun", nameAR: "المنافقون", type: "Medinan", totalVerses: 11),
        SurahMetadataModel(id: 64, nameEN: "At-Taghabun", nameAR: "التغابن", type: "Medinan", totalVerses: 18),
        SurahMetadataModel(id: 65, nameEN: "At-Talaq", nameAR: "الطلاق", type: "Medinan", totalVerses: 12),
        SurahMetadataModel(id: 66, nameEN: "At-Tahrim", nameAR: "التحريم", type: "Medinan", totalVerses: 12),
        SurahMetadataModel(id: 67, nameEN: "Al-Mulk", nameAR: "الملك", type: "Meccan", totalVerses: 30),
        SurahMetadataModel(id: 68, nameEN: "Al-Qalam", nameAR: "القلم", type: "Meccan", totalVerses: 52),
        SurahMetadataModel(id: 69, nameEN: "Al-Haqqah", nameAR: "الحاقة", type: "Meccan", totalVerses: 52),
        SurahMetadataModel(id: 70, nameEN: "Al-Ma'arij", nameAR: "المعارج", type: "Meccan", totalVerses: 44),
        SurahMetadataModel(id: 71, nameEN: "Nuh", nameAR: "نوح", type: "Meccan", totalVerses: 28),
        SurahMetadataModel(id: 72, nameEN: "Al-Jinn", nameAR: "الجن", type: "Meccan", totalVerses: 28),
        SurahMetadataModel(id: 73, nameEN: "Al-Muzzammil", nameAR: "المزمل", type: "Meccan", totalVerses: 20),
        SurahMetadataModel(id: 74, nameEN: "Al-Muddaththir", nameAR: "المدثر", type: "Meccan", totalVerses: 56),
        SurahMetadataModel(id: 75, nameEN: "Al-Qiyamah", nameAR: "القيامة", type: "Meccan", totalVerses: 40),
        SurahMetadataModel(id: 76, nameEN: "Al-Insan", nameAR: "الإنسان", type: "Medinan", totalVerses: 31),
        SurahMetadataModel(id: 77, nameEN: "Al-Mursalat", nameAR: "المرسلات", type: "Meccan", totalVerses: 50),
        SurahMetadataModel(id: 78, nameEN: "An-Naba'", nameAR: "النبأ", type: "Meccan", totalVerses: 40),
        SurahMetadataModel(id: 79, nameEN: "An-Nazi'at", nameAR: "النازعات", type: "Meccan", totalVerses: 46),
        SurahMetadataModel(id: 80, nameEN: "'Abasa", nameAR: "عبس", type: "Meccan", totalVerses: 42),
        SurahMetadataModel(id: 81, nameEN: "At-Takwir", nameAR: "التكوير", type: "Meccan", totalVerses: 29),
        SurahMetadataModel(id: 82, nameEN: "Al-Infitar", nameAR: "الانفطار", type: "Meccan", totalVerses: 19),
        SurahMetadataModel(id: 83, nameEN: "Al-Mutaffifin", nameAR: "المطففين", type: "Meccan", totalVerses: 36),
        SurahMetadataModel(id: 84, nameEN: "Al-Inshiqaq", nameAR: "الانشقاق", type: "Meccan", totalVerses: 25),
        SurahMetadataModel(id: 85, nameEN: "Al-Buruj", nameAR: "البروج", type: "Meccan", totalVerses: 22),
        SurahMetadataModel(id: 86, nameEN: "At-Tariq", nameAR: "الطارق", type: "Meccan", totalVerses: 17),
        SurahMetadataModel(id: 87, nameEN: "Al-A'la", nameAR: "الأعلى", type: "Meccan", totalVerses: 19),
        SurahMetadataModel(id: 88, nameEN: "Al-Ghashiyah", nameAR: "الغاشية", type: "Meccan", totalVerses: 26),
        SurahMetadataModel(id: 89, nameEN: "Al-Fajr", nameAR: "الفجر", type: "Meccan", totalVerses: 30),
        SurahMetadataModel(id: 90, nameEN: "Al-Balad", nameAR: "البلد", type: "Meccan", totalVerses: 20),
        SurahMetadataModel(id: 91, nameEN: "Ash-Shams", nameAR: "الشمس", type: "Meccan", totalVerses: 15),
        SurahMetadataModel(id: 92, nameEN: "Al-Lail", nameAR: "الليل", type: "Meccan", totalVerses: 21),
        SurahMetadataModel(id: 93, nameEN: "Ad-Duha", nameAR: "الضحى", type: "Meccan", totalVerses: 11),
        SurahMetadataModel(id: 94, nameEN: "Ash-Sharh", nameAR: "الشرح", type: "Meccan", totalVerses: 8),
        SurahMetadataModel(id: 95, nameEN: "At-Tin", nameAR: "التين", type: "Meccan", totalVerses: 8),
        SurahMetadataModel(id: 96, nameEN: "Al-'Alaq", nameAR: "العلق", type: "Meccan", totalVerses: 19),
        SurahMetadataModel(id: 97, nameEN: "Al-Qadr", nameAR: "القدر", type: "Meccan", totalVerses: 5),
        SurahMetadataModel(id: 98, nameEN: "Al-Bayyinah", nameAR: "البينة", type: "Medinan", totalVerses: 8),
        SurahMetadataModel(id: 99, nameEN: "Az-Zalzalah", nameAR: "الزلزلة", type: "Medinan", totalVerses: 8),
        SurahMetadataModel(id: 100, nameEN: "Al-'Adiyat", nameAR: "العاديات", type: "Meccan", totalVerses: 11),
        SurahMetadataModel(id: 101, nameEN: "Al-Qari'ah", nameAR: "القارعة", type: "Meccan", totalVerses: 11),
        SurahMetadataModel(id: 102, nameEN: "At-Takathur", nameAR: "التكاثر", type: "Meccan", totalVerses: 8),
        SurahMetadataModel(id: 103, nameEN: "Al-Asr", nameAR: "العصر", type: "Meccan", totalVerses: 3),
        SurahMetadataModel(id: 104, nameEN: "Al-Humazah", nameAR: "الهمزة", type: "Meccan", totalVerses: 9),
        SurahMetadataModel(id: 105, nameEN: "Al-Fil", nameAR: "الفيل", type: "Meccan", totalVerses: 5),
        SurahMetadataModel(id: 106, nameEN: "Quraysh", nameAR: "قريش", type: "Meccan", totalVerses: 4),
        SurahMetadataModel(id: 107, nameEN: "Al-Ma'un", nameAR: "الماعون", type: "Meccan", totalVerses: 7),
        SurahMetadataModel(id: 108, nameEN: "Al-Kawthar", nameAR: "الكوثر", type: "Meccan", totalVerses: 3),
        SurahMetadataModel(id: 109, nameEN: "Al-Kafirun", nameAR: "الكافرون", type: "Meccan", totalVerses: 6),
        SurahMetadataModel(id: 110, nameEN: "An-Nasr", nameAR: "النصر", type: "Medinan", totalVerses: 3),
        SurahMetadataModel(id: 111, nameEN: "Al-Masad", nameAR: "المسد", type: "Meccan", totalVerses: 5),
        SurahMetadataModel(id: 112, nameEN: "Al-Ikhlas", nameAR: "الإخلاص", type: "Meccan", totalVerses: 4),
        SurahMetadataModel(id: 113, nameEN: "Al-Falaq", nameAR: "الفلق", type: "Meccan", totalVerses: 5),
        SurahMetadataModel(id: 114, nameEN: "An-Nas", nameAR: "الناس", type: "Meccan", totalVerses: 6)
    ]
}
