//
//  WuduGuideView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 23/07/2026.
//

import SwiftUI

struct WuduGuideView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var bgColor: Color { isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95) }
    var cardColor: Color { isDarkMode ? Color.white.opacity(0.06) : Color.white }
    var textColor: Color { isDarkMode ? .white.opacity(0.9) : Color(red: 0.20, green: 0.22, blue: 0.21) }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    tahaarahSection
                    virtuesSection
                    beforeWuduSection
                    wuduStepsSection
                    masahSection
                    nullifiersSection
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Purification (Wudu')")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - SECTIONS
    
    private var tahaarahSection: some View {
        standardCard(
            title: "Purification & Cleanliness",
            content: "Purification is a profound matter in Islam. One must purify their intention for Allah and physically purify their bodies and clothes before prayer.\n\nIt is obligatory to perform a full ritual bath (Ghusl) instead of Wudu' after intimate relations, after ejaculation, and upon the completion of a woman's menses or post-natal bleeding.",
            color: sageGreen
        )
    }
    
    private var virtuesSection: some View {
        hadithQuoteCard(
            title: "The Virtues of Wudu'",
            text: "When the Muslim or believing servant performs ablution and washes his face, each sin he has committed by his eyes washes away with the water. When he washes his hands, each sin his hands have committed washes away... until he becomes free of sin.",
            reference: "Sahih Muslim",
            color: accentGold
        )
    }
    
    private var beforeWuduSection: some View {
        listCard(
            title: "Before Doing Wudu'",
            items: [
                "1. Relieve yourself first if required, and ensure you clean the private parts (Istinja) properly.",
                "2. It is a highly emphasized Sunnah to clean the teeth with a Miswak (tooth-stick) before performing Wudu'.",
                "3. Ensure no waterproof substances (like nail polish, paint, or certain makeup) are blocking water from reaching the skin."
            ],
            color: sageGreen
        )
    }
    
    private var wuduStepsSection: some View {
        VStack(spacing: 16) {
            // Intro to steps
            standardCard(
                title: "How to Perform Wudu'",
                content: "In the Hanafi school, performing the acts in order (Tarteeb) and washing three times are highly rewarded Sunnahs. The acts marked as Fard are strictly obligatory for the Wudu to be valid.",
                color: accentGold
            )
            
            // Steps
            stepCard(step: 1, title: "Intention & Bismillah", desc: "Make the intention in your heart to perform Wudu' to remove impurity. Then say: Bismillah.", imageName: "wudu_intention", isFard: false)
            
            stepCard(step: 2, title: "Wash Hands (x3)", desc: "Completely wash both hands up to and including the wrists, ensuring water goes between the fingers.", imageName: "wudu_hands", isFard: false)
            
            stepCard(step: 3, title: "Rinse Mouth (x3)", desc: "Using the right hand, take water into the mouth, gargle (if not fasting), and expel it.", imageName: "wudu_mouth", isFard: false)
            
            stepCard(step: 4, title: "Sniff Water (x3)", desc: "Sniff water gently into the nostrils using the right hand, and clean it out using the left hand.", imageName: "wudu_nose", isFard: false)
            
            stepCard(step: 5, title: "Wash Face", desc: "Wash the entire face from the hairline to below the chin, and from earlobe to earlobe. Doing this once is Fard, three times is Sunnah.", imageName: "wudu_face", isFard: true)
            
            stepCard(step: 6, title: "Wash Arms", desc: "Wash both arms completely, starting from the fingertips up to and including the elbows. Begin with the right arm.", imageName: "wudu_arms", isFard: true)
            
            stepCard(step: 7, title: "Wipe Head (Masah)", desc: "Wet your hands and wipe at least one-quarter of the head (the crown). Wiping the whole head is Sunnah.", imageName: "wudu_head", isFard: true)
            
            stepCard(step: 8, title: "Wipe Ears (x1)", desc: "Using the same water, wipe the insides of both ears with the index fingers and the backs with the thumbs.", imageName: "wudu_ears", isFard: false)
            
            stepCard(step: 9, title: "Wash Feet", desc: "Wash both feet up to and including the ankles, ensuring water reaches between the toes. Begin with the right foot.", imageName: "wudu_feet", isFard: true)
            
            stepCard(step: 10, title: "Supplication", desc: "Look towards the sky and recite the Shahada: Ash-hadu anllaa ilaaha illallaah wa ash-hadu anna Muhammadan 'abduhu wa rasooluh.", imageName: "wudu_dua", isFard: false)
        }
    }
    
    private var masahSection: some View {
        standardCard(
            title: "Al-Masah (Wiping over Socks)",
            content: "Wiping over leather socks (Khuffayn) or thick socks that hold their shape without tying is permissible in the Hanafi madhhab, provided they were put on while in a state of Wudu'.\n\nThis is valid for 24 hours for a resident, and 72 hours for a traveler.",
            color: accentGold
        )
    }
    
    private var nullifiersSection: some View {
        listCard(
            title: "What Nullifies Wudu'?",
            items: [
                "1. Passing anything from the front or back passages (wind, urine, stool, madhi, etc).",
                "2. Flowing blood or pus from any part of the body (if it flows past its point of exit).",
                "3. Vomiting a mouthful or more.",
                "4. Sleeping while lying down, or leaning against something such that you would fall if it were removed.",
                "5. Fainting, unconsciousness, or intoxication.",
                "6. Laughing aloud during a prayer that contains bowing and prostration (invalidates both Wudu and Salah).\n\nNote: In the Hanafi school, touching the private parts or touching the opposite gender does not nullify Wudu'."
            ],
            color: sageGreen
        )
    }
    
    // MARK: - REUSABLE UI COMPONENTS
    
    private func standardCard(title: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundColor(color)
            
            Text(content)
                .font(.system(.body, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    private func listCard(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(textColor)
                        .lineSpacing(4)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    private func hadithQuoteCard(title: String, text: String, reference: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
            
            Text("— \(reference)")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.gray)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
    }
    
    private func stepCard(step: Int, title: String, desc: String, imageName: String, isFard: Bool) -> some View {
        let themeColor = isFard ? sageGreen : accentGold
        
        return VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .firstTextBaseline) {
                Text("\(step). \(title)")
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundColor(themeColor)
                
                Spacer()
                
                Text(isFard ? "FARD" : "SUNNAH")
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeColor.opacity(0.1))
                    .foregroundColor(themeColor)
                    .clipShape(Capsule())
            }
            
            Text(desc)
                .font(.system(.body, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
            
            // Minimalist Vector Placeholder
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeColor.opacity(0.3), lineWidth: 1))
    }
}
