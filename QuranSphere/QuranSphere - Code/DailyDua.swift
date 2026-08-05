import Foundation

struct DailyDua: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let arabic: String
    let transliteration: String
    let translation: String
    let benefit: String
    let reference: String
    let iconName: String
}

struct DuaData {
    static let allDuas: [DailyDua] = [
        
        // MARK: - Sleep & Home (1-6)
        DailyDua(
            number: 1,
            title: "Upon Going to Sleep",
            arabic: "اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا",
            transliteration: "Allahumma bis'mika, amuu'tu wa ah'ya",
            translation: "O Allah in Your name, I die and I live.",
            benefit: "Hudhaifah bin Al-Yaman رضي الله عنه narrated that when the Prophet ﷺ wanted to sleep, he would say: \"O Allah, in Your Name I die and I live (Allahumma bis'mika, amuu'tu wa ah'ya).\"",
            reference: "Jami' at-Tirmidhi 3417 | Sahih al-Bukhari 7394",
            iconName: "bed.double.fill"
        ),
        DailyDua(
            number: 2,
            title: "Wake up from Sleep",
            arabic: "اَلْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
            transliteration: "Alhamdulillah hil'ladhi ah'yaana ba'damaa amaa'tanaa wa ilay'hin nushoor",
            translation: "All praise be to Allah, who gave us life after death (sleep is a form of death) and to Him will we be raised and returned.",
            benefit: "Hudhaifah bin Al-Yaman رضي الله عنه narrated that... when he would wake, he would say: \"Allah praise is due to Allah who revived my soul after causing its death and to Him is the resurrection.\"",
            reference: "Jami' at-Tirmidhi 3417 | Sahih al-Bukhari 7394",
            iconName: "sun.max.fill"
        ),
        DailyDua(
            number: 3,
            title: "When Leaving Home",
            arabic: "بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
            transliteration: "Bismillah; Tawakkaltu alal'lah; Wa-laa hawla wa-laa qu'wata illa billaah.",
            translation: "In the Name of Allah, I have placed my trust in Allah, there is no might and no power except by Allah.",
            benefit: "Narrated Anas ibn Malik رضي الله عنه The Prophet ﷺ said: When a man goes out of his house and says: \"In the name of Allah, I trust in Allah; there is no might and no power but in Allah,\" the following will be said to him at that time: \"You are guided, defended and protected.\"",
            reference: "Sunan Abi Dawud 5095",
            iconName: "door.right.hand.open"
        ),
        DailyDua(
            number: 4,
            title: "When Entering Home",
            arabic: "بِسْمِ اللَّهِ وَلَجْنَا، وَ بِسْمِ اللَّهِ خَرَجْنَا، وَعَلَىٰ رَبِّنَا تَوَكَّلْنَا",
            transliteration: "Bismillahi walajnaa; Wa-bismillahi kharajnaa; Wa-ala rabbina tawak'kalnaa.",
            translation: "In the Name of Allah we enter, in the Name of Allah we leave and upon our Lord we depend. Then say: 'As-Salaamu Alaykum' to those present.",
            benefit: "Jabir b. 'Abdullah رضي الله عنه reported Allah's Messenger ﷺ as saying: When a person enters his house and mentions the name of Allah at the time of entering it and while eating the food, Satan says addressing himself: You have no place to spend the night...",
            reference: "Sahih Muslim 2018a",
            iconName: "door.left.hand.closed"
        ),
        DailyDua(
            number: 5,
            title: "Entering the Toilet",
            arabic: "بِسْمِ اللَّهِ، اَللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبْثِ وَالْخَبَائِثِ",
            transliteration: "Bismillah; Allahumma innee A'oodhu-bika minal khubu'thi wal khaba'ith.",
            translation: "In the name of Allah. O Allah I seek refuge in You from the male female evil and Jinn's.",
            benefit: "Narrated Anas bin Malik رضي الله عنه Whenever the Prophet ﷺ went to the lavatory, he used to say: \"Allahumma inni a'udhu bika min al-khubuthi wal khaba'ith.\"\n\nEnter the toilet with left foot first.",
            reference: "Sahih al-Bukhari 6322",
            iconName: "shower.fill"
        ),
        DailyDua(
            number: 6,
            title: "Leaving the Toilet",
            arabic: "غُفْرَانَكَ",
            transliteration: "Ghufranak",
            translation: "I seek Your forgiveness",
            benefit: "Yusuf bin Abi Burdah رضي الله عنه narrated: \"I heard my father say: 'I entered upon 'Aishah, and I heard her say: \"When the Messenger of Allah exited the toilet, he would say: Ghufranaka (I seek Your forgiveness).\n\nLeave the toilet with right foot first.",
            reference: "Sunan Ibn Majah 300",
            iconName: "shower"
        ),
        
        // MARK: - Wudu & Masjid (10-13)
        DailyDua(
            number: 10,
            title: "Start of Wudu",
            arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            transliteration: "Bismillaahir Rahmaa-nir Raheem",
            translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            benefit: "Narrated Nu'am Al-Mujmir رضي الله عنه: Once I went up the roof of the mosque, along with Abu Huraira رضي الله عنه He perform ablution and said, \"I heard the Prophet ﷺ saying, 'On the Day of Resurrection, my followers will be called \"Al-Ghurr-ul- Muhajjalun\" from the trace of ablution and whoever can increase the area of his radiance should do so.\n\ni.e. by performing ablution regularly.",
            reference: "Sahih al-Bukhari 136 | Hisn al-Muslim 12",
            iconName: "drop.fill"
        ),
        DailyDua(
            number: 11,
            title: "Completion of Wudu",
            arabic: "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
            transliteration: "Ash'hadu al'laa ilaaha illallahu;\nWah dahu laa-sharee kalah;\nWa ash'hadu anna;\nMuhammadan ab'duhuu wa'rasooluh.",
            translation: "I testify that there is no one worthy of worship besides Allah. He is all by Himself and has no partner and I testify that Muhammad is Allah's messenger (Rasool).",
            benefit: "Uqba b. 'Amir al-Juhani رضي الله عنه reported:\n\nVerily the Messenger of Allah ﷺ said and then narrated (the hadith) like one (mentioned above) except (this) that he said: He who performed ablution and said: I testify that there is no god but Allah, the One, there is no associate with Him and I testify that Muhammad is His servant and His Messenger.",
            reference: "Sahih Muslim 234b | Hisn al-Muslim 13",
            iconName: "hands.sparkles.fill"
        ),
        DailyDua(
            number: 12,
            title: "Entering the Masjid",
            arabic: "بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
            transliteration: "Bismillah;\nWas'salaatu was'salamu ala rasoolil'lah;\nAllahummah tah'lee ab-waa'ba rahmatik.",
            translation: "In the Name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, open the doors of mercy.",
            benefit: "It was narrated that 'Abdul-Malik bin Sa'eed رضي الله عنه said:\n\n\"I heard Abu Humaid and Abu Usaid say: 'The Messenger of Allah ﷺ said: \"When any one of you enters the Masjid, let him say: 'Allahumma aftahli abwaba rahmatik (O Allah, open to me the gates of your mercy). And when he leaves let him say: Allahumma inni as'aluka min fadlik (O Allah, I ask You of Your bounty).\"'",
            reference: "Sunan an-Nasa'i 729 | Hisn al-Muslim 20",
            iconName: "building.columns.fill"
        ),
        DailyDua(
            number: 13,
            title: "Leaving the Masjid",
            arabic: "بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ",
            transliteration: "Bismillah;\nWas'salaatu was'salamu ala rasoolil'lah;\nAllahumma innee as'aluka min fadlik.",
            translation: "In the Name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, I ask for Your favour, O Allah, verily I seek from You, Your bounty.",
            benefit: "It was narrated that 'Abdul-Malik bin Sa'eed رضي الله عنه said:\n\n\"I heard Abu Humaid and Abu Usaid say: 'The Messenger of Allah ﷺ said: \"When any one of you enters the Masjid, let him say: 'Allahumma aftahli abwaba rahmatik (O Allah, open to me the gates of your mercy). And when he leaves let him say: Allahumma inni as'aluka min fadlik (O Allah, I ask You of Your bounty).\"'",
            reference: "Sunan an-Nasa'i 729 | Hisn al-Muslim 20",
            iconName: "building.columns"
        ),
        
        // MARK: - Sneezing & Health (21-27)
        DailyDua(
            number: 21,
            title: "When Sneezing",
            arabic: "الْحَمْدُ لِلَّهِ",
            transliteration: "Alhamdulillah",
            translation: "All praise is for Allah.",
            benefit: "Narrated Abu Huraira رضي الله عنه\n\nThe Prophet ﷺ said, \"Allah loves sneezing but dislikes yawning; so if anyone of you sneezes and then praises Allah, every Muslim who hears him (praising Allah) has to say Tashmit to him. But as regards yawning, it is from Satan, so if one of you yawns, he should try his best to stop it, for when anyone of you yawns, Satan laughs at him.\"",
            reference: "Sahih al-Bukhari 6226 | Hisn al-Muslim 188",
            iconName: "wind"
        ),
        DailyDua(
            number: 22,
            title: "When Hearing Someone Sneeze",
            arabic: "يَرْحَمُكَ اللَّهُ",
            transliteration: "Yaarha'muka Allah",
            translation: "May Allah have mercy on you.",
            benefit: "Narrated Abu Huraira رضي الله عنه\n\nThe Prophet ﷺ said, \"Allah likes sneezing and dislikes yawning, so if someone sneezes and then praises Allah, then it is obligatory on every Muslim who heard him, to say: May Allah be merciful to you (Yar-hamuka-l-lah). But as regards yawning, it is from Satan, so one must try one's best to stop it, if one says 'Ha' when yawning, Satan will laugh at him.\"",
            reference: "Sahih al-Bukhari 6223 | Hisn al-Muslim 188",
            iconName: "ear"
        ),
        DailyDua(
            number: 23,
            title: "Sneezers Replies Back",
            arabic: "يَهْدِيكُمُ اللَّهُ وَيُصْلِحُ بَالَكُمْ",
            transliteration: "Yah'deeku-mullaahu wa yuslihu baalakum",
            translation: "May Allah guide you and rectify your condition.",
            benefit: "Abu Hurairah reported the prophet ﷺ as saying:\n\nWhen one of you sneezes, he should say: \"Praise be to Allah in every circumstance,\" and his brother or his companion should say: \"May Allah have mercy on you!\" And he should then reply: \"May Allah guide you and set right your affairs.\"",
            reference: "Sunan Abi Dawud 5033 | Hisn al-Muslim 189",
            iconName: "person.wave.2.fill"
        ),
        DailyDua(
            number: 24,
            title: "For Good Health",
            arabic: "أَسْأَلُ اللَّهَ الْعَظِيمَ، رَبَّ الْعَرْشِ الْعَظِيمِ، أَنْ يَشْفِيَكَ",
            transliteration: "As alullaahal adheem;\nRabbal arshil adheem ;\nAn yash'fiyak.\n\n(Recite seven times)",
            translation: "I ask Almighty Allah, Lord of the Magnificent Throne, to make you well.\n\n(Recite seven times)",
            benefit: "Narrated Abdullah ibn Abbas رضي الله عنه\n\nThe Prophet ﷺ said:\nIf anyone visits a sick whose time (of death) has not come, and says with him (seven times):\nI ask Allah, the Mighty, the Lord of the mighty Throne, to cure you, Allah will cure him from that disease.",
            reference: "Sunan Abi Dawud 3106",
            iconName: "heart.text.square"
        ),
        DailyDua(
            number: 25,
            title: "Cure of any illness",
            arabic: "أَذْهِبِ الْبَأْسَ رَبَّ النَّاسِ، وَاشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا",
            transliteration: "Adh'hibil bah'sa rabban naas;\nWashfi antash shafee;\nLa shifaa'a illah shifa'uk;\nShifaa'an laa yu'gaa-diru saqa'maa.",
            translation: "O Lord of the people, remove this pain and cure it, You are the one who cures and there is no one besides You who can cure, grant such a cure that no illness remains.",
            benefit: "Narrated 'Aisha رضي الله عنها\n\nThe Prophet ﷺ used to treat some of his wives by passing his right hand over the place of ailment and used to say, \"O Lord of the people! Remove the difficulty and bring about healing as You are the Healer. There is no healing but Your Healing, a healing that will leave no ailment.\"",
            reference: "Sahih al-Bukhari 5750",
            iconName: "cross.case.fill"
        ),
        DailyDua(
            number: 26,
            title: "Placing Children under Allah's Protection",
            arabic: "أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ، مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ",
            transliteration: "U'ee dhukuma bi-kalimaatil-lahit-taamma;\nMin kulli shaytaanin wa haam'mah;\nWa min kulli 'aynin laammah.",
            translation: "I seek protection for you in the Perfect Words of Allah from every devil and every beast, and from every envious blameworthy eye.",
            benefit: "Narrated Ibn 'Abbas رضي الله عنه\n\nThe Prophet ﷺ used to seek Refuge with Allah for Al-Hasan and Al-Husain and say: \"Your forefather (i.e. Ibrahim) used to seek Refuge with Allah for Ishmail and Ishaq by reciting the following: 'O Allah! I seek Refuge with Your Perfect Words from every devil and from poisonous pests and from every evil, harmful, envious eye.'\"\nSahih al-Bukhari 3371\n\nIbn 'Abbas رضي الله عنه narrated that the Messenger of Allah ﷺ used to seek refuge for Al-Hasan and Al-Husain saying: \"U'idhukuma bikalimatillahi-tammati,min kulli shaitanin wa hammatin, wa minkulli'ainin lammah...\" And he would say: \"It is with this that Ibrahim would seek refuge for Ishaq and Ismail عليه السلام.\"\nAnother chain reports a similar narration.\nJami' at-Tirmidhi 2060",
            reference: "Sahih al-Bukhari 3371 | Jami' at-Tirmidhi 2060",
            iconName: "shield.fill"
        ),
        DailyDua(
            number: 27,
            title: "Dua for the Parents",
            arabic: "رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ\n\nرَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
            transliteration: "41. Rab'banagh fir'lii wali-waaliday'ya walil mu'mineena yaw'ma yaqoo'mul hisaab.\n\n24. Rabbir ham'huma kamaa rabba yaa'nee saghee'raa.",
            translation: "14:41 Our Lord! Forgive me and my parents, and (all) the believers on the Day when the reckoning will be established.\n\n17:24 My Lord! Have mercy on them both as they did care for me when I was young.",
            benefit: "Narrated Ibn Mas'ud رضي الله عنه\n\nA man asked the Prophet ﷺ \"What deeds are the best?\" The Prophet ﷺ said:\n1. \"To perform the (daily compulsory) prayers at their (early) stated fixed times,\n2. to be good and dutiful to one's own parents,\n3. and to participate in Jihad in Allah's Cause.\"",
            reference: "Quran 14:41 | Quran 17:24 | Sahih al-Bukhari 7534",
            iconName: "heart.fill"
        )
    ]
}
