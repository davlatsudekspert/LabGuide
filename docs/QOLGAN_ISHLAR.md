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
- [ ] Yangi bo'limlar 2-to'lqin: koagulogramma, parazitologiya, koprologiya; 3-to'lqin: IFA, likvor, balg'am
- [ ] Hamkor reklamasi: serverda hamkorlar ko'chirilmagan (hozir faqat test buildlarda namuna)
- [ ] Moderatsiya: bloklash tugmasi uchun serverda `author.ref`, so'z filtri (Apple 1.2)
- [ ] Ma'ruza 1-mavzu ruscha/inglizcha; rasmiy ruscha toifa matni; domla 529 savoli (kalit tasdiqlangach)
- [ ] 45 ta umumiy amaliyot kuni — manbada mavzu yo'q, jadvaldan mavzu kerak
- [ ] Ikki ekranli rejim (TV), tahlil varaqasini rasmdan o'qish (qurilmada), marketing rejasi, rolik (ru/en, sitologiya)
- [ ] Pro/to'lov: faqat to'liq yangi versiya sifatida (kod `pro-later` tarmog'ida; qoidalar egasining xabarida)
