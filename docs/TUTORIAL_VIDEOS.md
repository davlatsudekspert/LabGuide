# Qo‘llanma videolari: testni boshlash (ustoz va talaba)

Egasi topshirig‘i (2026-10-18): “2 ta qisqa video — testni qanday boshlash: biri ustoz, biri talaba uchun.”

Ikkala video ham ilovaning **haqiqiy joriy UI**sidan yig‘ilgan (soxta server `FakeLabBackend`, uz, Klassik
mavzu, iPhone 390x844 @3x; katta ekran — 1920x1080). Ovoz yo‘q, o‘zbekcha yozuvlar (Inter), bosiladigan joy —
to‘q sariq doira, o‘tishlar 0,3 s, boshida va oxirida kartochka (`labguide.nfcstore.uz`).

| Video | Davomiyligi | Format |
|---|---|---|
| `labguide_teacher_test.mp4` — “Ustoz: testni boshlash” | 90 s | 1080x1920, H.264, 30 fps, ~6,6 MB |
| `labguide_student_test.mp4` — “Talaba: testga qo‘shilish” | 56 s | 1080x1920, H.264, 30 fps, ~4,4 MB |

Videolar repoga qo‘shilmaydi (faqat skriptlar).

## Qayta yig‘ish

```sh
flutter test tool/screenshots/tutorial_teacher_test.dart --update-goldens
flutter test tool/screenshots/tutorial_student_test.dart --update-goldens
python3 tool/screenshots/tutorial_compose.py teacher [--out DIR] [--preview]
python3 tool/screenshots/tutorial_compose.py student [--out DIR] [--preview]
```

- Kadrlar: `tool/screenshots/out/tutorial/<teacher|student>/NN_<qadam>.png` + `frames.json` (har kadrdan keyin
  bosilgan joy, mantiqiy px). Yordamchi: `tool/screenshots/tutorial_helper.dart` (`TutorialWalk`).
- Yozuvlar va har qadam davomiyligi — `tutorial_compose.py` dagi `TEACHER` / `STUDENT` jadvallarida (UI matni
  o‘zgarsa, avval testni qayta yurgizing, so‘ng `--preview` bilan ko‘zdan kechiring).
- Talabalar ustoz videosida boshqa “qurilmadan” ishlaydi (`FakeLabBackend.actAs`): qo‘shilish, boshlash (6–7 daqiqa
  oldin), topshirish. Talaba videosidagi skaner kadri — soxta kamera (`FakeQrCamera.buildPreview`): ustoz
  telefonida ochiq Test QR (haqiqiy havola `inviteUrl(kod, a=topshiriq)`).

## Ustoz videosi — qadamlar va yozuvlar

| # | Ekran | Yozuv (izoh) |
|---|---|---|
| — | Kartochka | LabGuide — Ustoz: testni boshlash (Guruh → test → QR → natijalar) |
| 1 | Profil → Rol | Profil → Rol: «Ustoz» (Avval email bilan hisobga kiring) · «Ustoz»ni tanlab, «Davom etish» |
| 2 | O‘rganish | O‘rganish → «Guruh va topshiriqlar» |
| 3 | Guruh va topshiriqlar | «Guruh yaratish» · Bir marta: ustoz sifatida ro‘yxatdan o‘ting |
| 4 | Guruh yaratish | Guruh nomini yozing → «Guruhni yaratish» |
| 5 | Guruh sahifasi | Guruh tayyor: taklif kodi va QR (Talabalar QR ni skanerlaydi yoki 8 belgili kodni yozadi) · Talabalar qo‘shildi |
| 6 | Ma’ruza rejimi | Testni tanlang: O‘rganish → «Ma’ruza rejimi» · Mavzu ostidagi «Mavzu testi» |
| 7 | Mavzu testi | «Guruhga topshirish» |
| 8 | Guruhga topshirish | Guruh tanlangan — savollar sonini belgilang · 5 ta savol · har talabaga boshqa savollar (Variantli test) |
| 9 | 〃 | Muddat va javoblar qachon ochilishi · Muddat: 1 kun · Javoblar: muddat tugagach (Ball darhol, to‘g‘ri javoblar — keyin) |
| 10 | 〃 | «Topshiriqni berish» |
| 11 | Guruh sahifasi | Guruh sahifasida testni oching |
| 12 | Topshiriq (ustoz) | «Test QR» — talabalarga ko‘rsating · Talabalar skanerlaydi → test darhol ochiladi |
| 13 | Natijalar | Natijalar o‘zi yangilanadi (Har 10 soniyada) · 2 / 3 topshirdi — «Katta ekran» |
| 14 | Katta ekran | Katta ekran: jonli reyting (Kim yechmoqda, kim topshirdi) · Hamma topshirdi: 3 / 3 |
| 15 | Topshiriq (ustoz) | «Testni yakunlash» · Tasdiqlang — yangi urinish qabul qilinmaydi · Test yakunlandi — talabalarga javoblar ochildi |
| 16 | Natijalar / katta ekran | Natijalar taqsimoti va eng qiyin savollar · Katta ekranda — birga muhokama qiling |
| — | Kartochka | labguide.nfcstore.uz · Savol va takliflar: ilovada «Yordam va aloqa» |

## Talaba videosi — qadamlar va yozuvlar

