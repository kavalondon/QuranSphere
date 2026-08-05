//
//  MoodCardSettingsView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 21/07/2026.
//

import SwiftUI

struct MoodCardSettingsView: View {
    // 🌟 Separate AppStorage for Dashboard Cards
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("moodArabicFont") private var moodArabicFont: String = "KFGQPCUthmanTahaNaskh"
    @AppStorage("moodArabicFontSize") private var moodArabicFontSize: Double = 24.0
    @AppStorage("moodScriptStyle") private var moodScriptStyle: String = "Uthmani"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - Live Preview Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("LIVE PREVIEW")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Surah 13 : Verse 28")
                                .font(.system(.caption, design: .monospaced)).bold()
                                .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                            Spacer()
                            Image(systemName: "bookmark").foregroundColor(.gray)
                        }
                        
                        // The Dynamic Arabic Text Preview
                        Text(sampleArabicText)
                            .font(.custom(moodArabicFont, size: moodArabicFontSize))
                            .lineSpacing(10)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Those who have believed and whose hearts are assured by the remembrance of Allah.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // MARK: - Controls Section
                VStack(spacing: 24) {
                    // Script Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Script Style")
                            .font(.system(.subheadline, design: .serif))
                        Picker("Script Style", selection: $moodScriptStyle) {
                            Text("Uthmani").tag("Uthmani")
                            Text("IndoPak").tag("IndoPak")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Font Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Arabic Font")
                            .font(.system(.subheadline, design: .serif))
                        Picker("Font", selection: $moodArabicFont) {
                            // 🌟 FIXED: Using the exact font file names so it actually updates!
                            Text("Amiri").tag("AmiriQuran-Regular")
                            Text("Madinah").tag("KFGQPCUthmanTahaNaskh")
                            Text("Saleem").tag("_PDMS_Saleem_QuranFont")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Size Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Text Size")
                                .font(.system(.subheadline, design: .serif))
                            Spacer()
                            Text("\(Int(moodArabicFontSize))")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                        }
                        
                        HStack {
                            Text("A").font(.system(size: 14))
                            Slider(value: $moodArabicFontSize, in: 18...40, step: 1)
                                .accentColor(Color(red: 0.38, green: 0.48, blue: 0.43))
                            Text("A").font(.system(size: 28))
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(24)
                .background(isDarkMode ? Color.white.opacity(0.04) : Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
        }
        .background(isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95))
        .navigationTitle("Comfort Verses") // 🌟 FIXED: Added the missing dot here!
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Sample text for the live preview
    private var sampleArabicText: String {
        if moodScriptStyle == "IndoPak" {
            return "الَّذِيْنَ اٰمَنُوْا وَتَطْمَىِٕنُّ قُلُوْبُهُمْ بِذِكْرِ اللّٰهِ"
        } else {
            return "ٱلَّذِينَ ءَامَنُوا۟ وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ ٱللَّهِ"
        }
    }
}
