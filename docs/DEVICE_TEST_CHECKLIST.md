# Haqiqiy qurilma sinovi uchun ro‘yxat (Android + iOS) — 2026-10-25

**Holat: hamma qator NOT RUN.** Bu sessiyada haqiqiy telefon/planshet bo‘lmagan; sinov o‘tkazilgandek ko‘rsatilmaydi. Quyidagi ro‘yxat sinovchi uchun; natijani `PASS/FAIL/NOT RUN` deb to‘ldiring (`docs/DEVICE_TEST_CHECKLIST.csv`).

**Muhim:** joriy reliz branch’ida (`fix/images-apparatus`) Pro/Premium/to‘lov YO‘Q — hamma funksiya bepul (D-58). Tarif, sinov muddati, billing va Restore qatorlari faqat `pro/tiers-premium` integratsiya qilingandan KEYIN sinaladi (`docs/TIERS_INTEGRATION_PLAN.md`). Kod bo‘yicha sinov muddati 7 kun, 30 emas.

Oldindan: eng so‘nggi build’ni TestFlight/ichki sinov orqali o‘rnating (bu sessiya build chiqarmaydi); 3 til, light/dark, kichik ekran va tizim shrifti ×1.3/×2.0 bilan takrorlang; natija skrinshotlarini biriktiring.

