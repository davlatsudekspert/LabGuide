# Video qo‘llanmalar uchun funksiyalar inventari (2026-10-25)

Egasi topshirig‘i (25-okt): “video qo‘llanmalar — halol”. Bu hujjat **faqat haqiqatan ishlaydigan**
funksiyalarni ajratadi: qaysi ekran bor, kim ko‘radi, nimaga server kerak, nima yashirin. Video va
“Qanday foydalaniladi?” matnlari faqat shu jadvaldagi **ishlaydi** holatidagi funksiyalarni ko‘rsatadi.

**Usul.** `lib/app/router.dart` (barcha `GoRoute`lar), bo‘lim ekranlari kodi, mavjud widget/unit
testlar va `docs/APP_MAP_2026-10-18.md` solishtirildi; hub ekranlar
`tool/video/howto_walk_test.dart` bilan (uz/ru/en, yorug‘, 390×844) qayta suratga olindi va ko‘zdan
kechirildi. Pro / to‘lov — ilovada yo‘q va hech qachon chiqarilmagan (D-58,
`test/guards/product_policy_guard_test.dart`), shuning uchun inventarga kiritilmagan.

Holatlar: **ishlaydi** — serversiz, qurilmada ishlaydi; **cheklangan** — ishlaydi, lekin faqat ma’lum
rol/til/mintaqada ko‘rinadi; **server kerak** — server (backend) va hisob bo‘lmasa ekran “mavjud emas”
holatini ko‘rsatadi; **yashirin** — build bayrog‘i bilan o‘chirilgan, do‘kon buildida yo‘q.

Rollar: L — laborant, Sh — shifokor, U — ustoz, T — talaba (rol faqat bosh sahifa va ba’zi kirish
nuqtalarini o‘zgartiradi; Lab bo‘limlari hamma rolga ochiq).

## 1. Lab: ish vositalari

| Funksiya | Manzil | Kim ko‘radi | Holat | Dalil (test / ekran) | How-to |
|---|---|---|---|---|---|
| Kalibrlash yo‘li (apparat → analit → reagent REF / IFU → yo‘riqnoma mosligi → yozuv) | `/lab/calibration` (`?model=`, `?mine=`, `?analyte=`) | Hamma; bosh sahifa plitkasi — L | ishlaydi (oflayn) | `test/widget/calibration_safety_test.dart`, `test/unit/calibration_safety_test.dart`, `CalibrationScreen` | ha |
| Kalibrlash jurnali (lot, qiymatlar, natija, tasdiqlovchi; o‘chirish tarixi) | `/lab/calibration/log`, `/log/:id` | Hamma | ishlaydi (faqat shu qurilmada saqlanadi) | `calibration_safety_test.dart` (saqlash, o‘chirish) | ha (kalibrlash videosi ichida) |
| Sifat nazorati: nazorat to‘plami, seriyalar, Levey–Jennings grafigi, Westgard qoidalari | `/lab/qc`, `/qc/new`, `/qc/set/:id`, `/set/:id/target/:level` | Hamma; L — 1-plitka | ishlaydi (oflayn; zaxira — matn nusxasi) | `test/widget/qc_flow_test.dart`, `test/widget/levey_jennings_chart_test.dart`, `test/unit/qc_rules_test.dart`, `test/unit/qc_test.dart` | ha |
| QC yo‘riqnomalari: EQA (tashqi sifat nazorati), rad etilgan namuna, kritik qiymatlar | `/lab/qc/eqa`, `/qc/rejected`, `/qc/critical` | Hamma | ishlaydi — **faqat tushuntirish**: ilova EQA dasturiga ulanmagan va natija yubormaydi (ekranda shunday yozilgan) | `QcGuideScreen`, `walk_all_screens_test.dart` (`/lab/qc/eqa`) | ha (QC videosida, “tushuntirish” deb) |
| Preanalitika (5 bosqich, bemor tayyorgarligi, probirkalar tartibi, saqlash va tashish) | `/lab/preanalytics` | Hamma; Sh, L — plitka | ishlaydi | `test/unit/preanalytics_test.dart`, `test/widget/books_preanalytics_flow_test.dart` | ha |
| Kalkulyatorlar (17 ta: eGFR, ACR, anion oralig‘i, tuzatilgan kalsiy, LDL, osmolyallik, HbA1c, hisob kamerasi, leykoformula mutlaq sonlari, retikulotsitlar, Light, rang ko‘rsatkichi, Nechiporenko, Kakovskiy–Addis, Zimnitskiy, suyultirish, birliklar) | `/lab/calculators/...` | Hamma | ishlaydi (faqat kiritilgan qiymatdan hisoblaydi) | `test/widget/clinical_calc_test.dart`, `test/widget/manual_calc_test.dart`, `test/unit/clinical_calculators_test.dart`, `test/unit/manual_calculators_test.dart` | ha |
| Apparatlar katalogi (4 yo‘nalish: biokimyo, gematologiya, immunokimyo, siydik; ishlab chiqaruvchi → model kartasi) | `/lab/instruments`, `c/:category(/:maker)`, `m/:id` | Hamma | ishlaydi | `test/widget/instruments_flow_test.dart`, `test/unit/instrument_catalog_test.dart` | ha |
| Laboratoriya yo‘nalishlari (ma’lumotnoma kartalari: sil, OIV, bakteriologiya, … ) | `/lab/instruments/d/:direction`, `lc/:id` | Hamma | ishlaydi (ma’lumotnoma; kartada “platforma va test alohida”) | `test/widget/lab_cards_directions_test.dart`, `test/widget/lab_card_screen_test.dart`, `test/guards/lab_directions_guard_test.dart` | ha |
| Apparat sinfi sxemalari (35 karta, “sxematik tasvir — aniq model emas”) | `lc/:id` ichida | Hamma | ishlaydi | `test/widget/lab_card_schematic_test.dart`, `test/guards/lab_card_schematic_guard_test.dart` | ha (apparatlar videosida) |
| “Ro‘yxatda yo‘q apparatni qo‘shish” (o‘z apparati) | `/lab/instruments`, kalibrlash 1-qadam | Hamma | ishlaydi (qurilmada) | `instruments_flow_test.dart` | ha (qadam sifatida) |

