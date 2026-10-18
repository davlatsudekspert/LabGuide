# Qolgan ishlar (2026-10-17 kechasi holati)

Shu ro'yxat bo'yicha ketamiz. Bajarilgani `[x]`.

## Hozir ishlayotgan
- [ ] Ma'ruza bo'limida hamma taqdimotlar (98 mavzu + 26 protokol) va qidiruv — yordamchi yozyapti
- [ ] Yangi build: Play internal → TestFlight (65783b3 chiqarilmoqda)

## Egasi qiladigan
- [ ] GitHub: `LG_APPLE_SIGNIN=true`, so'ng `testflight` (kerak bo'lsa `apple_setup=true`)
- [ ] Google Cloud Console: OAuth client ID'lar → `GOOGLE_CLIENT_IDS`, `LG_GOOGLE_CLIENT_ID`, `LG_GOOGLE_IOS_CLIENT_ID` (docs/AUTH_SOCIAL_LOGIN.md)
- [ ] `labguide@nfcstore.uz` ga xat kelishini sinash (Cloudflare Email Routing)
- [ ] Apparat rasmlari: ruxsat xatlari (docs/instrument_permission_emails/) yoki o'z suratlari
- [ ] Domla/mutaxassis: sitologiya, spermogramma, qon guruhi, siydik, qon morfologiyasi, gistologiya, leykoformula baholash
- [ ] App Store Connect: yosh reytingi anketasi, tibbiy qurilma maqomi (Yo'q), DSA, Notes for Review (docs/APPLE_2026_REQUIREMENTS.md)
- [ ] Play Console: "Start rollout", test qiluvchilar; kontakt manzili
- [ ] Ovoz yozish: 4 rolik (talaba, ustoz, shifokor, laborant)
- [ ] Ustoz bilan suhbat natijalari (rejaga qo'shish)

## Men qilaman (navbat)
- [x] Ma'ruza — 16:9 taqdimot ko'rinishi, to'liq ekran (gorizontal so'rovi), to'liq manbalar oynasi, uzun slaydlarni bo'lish, ekranga uzatish (tizim ko'zgusi), taqdimotchi rejimi (D-59)
- [x] Toifa: 50 savollik test — imtihon yoki mashq rejimi (xato darhol), qoralama davom etadi, xatolar raundi; kunlik hisob, seriya, 7 kun, "Bugun" kartasi (hub + bosh sahifa); "ertaga davom etamiz" lokal eslatmasi (standart o'chiq); og'zaki bilet yozmasdan (o'ylash taymeri, asosiy so'zlar ro'yxati, Leitner takrorlash) (D-60)
- [ ] Toifa: haqiqiy qurilmada toifa eslatmasini sinash (Android 13+ ruxsat oynasi, iOS; bosilganda toifa bo'limi ochilishi)
- [ ] Toifa: shifokor roli uchun toifa bo'limi kerakmi — egasi qarori (hozir shifokor/talabaga yopiq, "Bugun" kartasi ham yo'q)
- [ ] Haqiqiy ikkinchi ekran (televizorda slayd, telefonda taqdimotchi): Android `Presentation` / iOS `UIScreen` — native kod va qurilmada sinov kerak (hozir faqat ekran ko'zgusi, D-59)
- [ ] Ma'ruza: tik telefonda slaydni barmoq bilan kattalashtirish (pinch-zoom) — surish bilan to'qnashmasligi kerak
- [ ] **Har mavzudan keyin test** (mavzu testi): ma'ruza oxirida "Mavzu testi", ustoz guruhga bir bosishda topshiradi, natijalar ko'rinadi, xato qilingan savol → tegishli slaydga havola
- [ ] 32 ta mavzuda test savollari yo'q (test_gap) — tekshirilgan kontentdan savollar tuzish (AI loyiha + inson tekshiruvi)
- [x] Yangi bo'limlar 2-to'lqin: koagulogramma (testlar, namuna/sitrat hisoblagichi, PT/APTT o'qish yordamchisi, ISTH DIC bali, monitoring) va koprologiya + parazitologiya (koprogramma elementlari, yashirin qon, boyitish, 7 parazit sxemasi) (D-61)
- [ ] Koagulogramma/koprologiya: mutaxassis (domla) tekshiruvi — keyin "qoralama" belgisini olib tashlash; ISTH 2001 asl maqolasi (Taylor va boshq.) bilan DIC jadvalini solishtirish (bu muhitda ochilmadi)
- [ ] Koprologiya: DPDx yoki boshqa erkin litsenziyali mikrofotolar (har rasm uchun muallif/litsenziya tekshirilsa) — hozir faqat sxema
- [ ] Yangi bo'limlar 3-to'lqin: IFA, likvor, balg'am
- [ ] Hamkor reklamasi: serverda hamkorlar ko'chirilmagan (hozir faqat test buildlarda namuna)
- [x] Moderatsiya: serverda `author.ref` + server bloklari (migratsiya 0011), so'z filtri uz/ru/en (Apple 1.2) (D-62)
- [x] Admin panel: hisobni email bo'yicha o'chirish (o'zi o'chirgandagi yo'l, jurnal); siyosat — email so'rovi 30 kun ichida (D-63)
- [x] Dizayn takliflari 6–7: Toifa kartalari Kunlik karta uslubida (soya, chegarasiz); sinflar yuklanishi — skeleton
- [x] Hamjamiyat qoidalari matniga NCII (intim rasmlar) taqiqi bandi — egasi (Apple 2026-10-16) (`cmRulesC2`, uz/ru/en; qorovul: `test/guards/product_policy_guard_test.dart`)
- [x] Ma'ruza 1-mavzu (d001) ruscha/inglizcha — muallif deckining aynan tarjimasi (`assets/lectures/d001.ru.json`, `d001.en.json`; rasmsiz — rasmlar uz matnli PPTX render, ilova matn shablonida chizadi; ustoz tekshiruvi kerak, qoralama)
- [ ] d001 ru/en uchun PPTX rasmlari (ixtiyoriy: `tool/slides/make_m1.py` ni ru/en ga moslab soffice bilan render)
- [ ] Rasmiy ruscha toifa matni; domla 529 savoli (kalit tasdiqlangach)
- [ ] 45 ta umumiy amaliyot kuni — manbada mavzu yo'q, jadvaldan mavzu kerak
- [ ] Ikki ekranli rejim (TV), tahlil varaqasini rasmdan o'qish (qurilmada), marketing rejasi, rolik (ru/en, sitologiya)
- [ ] Pro/to'lov: faqat to'liq yangi versiya sifatida (kod `pro-later` tarmog'ida; qoidalar egasining xabarida)
