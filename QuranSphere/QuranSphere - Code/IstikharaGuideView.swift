import SwiftUI

struct IstikharaGuideView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("arabicFont") private var arabicFont: String = "Amiri"
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // MARK: - Intro Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("Seeking Allah’s Guidance")
                        .font(.system(.title2, design: .serif)).bold()
                        .foregroundColor(sageGreen)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Istikhara is a powerful prayer that Muslims perform to seek Allah’s guidance when facing important decisions.")
                        Text("Whether it’s about choosing a job, marriage, or other matters – big or small – Istikhara offers us clarity and peace by placing our trust in Allah’s infinite wisdom.")
                        Text("Here, we explore what Istikhara is, the best time to pray it, and how to perform it, along with the essential Du’a.")
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.75))
                    .lineSpacing(6)
                }
                .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                .padding(.top, 16)
                
                // MARK: - What is Istikhara Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("What is Istikhara?")
                        .font(.system(.title3, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Salat-al-Istikhara translates to the Prayer of Seeking Counsel, and was commonly taught by Prophet Muhammad (peace be upon him) as a crucial part of seeking Allah’s help in making decisions.")
                        Text("It involves praying two voluntary Rakahs (units of prayer) and then making a specific Du’a to seek Allah’s guidance.")
                        Text("By performing Istikhara, we ask Allah (SWT) to guide us to what is best for our faith, life, and future, and to protect us from harm.")
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.75))
                    .lineSpacing(6)
                    
                    // Hadiths
                    VStack(spacing: 16) {
                        GuideHadithCard(
                            text: "It was narrated that the Prophet (PBUH) used to teach his companions Istikhara for each and every matter as he used to teach them surahs from the Holy Qur’an.",
                            reference: "Sahih al-Bukhari, 6382",
                            isDarkMode: isDarkMode,
                            accentGold: accentGold
                        )
                        
                        GuideHadithCard(
                            text: "Amongst the happiness of the son of Adam is the abundance in performing Istikhara... and amongst the misery of the son of Adam is his disregard for Istikhara...",
                            reference: "Tirmidhi",
                            isDarkMode: isDarkMode,
                            accentGold: accentGold
                        )
                    }
                    .padding(.vertical, 8)
                    
                    Text("This highlights its importance as a regular practice for any significant decision. It is a reminder that while we make efforts, ultimate success comes from Allah (SWT).")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.75))
                        .lineSpacing(6)
                }
                .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                
                // MARK: - When to Pray Card
                VStack(alignment: .leading, spacing: 20) {
                    Text("When to pray Istikhara")
                        .font(.system(.title3, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Istikhara can be performed at any time of the day or night, except during the prohibited times of Salah, such as after Fajr and Asr.")
                        Text("The Rakahs can be woven into our normal daily sunnah prayers, such as the two Rakahs before Fajr or after Maghrib, or you can offer them as extra Rakahs.")
                        Text("Many Muslims find a sense of peace when they pray the Salah at night as part of Qiyam ul-Layl (the night prayer), as they tend to feel more focused and connected to Allah during the latter hours of the night.")
                        Text("If they are making a big decision, some tend to perform Istikhara beforehand, i.e. before a job interview or when making decisions about marriage.")
                        Text("It’s best to approach Istikhara with a calm mind and sincere intentions, trusting in Allah’s wisdom to guide you.")
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.75))
                    .lineSpacing(6)
                }
                .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                
                // MARK: - How to Pray Card
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to pray Istikhara")
                            .font(.system(.title3, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        
                        Text("Before beginning, prepare yourself by performing Wudu (ablution) and finding a quiet, clean space.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(isDarkMode ? .white.opacity(0.8) : .gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 28) {
                        GuideStepView(step: 1, text: "Stand facing the Qibla with your feet shoulder-width apart.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 2, text: "Make a sincere intention (Niyyah) to pray Istikhara to seek Allah’s guidance for your specific decision.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 3, text: "Raise your hands and say “Allahu Akbar” (Allah is the greatest) to begin the prayer. Place your right hand over your left above your chest.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 4, text: "Recite Surah Al-Fatihah, followed by another Surah or at least three verses from the Quran.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 5, text: "Bow (Rukoo’) by saying “Allahu Akbar” and place your hands on your knees. Say “Subhana Rabbiy-al-Adheem” at least three times.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 6, text: "Rise from bowing and stand upright saying, “Sami’ Allahu liman hamidah” followed by “Rabbana lakal hamd”.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 7, text: "Prostrate (Sujood) saying “Allahu Akbar”. Say “Subhaana Rabbiy-al-A‘laa” at least three times.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 8, text: "Sit up briefly saying “Allahu Akbar.” Then return to Sujood, repeating “Subhaana Rabbiy-al-A‘laa” at least three times.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 9, text: "Rise from prostration and stand up saying “Allahu Akbar.” This concludes one Rak’ah.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 10, text: "Begin the second Rak’ah and repeat steps 4–8.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 11, text: "After completing two Rak’ahs, sit and recite the Tashahhud.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 12, text: "Send Salawat upon the Prophet Muhammad (peace be upon him).", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 13, text: "Conclude the prayer by turning your head to the right and left, saying “Assalamu alaikum wa rahmatullah” each time.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 14, text: "After completing the Salah, recite the Istikhara Dua with full concentration.", sageGreen: sageGreen, isDarkMode: isDarkMode)
                        GuideStepView(step: 15, text: "Be specific in your mind about the decision you are seeking guidance on. Your Istikhara prayer is now complete, Alhamdulillah!", sageGreen: sageGreen, isDarkMode: isDarkMode)
                    }
                    
                    Divider().opacity(0.5).padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Following the prayer, guidance may come in the form of clarity, ease, or a sense of peace. Not all answers come in dreams, but rather, a conviction towards a certain decision.")
                        Text("If your results are not clear, you could consult with others around you and the people you trust.")
                        Text("Our circumstances in life are all part of Allah’s plan and you should trust in His response. You can repeat the Istikhara prayer if needed, but always have faith in Allah’s plan, even if the answer isn’t immediate or obvious.")
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.75))
                    .lineSpacing(6)
                }
                .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                
                
                // MARK: - The Istikhara Dua Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("The Istikhara Dua")
                        .font(.system(.title3, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    
                    // 1. Arabic Card
                    VStack(alignment: .trailing, spacing: 16) {
                        Text("Arabic")
                            .font(.system(.caption, design: .rounded)).bold()
                            .textCase(.uppercase)
                            .foregroundColor(sageGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلاَ أَقْدِرُ وَتَعْلَمُ وَلاَ أَعْلَمُ وَأَنْتَ عَلاَّمُ الْغُيُوبِ اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاصْرِفْهُ عَنِّي وَاصْرِفْنِي عَنْهُ، وَاقْدُرْ لِي الْخَيْرَ حَيْثُ كَانَ ثُمَّ أَرْضِنِي بِهِ")
                            .font(.custom(arabicFont, size: 28))
                            .lineSpacing(16)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                    
                    // 2. Transliteration Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Transliteration")
                            .font(.system(.caption, design: .rounded)).bold()
                            .textCase(.uppercase)
                            .foregroundColor(sageGreen)
                        
                        Text("Allahumma innee astakheeruka bi ‘ilmika wa astaqdiruka bi qadratika wa as’aluka min fadlika al-’adheem fa innaka taqdiru wa la aqdiru wa ta’lamu wa la a’lamu wa anta ‘allaam ul-ghuyoob. Allahumma in kunta ta’lamu anna haadha al-amra khayrun lee fee deenee wa ma’aashee wa ‘aaqibati amree faqdurhu lee wa yassirhu lee thumma baarik lee feehi wa in kunta ta’lamu anna haadha al-amara sharrun lee fee deenee wa ma’aashee wa ‘aaqibati amree fasrifhu ‘annee wasrifnee ‘anhu waqdur lee al-khayra haythu kaana thumma ardinee bih")
                            .font(.system(.subheadline, design: .serif))
                            .italic()
                            .lineSpacing(6)
                            .foregroundColor(sageGreen)
                            .multilineTextAlignment(.leading)
                    }
                    .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                    
                    // 3. English Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("English")
                            .font(.system(.caption, design: .rounded)).bold()
                            .textCase(.uppercase)
                            .foregroundColor(sageGreen)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("O Allah, I seek Your guidance (in making a choice) by virtue of Your knowledge, and I seek ability by virtue of Your power, and I ask You of Your great bounty. You have power, and I do not. You know, and I know not, and You are the Knower of the unseen.")
                            Text("O Allah, if You know that this matter [mention the thing to be decided] is good for me in my religion, my livelihood, my worldly affairs, and in the hereafter then decree it for me, make it easy for me, and bless it for me.")
                            Text("And if You know that this matter is bad for me in my religion, my livelihood, my worldly affairs, and in the hereafter then turn it away from me and turn me away from it, and decree for me the good wherever it may be and make me content with it.")
                        }
                        .font(.system(.body, design: .serif))
                        .lineSpacing(6)
                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : .gray)
                        .multilineTextAlignment(.leading)
                        
                        Text("[Sahih al-Bukhari, 6382]")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.top, 4)
                    }
                    .modifier(GuideCardModifier(isDarkMode: isDarkMode))
                }
                
                Text("This Dua is a powerful way to align your choices with Allah’s guidance, ensuring peace and contentment in your decisions.")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(isDarkMode ? .white.opacity(0.6) : .gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 20)
        }
        .background(isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95))
        .navigationTitle("Istikhara")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Modifiers & Subviews