## 2. Lab: bo‘limlar va atlaslar

| Funksiya | Manzil | Kim | Holat | Dalil | How-to |
|---|---|---|---|---|---|
| Leykoformula: hujayralar atlasi, chalkashliklar, hisoblagich (100/200 hujayra, ko‘rmasdan rejim), tarix, talqin, chegaralar, texnika, mashq, baholash | `/lab/differential/...` | Hamma; L — plitka | ishlaydi | `test/widget/differential_flow_test.dart`, `diff_eyes_free_flow_test.dart`, `diff_assessment_flow_test.dart` | ha |
| Sitologiya: hujayralar, daraja, Bethesda, texnika, adekvatlik, reaktiv o‘zgarishlar, yetilish, boshqa, mashq | `/lab/cytology/...` | Hamma | ishlaydi | `test/widget/cytology_test.dart` | ha |
| Spermogramma: JSST 2021 chegaralari, hisoblagich, baholash, atamalar, preanalitika, mashq | `/lab/spermogram/...` | Hamma | ishlaydi | `test/widget/spermogram_test.dart` | ha |
| Qon guruhi: asoslar, usullar, moslik, xatolar, sifat, natijani o‘qish, mashq | `/lab/bloodgroup/...` | Hamma | ishlaydi | `test/widget/bloodgroup_test.dart` | ha |
| Gistologiya: preparatlar, bo‘yoqlar, mashq, mualliflar | `/lab/histology/...` | Hamma | ishlaydi | `test/widget/histology_test.dart` | ha |
| Qon morfologiyasi: normal surtma, eritrotsitlar, trombotsitlar, retikulotsitlar, anemiya, sifat, mashq | `/lab/bloodmorph/...` | Hamma | ishlaydi | `test/widget/bloodmorph_test.dart` | ha |
| Siydik tahlili: yig‘ish, fizik xossalar, test-chiziq, cho‘kma (atlasga havola), natijani o‘qish, mashq | `/lab/urinalysis/...` | Hamma | ishlaydi | `test/widget/urinalysis_test.dart` | ha |
| Koagulogramma: testlar, namuna, natijani o‘qish, DVS, monitoring (mashq yo‘q) | `/lab/coagulogram/...` | Hamma | ishlaydi | `test/widget/coagulogram_test.dart`, `test/unit/coagulogram_logic_test.dart` | ha |
| Najas tahlili va parazitlar (koprologiya): namuna yig‘ish, makroskopiya, koprogramma mikroskopiyasi, yashirin qon, ichak parazitlari (sxema), amaliy protokollar (taqdimot), tahlil kartalari; **bo‘lim mashqi yo‘q** | `/lab/coprology/...` | Hamma | ishlaydi | `test/widget/coprology_test.dart` | ha |
| Mikroskopiya atlasi: siydik cho‘kmasi (14 rasm, 2 ta element uchun rasm hali yo‘q — ekranda ko‘rsatilgan), periferik qon surtmasi, qon parazitlari (bezgak), qidiruv, “Bu nima?” mashqi, mualliflar va litsenziyalar | `/lab/microscopy`, `s/:section`, `i/:id`, `quiz`, `credits` | Hamma; T — plitka | ishlaydi | `test/widget/microscopy_flow_test.dart`, `test/unit/microscopy_atlas_test.dart` | ha |

