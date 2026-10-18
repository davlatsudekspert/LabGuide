# Qo‘llanma videolari: testni boshlash (ustoz va talaba)

Egasi topshirig‘i (2026-10-18): “2 ta qisqa video — testni qanday boshlash: biri ustoz, biri talaba uchun.”

Ikkala video ham ilovaning **haqiqiy joriy UI**sidan yig‘ilgan (soxta server `FakeLabBackend`, uz, Klassik
mavzu, iPhone 390x844 @3x; katta ekran — 1920x1080). Ovoz yo‘q, o‘zbekcha yozuvlar (Inter), bosiladigan joy —
to‘q sariq doira, o‘tishlar 0,3 s, boshida va oxirida kartochka (`labguide.nfcstore.uz`).

| Video | Davomiyligi | Format |
|---|---|---|
| `labguide_teacher_test.mp4` — “Ustoz: testni boshlash” | 90 s | 1080x1920, H.264, 30 fps, ~6,8 MB |
| `labguide_student_test.mp4` — “Talaba: testga qo‘shilish” | 61 s | 1080x1920, H.264, 30 fps, ~4,7 MB |

2026-10-18 qayta yozildi: cd3ba59 (sinf UX, 9 ta tuzatish) dan keyingi UI — “Guruh va topshiriqlar”
O‘rganish tepasida, rol “Ustoz” bir bosishda ustoz qiladi, guruh sahifasidan «Mavzu testi berish», Test QR /
Katta ekran topshiriq sahifasi tepasida, ustoz natijalarida “Yechmoqda”, QR bilan qo‘shilishda taxallus
so‘raladi, savol ekranida “Muddat: 19-okt 23:59”, natija izohi “…yoki ustoz testni yakunlaganda”.

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
| — | Kartochka | LabGuide — Ustoz: testni boshlash (Guruh → Mavzu testi → QR → natijalar) |
| 1 | Profil → Rol | Profil → Rol: «Ustoz / tadqiqotchi» (Avval email bilan hisobga kiring) · «Davom etish» — hisob ustoz bo‘ladi (Faqat o‘z guruhlaringizni boshqarasiz) |
| 2 | O‘rganish | O‘rganish → «Guruh va topshiriqlar» (Ro‘yxatning eng tepasida) |
| 3 | Guruh va topshiriqlar → Guruh yaratish | «Guruh yaratish» · Guruh nomini yozing → «Guruhni yaratish» |
| 4 | Guruh sahifasi | Guruh tayyor: taklif kodi va QR (Talabalar QR ni skanerlaydi yoki 8 belgili kodni yozadi) |
| 5 | Guruh sahifasi | Talabalar qo‘shildi → «Mavzu testi berish» (Ro‘yxatda taxalluslari bilan) |
| 6 | Mavzu testi berish (`DeckTestPickerScreen`) | Mavzuni qidiring (Faqat testi tayyor mavzular) · Mavzuni tanlang |
| 7 | Guruhga topshirish | Guruh tanlangan — savollar sonini belgilang · 5 ta savol · har talabaga boshqa savollar (Variantli test) |
| 8 | 〃 | Topshirish muddati: «1 kun» · To‘g‘ri javoblar: «Muddat tugagach» (Ball darhol, to‘g‘ri javoblar — keyin) |
| 9 | 〃 | «Topshiriqni berish» · Yuborildi — natijalarni oching («Yuborilgan testlar» qatori) |
| 10 | Topshiriq (ustoz) | Tepada: «Test QR» va «Katta ekran» («Talaba ko‘rinishida sinash» — testni o‘zingiz sinang) · Talabalar skanerlaydi → test darhol ochiladi |
| 11 | Natijalar | Testni ochganlar — «Yechmoqda» (Natijalar har 10 soniyada o‘zi yangilanadi) · Topshirganlar ball bilan ko‘rinadi |
| 12 | Katta ekran | 2 / 3 topshirdi — «Katta ekran» · Katta ekran: jonli reyting (Kim yechmoqda, kim topshirdi) · Hamma topshirdi: 3 / 3 |
| 13 | Topshiriq (ustoz) | «Testni yakunlash» · Tasdiqlang — yangi urinish qabul qilinmaydi · Test yakunlandi — talabalarga javoblar ochildi |
| 14 | Natijalar / katta ekran | Natijalar taqsimoti va eng qiyin savollar · Katta ekranda — birga muhokama qiling |
| — | Kartochka | labguide.nfcstore.uz · Savol va takliflar: ilovada «Yordam va aloqa» |

## Talaba videosi — qadamlar va yozuvlar

| # | Ekran | Yozuv (izoh) |
|---|---|---|
| — | Kartochka | LabGuide — Talaba: testga qo‘shilish (QR → taxallus → test → natija) |
| 1 | O‘rganish | O‘rganish → «Guruh va topshiriqlar» (Avval email bilan hisobga kiring) |
| 2 | Guruh va topshiriqlar | «QR kodni skanerlash» |
| 3 | Skaner | Ustoz ko‘rsatgan QR kodga kamerani qarating (Kod topilishi bilan davom etadi) |
| 4 | Kod bilan qo‘shilish (taxallus so‘rovi) | Birinchi marta: taxallusingizni yozing (Ustoz natijangizni shu nom bilan ko‘radi) · «Qo‘shilish» (Taxallus ixtiyoriy — haqiqiy ism shart emas) |
| 5 | Topshiriq | Test darhol ochildi — «Boshlash» (Savollar soni va muddat ko‘rsatilgan) |
| 6 | Savol | Javobni tanlang (Pastda — topshirish muddati) · So‘ng «Keyingi» · Har bir savolga javob bering |
| 7 | Oxirgi savol | Oxirgi savoldan so‘ng «Yakunlash» · Tasdiqlang — javoblar ustozga yuboriladi |
| 8 | Natija | Ball darhol ko‘rinadi · To‘g‘ri javoblar keyinroq ochiladi (Muddat tugagach yoki ustoz testni yakunlaganda) |
| 9 | Natija (yakunlangach) | Ustoz yakunladi: xatolar tahlili (Sizning javobingiz va to‘g‘ri javob, manbasi bilan) |
| yoki | Kod bilan qo‘shilish | Kamera ishlamasa: «Kod bilan qo‘shilish» · 8 belgili kod + taxallus → «Qo‘shilish» · Guruhda «Taxallusim» — istalgan payt o‘zgartiring (Testni tanlab, «Boshlash») |
| — | Kartochka | labguide.nfcstore.uz |

## Birinchi yozuvda (0b39fbe) topilgan UX muammolari

Quyidagi 9 band cd3ba59 da tuzatildi (batafsil — `docs/BUGS_2026-10-18_IPHONE.md`, 3-bo‘lim; testlar —
`test/widget/classroom_ux_test.dart`); videolar shu tuzatishlardan keyin qayta yozildi. Ro‘yxat tarix uchun
qoldirildi.

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

Qayta yozishda yangi muammo topilmadi (kadrlarda overflow chiziqlari, debug banner yoki eski UI yo‘q).
