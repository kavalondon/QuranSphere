import SwiftUI

struct SalahStepsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var bgColor: Color { isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95) }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 36) {
                    firstRakahSection
                    secondRakahSection
                    thirdAndFourthRakahSection
                    completingPrayerSection
                }
                .padding(.vertical, 28)
            }
        }
        .navigationTitle("How to Pray")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var firstRakahSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The First Rak'ah")
                .font(.system(.title2, design: .serif)).bold()
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                ExpandableStepCard(step: 1, title: "Takbeer", desc: "Raise both hands to your shoulders or ears, palms facing outward.", arabic: "اللهُ أَكْبَرُ", transliteration: "Allaahu Akbar", translation: "Allah is Greatest", imageName: "salah-step-02-takbeer", themeColor: sageGreen)
                
                ExpandableStepCard(step: 2, title: "Seeking Refuge", desc: "Place your hands on your naval area, with the right hand over the left.", arabic: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّحِيمِ", transliteration: "A'oothu billaahi minash-shaytanir-rajeem", translation: "I seek refuge with Allah from Satan the accursed", imageName: "salah-step-03-qiyam", themeColor: accentGold)
                
                ExpandableStepCard(step: 3, title: "Surah Al-Fatihah", desc: "Recite the opening chapter of the Qur'an.", arabic: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ\nآمين", transliteration: "Bismillaahir-rahmaanir-raheem\nAl-hamdu lillaahi rabbil 'aalameen\nAr-rahmaanir-raheem\nMaaliki yawmiddeen\nIyyaaka na'budu wa iyyaaka nasta'een\nIhdinas-siraatal mustaqeem\nSiratallatheena an'amta 'alayhim\nGhayril maghdoobi 'alayhim\nWaladdaalleen\nAameen", translation: "In the name of Allah, the Most Beneficent, the Most Merciful\nPraise be to Allah the Lord of the Worlds\nThe Most Beneficent, the Most Merciful\nMaster of the Day of Judgement\nYou alone we worship and in You alone we seek help\nGuide us to the straight path\nThe way of those whom You have favoured\nNot the way of those who have earned Your anger\nNor of those who have gone astray\nOh Allah answer our prayer!", imageName: "salah-step-03-qiyam", themeColor: sageGreen)
                
                ExpandableStepCard(step: 4, title: "Another Surah", desc: "Recite another short chapter from the Qur'an.", arabic: nil, transliteration: nil, translation: nil, imageName: "salah-step-03-qiyam", themeColor: accentGold)
                
                ExpandableStepCard(step: 5, title: "Ruku' (Bowing)", desc: "Say Allaahu Akbar, bow down, and praise Allah 3 times.", arabic: "سُبْحَانَ رَبِّيَ الْعَظِيمِ", transliteration: "Subhaana rabbiyal 'atheem", translation: "Glory be to my Lord the Supreme", imageName: "salah-step-04-ruku", themeColor: sageGreen)
                
                ExpandableStepCard(step: 6, title: "Rising from Ruku'", desc: "Stand back up straight.", arabic: "سَمِعَ اللهُ لِمَنْ حَمِدَهُ\nرَبَّنَا وَ لَكَ الْحَمْد", transliteration: "Sami'-Allaahu liman hamidah\nRabbanaa wa lakal hamd", translation: "Allah listens to the one who praises him\nOur Lord, and to You belongs the praise", imageName: "salah-step-05-qawma", themeColor: accentGold)
                
                ExpandableStepCard(step: 7, title: "First Sujood", desc: "Say Allaahu Akbar and prostrate on the ground. Praise Allah 3 times.", arabic: "سُبْحَانَ رَبِّي الأَعْلى", transliteration: "Subhaana rabbiyal 'alaa", translation: "Glory be to my Lord Most High", imageName: "salah-step-06-sujood", themeColor: sageGreen)
                
                ExpandableStepCard(step: 8, title: "Sitting (Jalsa)", desc: "Sit up briefly on your left thigh and ask for forgiveness.", arabic: "رَبِّ اغْفِرْ لِي", transliteration: "Rabbighfirlee", translation: "Oh Allah, forgive me", imageName: "salah-step-07-jalsa", themeColor: accentGold)
                
                ExpandableStepCard(step: 9, title: "Second Sujood", desc: "Prostrate a second time and praise Allah 3 times.", arabic: "سُبْحَانَ رَبِّي الأَعْلى", transliteration: "Subhaana rabbiyal 'alaa", translation: "Glory be to my Lord Most High", imageName: "salah-step-06-sujood", themeColor: sageGreen)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var secondRakahSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The Second Rak'ah")
                .font(.system(.title2, design: .serif)).bold()
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                ExpandableStepCard(step: 10, title: "Stand Up & Repeat", desc: "Stand up saying Allaahu Akbar, and repeat the previous steps (Fatihah, Surah, Ruku, and Sujood).", arabic: nil, transliteration: nil, translation: nil, imageName: "salah-step-05-qawma", themeColor: accentGold)
                
                ExpandableStepCard(step: 11, title: "First Tashahhud", desc: "After the second prostration, sit and recite the full Tashahhud. If praying 2 Rak'ahs, skip to the Completion step.", arabic: "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ\nالسَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ\nالسَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ\nأَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ\nوَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ", transliteration: "Attahiyyaatu lilaahi wassalawaatu wattayyibaatu\nAssalaamu 'alayka ay-yuhan-nabiyyu wa rahmatullaahi wabarakaatuh\nAssalaamu 'alaynaa wa 'alaa 'ibaadil-laahissaliheen\nAsh-hadu allaa ilaaha illallaah\nWa ash-hadu anna Muhammadan 'abduhu wa rasooluh", translation: "All compliments, prayers and pure words are due to Allah\nPeace be upon you Oh Prophet, and the mercy of Allah and His blessings\nPeace be upon us and on the righteous slaves of Allah\nI bear witness that there is no God or deity worthy of worship except Allah\nAnd I bear witness that Muhammad is His slave and Messenger", imageName: "salah-step-08-tashahhud", themeColor: sageGreen)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var thirdAndFourthRakahSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("For 3 or 4 Rak'ah Prayers")
                .font(.system(.title2, design: .serif)).bold()
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                ExpandableStepCard(step: 12, title: "Stand Up Again", desc: "If praying Maghrib, Dhuhr, Asr, or Isha, stand up after the first Tashahhud.", arabic: nil, transliteration: nil, translation: nil, imageName: "salah-step-05-qawma", themeColor: accentGold)
                
                ExpandableStepCard(step: 13, title: "Al-Fatihah Only", desc: "In the 3rd and 4th Rak'ahs, ONLY Surah Al-Fatihah is recited. Do not recite an additional Surah.", arabic: nil, transliteration: nil, translation: nil, imageName: "salah-step-03-qiyam", themeColor: sageGreen)
                
                ExpandableStepCard(step: 14, title: "Repeat Movements", desc: "Perform Ruku' and Sujood just like the previous Rak'ahs.", arabic: nil, transliteration: nil, translation: nil, imageName: "salah-step-06-sujood", themeColor: accentGold)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var completingPrayerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completing the Prayer")
                .font(.system(.title2, design: .serif)).bold()
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                ExpandableStepCard(step: 15, title: "Final Sitting & Salawat", desc: "During your final Rak'ah (2nd, 3rd, or 4th), after reciting Tashahhud, send blessings upon the Prophet.", arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ\nوَعَلَى آلِ مُحَمَّدٍ\nكَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ\nوَعَلَى آلِ إِبْرَاهِيمَ\nإِنَّكَ حَمِيدٌ مَجِيدٌ\nوَبَارِكْ عَلَى مُحَمَّدٍ\nوَعَلَى آلِ مُحَمَّدٍ\nكَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ\nوَعَلَى آلِ إِبْرَاهِيمَ\nإِنَّكَ حَمِيدٌ مَجِيدٌ", transliteration: "Allahumma salli 'ala Muhammad\nwa 'ala aali Muhammad\nkamaa salyta 'ala Ibraheem\nwa 'ala aali Ibraheem\ninnaka hameedun Majeed\nwa baarik 'alaa Muhammad\nwa 'alaa aali Muhammad\nkamaa baarakta 'alaa Ibraheem\nwa 'alaa aali Ibraheem\ninnaka hameedun Majeed", translation: "Oh Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim, indeed You are praiseworthy, Most glorious.\n\nAnd send Your blessings upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim, indeed You are praiseworthy, Most glorious.", imageName: "salah-step-08-tashahhud", themeColor: sageGreen)
                
                ExpandableStepCard(step: 16, title: "Tasleem", desc: "Turn your head to the right, then left, offering peace.", arabic: "السَّلامُ عَلَيْكُمْ وَرَحْمَةُ الله", transliteration: "Assalaamu 'alaykum wa rahmatullah", translation: "May Allah's peace and mercy be upon you", imageName: "salah-step-09-salaam", themeColor: accentGold)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Interactive Expandable Card
struct ExpandableStepCard: View {
    let step: Int
    let title: String
    let desc: String
    let arabic: String?
    let transliteration: String?
    let translation: String?
    let imageName: String
    let themeColor: Color
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isExpanded: Bool = false
    @State private var selectedTab: Int = 0
    
    var cardColor: Color { isDarkMode ? Color.white.opacity(0.06) : Color.white }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // TOP ROW (Always Visible)
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(themeColor.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text("\(step)")
                            .font(.system(.subheadline, design: .rounded)).bold()
                            .foregroundColor(themeColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(.headline, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        
                        Text(desc)
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(18)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // EXPANDABLE CONTENT SECTION
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Spacious edge-to-edge image container with generous height to prevent cropping
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 210)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    if let arabic = arabic, let translit = transliteration, let trans = translation {
                        VStack(spacing: 16) {
                            Picker("Language", selection: $selectedTab) {
                                Text("Arabic").tag(0)
                                Text("Transliteration").tag(1)
                                Text("English").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 20)
                            
                            VStack {
                                if selectedTab == 0 {
                                    Text(arabic)
                                        .font(.custom("Amiri", size: 22))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(10)
                                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                } else if selectedTab == 1 {
                                    Text(translit)
                                        .font(.system(.subheadline, design: .serif)).bold()
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(6)
                                        .foregroundColor(themeColor)
                                } else {
                                    Text(trans)
                                        .font(.system(.subheadline, design: .serif))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(6)
                                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : .gray)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    } else {
                        Spacer().frame(height: 8)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.03), radius: 10, x: 0, y: 4)
    }
}