## 3. O‘rganish

| Funksiya | Manzil | Kim | Holat | Dalil | How-to |
|---|---|---|---|---|---|
| Bilim va malakani baholash: bilim testi (50 savol), mavzu bo‘yicha mashq, og‘zaki bilet (toifa bo‘yicha), xatolar ustida ishlash, rivojlanish, kunlik maqsad va eslatma | `/learn/toifa/...` | hamma til, davlat va rolda ochiq (D-79); faqat Profil → “Bilim va malakani baholash” = “Yashirish” yopadi (redirect `/learn`) | ochiq (ishlaydi) | `test/widget/toifa_test.dart`, `toifa_daily_flow_test.dart`, `toifa_feedback_reveal_test.dart`, `toifa_translation_test.dart`, `test/guards/toifa_real_assets_guard_test.dart` | ha (ru/en videoda ham to‘g‘ridan-to‘g‘ri ko‘rinadi) |
| Kunlik savol (5 ta, izoh va manba bilan; seriya, eslatma) | `/learn/daily` | Hamma (manba: toifa ko‘rinsa — toifa banki, aks holda kontent paketi) | ishlaydi | `test/widget/daily_flow_test.dart`, `test/unit/daily_test.dart` | ha |
| Izohli test (mavzu bo‘yicha mashq, javobdan keyin izoh va manba) | `/learn/quiz`, analit kartasidagi `quiz` | Hamma | ishlaydi | `test/widget/quiz_result_actions_test.dart`, `answer_feedback_reveal_test.dart` | ha |
| Imtihon rejimi (vaqt, mavzular, savollar soni; natija va xatolar) | `/learn/exam`, `run`, `result/:id` | Hamma | ishlaydi | `test/widget/exam_flow_test.dart`, `test/unit/exam_engine_test.dart` | ha |
| Bo‘lim mashqlari (leykoformula, atlas, sitologiya, spermogramma, gistologiya, qon morfologiyasi, siydik, qon guruhi) | har bo‘limda `quiz` | Hamma | ishlaydi | bo‘lim testlari | ha |
| Jadvallar va algoritmlar | `/learn/reference(/:id)` | Hamma | ishlaydi | `test/widget/books_reference_layout_test.dart` | qisqa eslatma |
| Ma’ruza rejimi (tayyor taqdimotlar, mavzu testi) | `/learn/lecture/...` | Hamma | ishlaydi (oflayn) | `test/widget/lecture_*_test.dart`, `topic_test_flow_test.dart` | bu turkumda alohida video yo‘q |
| Guruh va topshiriqlar (ustoz guruhi, QR, topshiriq, natijalar, katta ekran) | `/learn/classes/...` | U, T (va hamma) | **server kerak**: `ClassesGate` — server sozlanmagan bo‘lsa “mavjud emas”, hisobsiz — “kiring” | `test/widget/classes_flow_test.dart`, `classroom_*_test.dart` (soxta server bilan) | **yo‘q** (serversiz ishlamaydi; 2026-10-18 dagi ikki tutorial ham soxta server bilan yozilgan — `docs/TUTORIAL_VIDEOS.md`) |
| Dars rejasi | `/learn/lesson` | Faqat U va admin | ishlaydi | `test/widget/research_draft_test.dart` | yo‘q (bu turkumda emas) |