| ID | Soha | Tekshiruv | Kutilgan natija | Android | iOS | Izoh |
|---|---|---|---|---|---|---|
| DEV-001 | Til | Ilova tilini UZ ga o‘tkazing, har 5 tabni oching | Barcha matnlar tanlangan tilda; kesilgan/ustma-ust yozuv yo‘q; uz apostroflari to‘g‘ri (o‘ g‘) | NOT RUN | NOT RUN |  |
| DEV-002 | Til | Ilova tilini RU ga o‘tkazing, har 5 tabni oching | Barcha matnlar tanlangan tilda; kesilgan/ustma-ust yozuv yo‘q; uz apostroflari to‘g‘ri (o‘ g‘) | NOT RUN | NOT RUN |  |
| DEV-003 | Til | Ilova tilini EN ga o‘tkazing, har 5 tabni oching | Barcha matnlar tanlangan tilda; kesilgan/ustma-ust yozuv yo‘q; uz apostroflari to‘g‘ri (o‘ g‘) | NOT RUN | NOT RUN |  |
| DEV-004 | Til | Profil → «Bilim va malakani baholash» sozlamasi (Avtomatik/O‘zbekiston/Yashirish) | Nomi 3 tilda to‘g‘ri («Malaka toifasi» so‘zi yo‘q); «Yashirish» bo‘limni yashiradi | NOT RUN | NOT RUN |  |
| DEV-005 | Til | Bilim va malakani baholash: natijani ulashish | Yozuv aynan «LabGuide mashq natijasi» / «Результат тренировки LabGuide» / «LabGuide practice result» | NOT RUN | NOT RUN |  |
| DEV-006 | Free/Pro/Premium | Hozirgi reliz branch’ida (fix/images-apparatus) hech qanday to‘lov/paywall/obuna ekrani yo‘qligini tekshiring | Profil, sozlamalar, qo‘llanma, bo‘limlarda narx, «Pro», «Premium», «Obuna» yo‘q; hamma funksiya bepul ochiq | NOT RUN | NOT RUN | D-58; test/guards/product_policy_guard_test.dart |
| DEV-007 | Free/Pro/Premium | Pro/Premium integratsiyadan KEYIN: Free foydalanuvchi bloklangan funksiyani ochadi | Paywall faqat gated funksiyada chiqadi; qolgani ochiq | NOT RUN | NOT RUN | Hozir integratsiya qilinmagan — sinov mumkin emas |
| DEV-008 | Free/Pro/Premium | Integratsiyadan KEYIN: Student/Teacher/Specialist/Premium rejalari paywall’da to‘g‘ri ko‘rsatiladi | Faqat tegishli rejalar; narxlar do‘kondan olinadi; 3 tilda mos matn | NOT RUN | NOT RUN | Hozir integratsiya qilinmagan |
| DEV-009 | Sinov muddati | Integratsiyadan KEYIN: bepul sinov boshlanadi (kod bo‘yicha 30 kun — D-80; bir telefonda bir marta) | Sinov tugmasi faqat qurilma tekshiruvi (Play Integrity/App Attest) tayyor bo‘lganda; muddat 30 kun (egasi qarori D-80, 2026-10-31; qurilmada tekshirilmagan) | NOT RUN | NOT RUN | TIERS_AUDIT: hozir 503, tugma yashirin |
| DEV-010 | Sinov muddati | Sinov tugagach: gated funksiya bloklanadi, bepul va saqlangan ma’lumot ochiq qoladi | Ma’lumot yo‘qolmaydi | NOT RUN | NOT RUN |  |
| DEV-011 | Billing | Sandbox xarid (Google Play Billing / StoreKit) — obuna ochilishi | Funksiya ochiladi; server tekshiruvi o‘tadi | NOT RUN | NOT RUN | Do‘kon mahsulotlari va server kalitlari hali yo‘q |
| DEV-012 | Billing | Obuna bekor qilish / muddati tugashi / qaytarish (refund) | Bekor: to‘langan muddat oxirigacha ochiq; tugash/refund: yopiladi | NOT RUN | NOT RUN |  |
| DEV-013 | Billing | Restore Purchases (iOS majburiy) | Qayta o‘rnatilgan ilovada obuna tiklanadi; mehmon uchun xabar | NOT RUN | NOT RUN | Apple 5.1.1 xavfi: mehmon tiklay olmaydi |
| DEV-014 | Offline obuna | Samolyot rejimi: keshlangan huquq ≤7 kun; soatni orqaga surish rad etiladi | Huquq saqlanadi/yopiladi qoidaga ko‘ra | NOT RUN | NOT RUN |  |
| DEV-015 | Kalkulyatorlar | eGFR, anion gap, tuzatilgan Ca, LDL, osmolyarlik va boshqa 17 ta kalkulyatorda namunaviy qiymatlar | Natijalar ilova ichidagi ma’lumotnoma bilan mos; SI/an’anaviy birlik almashinuvi; o‘nli vergul/nuqta to‘g‘ri uz/ru/en | NOT RUN | NOT RUN |  |
| DEV-016 | Kalkulyatorlar | Noto‘g‘ri/bo‘sh/juda katta kiritish | Xato xabari, ilova qotmaydi | NOT RUN | NOT RUN |  |
| DEV-017 | Apparatlar | Yo‘nalish kartasi (GC-MS, VITEK 2, MALDI-TOF, GeneXpert, PCR, ELISA, MGIT) ochiladi | Sxema ravshan, raqamli belgilar o‘qiladi, «aniq model emas» izohi ko‘rinadi, bosilsa kattalashadi | NOT RUN | NOT RUN |  |
| DEV-018 | Apparatlar | Sxemani ikki barmoq bilan zoom/pan | Silliq; sifat 1200 px; planshetda ham | NOT RUN | NOT RUN |  |
| DEV-019 | Apparatlar | «Qismlari va ishlash prinsipi» panelini oching (uz/ru/en) | Raqam bo‘yicha qismlar, prinsip, natija; matn kesilmaydi | NOT RUN | NOT RUN |  |
| DEV-020 | Apparatlar | Model kartasi va hamkor bloki (ko‘rinsa) | Hamkor bloki sahifa pastida; yuklanadi | NOT RUN | NOT RUN |  |
| DEV-021 | Qo‘llanma/video | 16 bo‘limda «Qanday foydalaniladi?» tugmasi, matn 3 tilda, internetsiz | Oyna pastki navigatsiya ostida qolmaydi; qadamlar o‘qiladi | NOT RUN | NOT RUN |  |
| DEV-022 | Qo‘llanma/video | Video tugmasi (hosting ulangandan KEYIN): o‘z tilidagi video ochiladi, hajm ko‘rsatiladi | Hozir videos.json bo‘sh — tugma ko‘rinmasligi KUTILGAN holat | NOT RUN | NOT RUN | Hosting qarori kerak |
| DEV-023 | Qo‘llanma/video | Internet yo‘q holatda video tugmasi | «Internet kerak; matnli qo‘llanma bu yerda» xabari; ilova qotmaydi | NOT RUN | NOT RUN | Hosting kerak |
| DEV-024 | Qo‘llanma/video | 36 MP4 ni haqiqiy telefonda ijro etish (720×1280, subtitrlar o‘qiladi, audio yo‘q) | Subtitr o‘qiladigan, kadrdan chiqmaydi | NOT RUN | NOT RUN | Fayllar videos.zip / lesson_samples_videos.zip |
| DEV-025 | Offline | Samolyot rejimi: asosiy bo‘limlar (kalkulyator, kalibrlash, QC, apparatlar, atlas) | Hammasi ishlaydi; tarmoq talab qiladiganlar halol xabar beradi | NOT RUN | NOT RUN |  |
| DEV-026 | Offline | Oflayn paketni yuklash va uzib qo‘yish | Qisman yuklash buzilmaydi | NOT RUN | NOT RUN |  |
| DEV-027 | Ekran o‘lchami | Kichik telefon (≈320–360 dp): Bosh sahifa, Lab, apparat kartasi, Bilim va malakani baholash, profil | Overflow yo‘q; tugmalar bosiladi; pastki navigatsiya matnni to‘smaydi | NOT RUN | NOT RUN |  |
| DEV-028 | Ekran o‘lchami | Katta telefon (≈430 dp): Bosh sahifa, Lab, apparat kartasi, Bilim va malakani baholash, profil | Overflow yo‘q; tugmalar bosiladi; pastki navigatsiya matnni to‘smaydi | NOT RUN | NOT RUN |  |
| DEV-029 | Ekran o‘lchami | Planshet (≥768 dp): Bosh sahifa, Lab, apparat kartasi, Bilim va malakani baholash, profil | Overflow yo‘q; tugmalar bosiladi; pastki navigatsiya matnni to‘smaydi | NOT RUN | NOT RUN |  |
| DEV-030 | Ekran o‘lchami | Tizim shrifti kattalashtirilgan (×1.3 va ×2.0) | Matn kesilmaydi, skroll ishlaydi | NOT RUN | NOT RUN |  |
| DEV-031 | Mavzu | Yorug‘ va qorong‘i rejim: sxemalar, diagrammalar, mikroskopiya atlasi | Kontrast yetarli; rasm foni to‘g‘ri; skrinshotlar bilan taqqoslash | NOT RUN | NOT RUN |  |
| DEV-032 | Mikroskopiya | Atlas rasmlari yuklanadi va kreditlar (muallif/litsenziya) ko‘rinadi | 65 rasm; staging 31 rasm YO‘Q | NOT RUN | NOT RUN |  |
| DEV-033 | Ma’lumot | Kalibrlash yozuvi saqlash → tarix qatorida tahlil nomi ilova tilida; yozuvni o‘chirish | Xom kod (glucose-plasma-fasting) ko‘rinmaydi; ma’lumot buzilmaydi | NOT RUN | NOT RUN |  |
| DEV-034 | Barqarorlik | Ilovani yopib qayta ochish, fon/old reja, tarmoq o‘zgarishi | Holat saqlanadi; qulash yo‘q | NOT RUN | NOT RUN |  |
| DEV-035 | Android | Android 8 va 14 (eng past/yangi qo‘llab-quvvatlanadigan), orqaga tugma, bildirishnoma ruxsati | Kutilgandek | NOT RUN | — |  |
| DEV-036 | iOS | iOS minimal va oxirgi versiya, dinamik shrift, VoiceOver, TestFlight o‘rnatish | Kutilgandek | — | NOT RUN |  |