| # | Ekran | Yozuv (izoh) |
|---|---|---|
| — | Kartochka | LabGuide — Talaba: testga qo‘shilish (QR yoki kod → test → natija) |
| 1 | O‘rganish | «O‘rganish» bo‘limini oching (Avval email bilan hisobga kiring) · «Guruh va topshiriqlar» |
| 2 | Guruh va topshiriqlar | «QR kodni skanerlash» |
| 3 | Skaner | Ustoz ko‘rsatgan QR kodga kamerani qarating (Kod topilishi bilan guruhga qo‘shilasiz) |
| yoki | Kod bilan qo‘shilish | Kamera ishlamasa: «Kod bilan qo‘shilish» · 8 belgili kod + taxallus → «Qo‘shilish» (Taxallus ixtiyoriy — haqiqiy ism shart emas) · Guruhda testni tanlab, «Boshlash» |
| 4 | Topshiriq | Test ochildi — «Boshlash» (Savollar soni va muddat ko‘rsatilgan) |
| 5 | Savol | Javobni tanlang · So‘ng «Keyingi» · Har bir savolga javob bering |
| 6 | Oxirgi savol | Oxirgi savoldan so‘ng «Yakunlash» · Tasdiqlang — javoblar ustozga yuboriladi |
| 7 | Natija | Ball darhol ko‘rinadi · To‘g‘ri javoblar keyinroq ochiladi (Muddat tugagach yoki ustoz testni yakunlagach) |
| 8 | Natija (yakunlangach) | Ustoz yakunladi: xatolar tahlili (Sizning javobingiz va to‘g‘ri javob, manbasi bilan) |
| — | Kartochka | labguide.nfcstore.uz |

## Yozib olishda ko‘zga tashlangan UX muammolari

1. **“Guruh va topshiriqlar” birinchi ekranda ko‘rinmaydi.** O‘rganish tabida (ustoz va talaba rolida ham)
   qatorga yetish uchun katta “Molekuladan amaliyotgacha” va “Kunlik savol” kartalaridan pastga surish kerak.
   Ustoz/talaba roli uchun bu qatorni tepaga chiqarish (yoki Bosh sahifadan to‘g‘ridan-to‘g‘ri havola) tavsiya.
2. **Mavzu testini guruh sahifasidan berib bo‘lmaydi.** Guruhdagi «Yangi topshiriq» — oddiy savol banki
   (variant va “javoblar qachon ochiladi” sozlamalari yo‘q). Variantli mavzu testi faqat O‘rganish → Ma’ruza
   rejimi → uzun ro‘yxatdan mavzu → «Mavzu testi» → «Guruhga topshirish» orqali (4–5 bosish + surish). Guruh
   sahifasidagi «Yangi topshiriq» da “Mavzu testi” tanlovi bo‘lsa, ustoz yo‘lni topishi osonlashadi.
3. **“Yuborilgan testlar” qatorini bosish — debug’da Navigator assertion.** «Guruhga topshirish» ekranidagi
   yuborilgan test qatori (`sent-<id>`) bosilganda `'!keyReservation.contains(key)'` (duplicate page key)
   xatosi chiqdi (root navigator ustidagi ekrandan shell ichidagi `/learn/classes/g/../a/..` ga push).
   Videoda guruh sahifasi orqali ochildi; release’dagi xatti-harakatini tekshirish kerak.
4. **Ilova ichidagi QR skaner taxallus so‘ramaydi.** Birinchi marta qo‘shilayotgan talaba darhol qo‘shiladi va
   ustozda faqat tartib raqami bilan ko‘rinadi (D-68 bo‘yicha taxallus ixtiyoriy). Keyin taxallus qo‘yish UI’si
   yo‘q (`setMyAlias` ishlatilmaydi). Taxallusni test boshlashdan oldin yoki guruh sahifasida so‘rash tavsiya.
5. **Vaqt chegarasiz testda “41:09:54” taymeri.** Savol ekranida muddatgacha qolgan vaqt soat:daqiqa:soniya
   ko‘rinishida (41 soat) — talabaga vaqt chegarasi bordek tuyuladi. “Muddat: ertaga 23:59” kabi matn yoki
   faqat oxirgi soatda taymer yaxshiroq.
6. **Ustoz telefonida “yechmoqda” holati yo‘q.** Katta ekranda “Yechmoqda…”, ustozning natijalar jadvalida esa
   o‘sha talaba “Topshirmagan” deb ko‘rinadi.
7. **Talaba natijasidagi izoh to‘liq emas.** “To‘g‘ri javoblar muddat tugagach ochiladi (19/10/2026 23:59)” —
   ustoz testni oldinroq yakunlasa ham ochilishi aytilmagan.
8. **Ustoz bo‘lish — ikki bosqich.** Rol “Ustoz” tanlangach ham guruh yaratishda alohida «Ustoz sifatida
   ro‘yxatdan o‘tish» kerak (rol — faqat bosh sahifa, huquq — server). Tushuntirish bor, lekin birinchi
   foydalanuvchi uchun kutilmagan qadam; rol ekranida “ustoz” tanlanganda bir qatorli eslatma foydali bo‘lardi.
9. **Topshiriq sarlavhasi juda uzun.** “Mavzu testi: Anemiyalar. Klassifikatsiyasi, etiologiyasi va
   patogenezi” ustoz topshiriq sahifasida 4 qator egallaydi va «Test QR» / «Katta ekran» tugmalarini pastga
   suradi (390x844 da ekranning pastki qismida).
