import SwiftUI

struct DailyDuasView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var bgColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95)
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header matching PrayerGuideListView
                    VStack(spacing: 12) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 42))
                            .foregroundColor(accentGold)
                        
                        Text("Daily Duas")
                            .font(.system(.title2, design: .serif)).bold()
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        
                        Text("Essential Duas for everyone")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundColor(sageGreen)
                        
                        Text("A collection of authentic, easy-to-memorize duas for various occasions. Perfect for young children, new Muslims, and anyone building a daily dua routine.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                    
                    // MARK: - Menu Cards (List of Duas)
                    VStack(spacing: 16) {
                        ForEach(DuaData.allDuas) { dua in
                            NavigationLink(destination: DuaDetailView(dua: dua)) {
                                duaMenuCard(dua: dua)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Daily Duas")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Menu card layout matching the Prayer Guide design style
    private func duaMenuCard(dua: DailyDua) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(sageGreen.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Text("\(dua.number)")
                    .font(.system(.headline, design: .rounded)).bold()
                    .foregroundColor(sageGreen)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dua.title)
                    .font(.system(.headline, design: .serif)).bold()
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                
                Text(dua.transliteration)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 40, height: 40)
                
                Image(systemName: dua.iconName)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}
