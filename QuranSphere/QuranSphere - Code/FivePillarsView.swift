//
//  FivePillarsView.swift
//  QuranSphere
//

import SwiftUI

struct PillarModel: Identifiable {
    let id = UUID()
    let name: String
    let englishName: String
    let description: String
    let number: Int
}

struct FivePillarsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme // Detects if user is in Dark or Light mode
    
    // 🎨 DYNAMIC COLORS (Adapts to Dark / Light Mode)
    var bgColor: Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.12, blue: 0.14) // Deep dark gray for dark mode
            : Color(red: 0.97, green: 0.96, blue: 0.94) // Soft off-white/beige for light mode
    }
    
    var cardBg: Color {
        colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.20) : Color.white
    }
    
    let goldAccent = Color(red: 0.83, green: 0.66, blue: 0.53)
    let primaryGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var textDark: Color {
        colorScheme == .dark ? Color.white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    var textGray: Color {
        colorScheme == .dark ? Color(red: 0.75, green: 0.75, blue: 0.75) : Color(red: 0.55, green: 0.55, blue: 0.55)
    }
    
    let pillars = [
        PillarModel(name: "Shahada", englishName: "Faith", description: "The declaration of faith in one God (Allah) and His messenger (peace be upon him).", number: 1),
        PillarModel(name: "Salah", englishName: "Prayer", description: "The ritual prayer required of every Muslim five times a day throughout their lifetime.", number: 2),
        PillarModel(name: "Zakat", englishName: "Almsgiving", description: "The act of giving a portion of a Muslim’s wealth to those in need throughout their lifetime.", number: 3),
        PillarModel(name: "Sawm", englishName: "Fasting", description: "The act of fasting during the holy month of Ramadan.", number: 4),
        PillarModel(name: "Hajj", englishName: "Pilgrimage", description: "The sacred pilgrimage to Mecca required of every Muslim at least once in their lifetime if it is within their means.", number: 5)
    ]
    
    var body: some View {
        ZStack {
            // 1. Dynamic Background Color
            bgColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 2. Custom Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 44, height: 44)
                            .background(colorScheme == .dark ? Color(red: 0.22, green: 0.22, blue: 0.24) : Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("The 5 Pillars")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textDark)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // 3. Header Section
                        VStack(spacing: 12) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 32))
                                .foregroundColor(goldAccent)
                            
                            Text("The Core of Islam")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(textDark)
                            
                            Text("The foundational beliefs and practices required of every Muslim throughout their lifetime.")
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(textGray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .lineSpacing(4)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        // 4. Cards Section
                        VStack(spacing: 16) {
                            ForEach(pillars) { pillar in
                                pillarCard(pillar: pillar)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // 5. Card Component
    private func pillarCard(pillar: PillarModel) -> some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Number Badge
            Text("\(pillar.number)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(primaryGreen)
                .clipShape(Circle())
                .padding(.top, 2)
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                Text("\(pillar.name) (\(pillar.englishName))")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(textDark)
                
                Text(pillar.description)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(textGray)
                    .lineSpacing(5)
            }
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

// Preview provider to check both light and dark modes
struct FivePillarsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FivePillarsView()
                .preferredColorScheme(.light)
            FivePillarsView()
                .preferredColorScheme(.dark)
        }
    }
}