## 4. Kutubxona, profil, boshqa

| Funksiya | Manzil | Kim | Holat | Dalil | How-to |
|---|---|---|---|---|---|
| Kitob va qo‘llanmalar, PDF o‘quvchi, saqlanganlar, manbalar va litsenziyalar | `/library/...` | Hamma | ishlaydi (ilova ichidagi materiallar) | `test/widget/library_flow_test.dart`, `pdf_reader_test.dart` | qisqa eslatma |
| Oflayn paketlar (yuklab olish, SHA-256 tekshiruvi) | `/library/packs`, `/profile/packs` | Hamma | **tarmoq kerak** (paketlar https manifestdan yuklanadi); yuklangach oflayn | `test/widget/packs_screen_test.dart`, `test/unit/packs_test.dart` (mahalliy soxta server) | storyboard-only (videoda tarmoqsiz ko‘rsatib bo‘lmaydi) |
| Profil: rol, til, mavzu (Klassik / Ivory, yorug‘/tungi), maxfiylik, “Bilim va malakani baholash” ko‘rinishi | `/profile`, `/profile/role`, `/profile/theme`, `/profile/privacy` | Hamma | ishlaydi | `test/widget/theme_test.dart`, `language_picker_test.dart` | ha (boshqa funksiyalar videosida qisqa) |
| Yordam va aloqa | `/profile/help`, `/profile/contact`, `/profile/support` | Hamma | aloqa (email) — ishlaydi; “Taklif va yordam” — server kerak | `test/widget/contact_screen_test.dart`, `support_admin_test.dart` | yo‘q |
| Hamjamiyat (savol-javob) | `/profile/community/...`, bosh sahifa kartasi | Hamma | **server kerak**: `community.available` bo‘lmasa karta umuman ko‘rinmaydi | `test/widget/community_test.dart` (soxta server) | **yo‘q** |
| Hamkor (reklama) UI | `/lab/partners/:id`, `/profile/partnership` | — | **yashirin** (`LG_PARTNER_ADS=false`, do‘kon buildida kompilyatsiyadan chiqarilgan) | `test/widget/partner_ads_flag_test.dart` | **yo‘q** |
| Pro / to‘lov / obuna | — | — | **yo‘q** (o‘chirilgan, hech qachon chiqarilmagan) | `test/guards/product_policy_guard_test.dart` | **yo‘q** |
| Admin konsoli, tekshiruv navbati | `/profile/admin/...`, `/library/review` | Faqat admin / tekshiruvchi | server kerak | `test/widget/admin_*_test.dart` | yo‘q |

## 5. Xulosa

- **Video va how-to uchun yaroqli (serversiz, haqiqiy ekranlar):** Kalibrlash (+jurnal), Sifat nazorati
  (LJ/Westgard; EQA — faqat tushuntirish), Preanalitika, Kalkulyatorlar, Apparatlar va metodikalar
  (katalog, yo‘nalish kartalari, sxemalar), Mikroskopiya atlasi (+mashq), Najas tahlili va
  parazitologiya, Bilim va malakani baholash (ko‘rinish qoidasi bilan), testlar (izohli test, imtihon
  rejimi, kunlik savol, bo‘lim mashqlari), Leykoformula, Sitologiya, Spermogramma, Qon guruhi,
  Gistologiya, Qon morfologiyasi, Koagulogramma, Siydik tahlili, Profil/til/mavzu.
- **Video qilinmaydi (halollik uchun):** Guruhlar/ustoz va Hamjamiyat — server kerak; oflayn paketlar —
  tarmoq kerak; hamkor reklama — yashirin; Pro — yo‘q.
- Mavzu bo‘yicha video rejasi — `docs/video/PLAN.md`; chiqarilgan fayllar — `docs/video/OUTPUTS.md`.