struct GuideCardModifier: ViewModifier {
    let isDarkMode: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.025), radius: 10, x: 0, y: 5)
    }
}

struct GuideHadithCard: View {
    let text: String
    let reference: String
    let isDarkMode: Bool
    let accentGold: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "quote.opening")
                .foregroundColor(accentGold.opacity(0.8))
                .font(.system(size: 20, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .font(.system(.subheadline, design: .serif))
                    .italic()
                    .lineSpacing(4)
                    .foregroundColor(isDarkMode ? .white.opacity(0.9) : .black.opacity(0.8))
                
                Text("— \(reference)")
                    .font(.system(.caption, design: .rounded)).bold()
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
        .padding(20)
        .background(isDarkMode ? Color.white.opacity(0.04) : accentGold.opacity(0.08))
        .cornerRadius(16)
    }
}

struct GuideStepView: View {
    let step: Int
    let text: String
    let sageGreen: Color
    let isDarkMode: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                Circle()
                    .fill(sageGreen.opacity(0.12))
                    .frame(width: 32, height: 32)
                Text("\(step)")
                    .font(.system(.caption, design: .rounded)).bold()
                    .foregroundColor(sageGreen)
            }
            .padding(.top, 2)
            
            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundColor(isDarkMode ? .white.opacity(0.9) : .black.opacity(0.8))
                .lineSpacing(6)
        }
    }
}
