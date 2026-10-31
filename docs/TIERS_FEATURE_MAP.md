# Tariflar xaritasi: egasi ro‘yxati → bugun bepul → Pro delta (D-78, 2026-10-25)

> Tarmoq `paid/feat` (faqat lokal; push, merge, PR, build, deploy, do‘kon/billing API chaqiruvi — **yo‘q**).
> `LG_PRO_ENABLED` standart `false`: bayroq o‘chiq buildda ilova bepul versiya bilan bir xil, Pro kirish nuqtalari
> ko‘rinmaydi. Barcha Pro testlari **soxta do‘kon / soxta server** bilan; haqiqiy App Store / Google Play bilan
> hech narsa sinalmagan (**NOT VERIFIED**).

**Egasi qarori (2026-10-25, D-78).** Bugun `main` (`4b0f057`, do‘kon tekshiruvida) da bor HAMMA narsa bepul va
cheklovsiz qoladi (kunlik limit yo‘q). Egasi ro‘yxatidagi nomlar — mahsulot nomlari; pullik bo‘ladi faqat bugun
YO‘Q, yangi yoki kengaytirilgan qism. Har pullik amal faqat BOSHLANISHIDA tekshiriladi (`requireFeature` /
`runExport` / `ProFeatureGate`), boshlangan amal to‘xtatilmaydi, obuna tugaganda foydalanuvchi ma’lumoti
o‘chirilmaydi va yashirilmaydi (saqlangan natijalarni ko‘rish ochiq). Sinov — 30 kun (D-80; D-76/D-77 dagi 7 kun almashtirildi).

Holatlar: **BUILT_AND_TESTED** — ekran + avtomatik testlar (soxta do‘kon bilan) o‘tadi; **BUILT_PARTIAL** — bir
qismi qurilgan; **NOT_BUILT** — qurilmadi (sabab ko‘rsatilgan). Katalog: `lib/core/entitlements/feature.dart`;
qurilganlari `ProGatePolicy.gated` (`pro_catalog.dart`) da, qurilmagani to‘lov oynasida va’da qilinmaydi.

## 1. Talaba Pro (`learner`)

| Egasi bandi | Bugun bepul (`main`) | Pro delta (bu tarmoq) | Holat |
|---|---|---|---|
| Natijalar tarixi | Har bank ostida “Natijalar tarixi”: barcha natijalar (oxirgi 50), so‘nggi 10 ta grafigi, o‘rtacha/eng yaxshi, har natijada mavzular tahlili (`lib/features/learn/exam_screens.dart` `ExamHistory`, `exam_widgets.dart` `TopicBreakdown`). **O‘zgarmadi, cheklanmaydi** (D-71 dagi “oxirgi 3 ta” bekor). | `Feature.resultsAnalytics` — “Natijalar tahlili” `/learn/results` (`lib/features/pro/results_screens.dart`, mantiq `learner_analytics.dart`): barcha banklar (paket, toifa, boshqa) bo‘yicha to‘liq tarix, bank filtri, umumiy ko‘rsatkichlar va trend (so‘nggi 5 ta − oldingi 5 ta), so‘nggi 20 ta grafigi, mavzular bo‘yicha jamlangan aniqlik va o‘zgarish (eski/yangi yarmi), zaif mavzular (≥ 5 savol, < 60 %). Kirish: bepul tarix ostidagi Pro qatori. | **BUILT_AND_TESTED** — `test/unit/learner_analytics_test.dart`, `test/widget/pro_learner_test.dart` |
| Imtihon simulyatsiyasi | “Imtihon rejimi” (mavzu, son, vaqt tanlanadi, belgilash/orqaga qaytish bor) va toifa testi (rasmiy 50 savol, ixtiyoriy vaqt va chegara) — `exam_screens.dart`, `toifa_screens.dart`. **O‘zgarmadi.** | `Feature.examSimulation` — `/learn/simulation` (`lib/features/pro/simulation_screens.dart`): imtihon sharoiti — vaqt va o‘tish chegarasi MAJBURIY, savollar barcha mavzulardan mutanosib (`drawBalanced`), ketma-ket (xarita, belgilash, orqaga qaytish yo‘q — `ExamRunner` faqat `session.simulation` da), har savolga sarflangan vaqt (`ExamSession.timeAt`), hisobot `/learn/simulation/result/:id`: o‘tdi/o‘tmadi, vaqt, bir savolga o‘rtacha, eng uzoq 5 savol, mavzular, oldingi simulyatsiya bilan farq. Natija oddiy tarixga ham yoziladi. Bank: paket; toifa — faqat toifa ochiq foydalanuvchiga. | **BUILT_AND_TESTED** — o‘sha testlar |
| PDF / CSV eksport | Natija kartochkasini rasm (PNG) sifatida ulashish (`lib/features/share/result_share.dart`) — **o‘zgarmadi**. Fayl eksporti yo‘q. | `Feature.resultsExport` — natijalar tahlili ekranidagi “Eksport: PDF yoki CSV” (`lib/features/pro/results_export.dart`): CSV — sessiyalar va mavzular (UTF-8 BOM, formula in’eksiyasidan himoya), PDF — umumiy ko‘rsatkichlar, zaif mavzular, mavzular jadvali, to‘liq tarix. PDF yozuvchisi tashqi paketsiz (`lib/core/export/pdf_report.dart`, Inter shrifti joylanadi — uz/ru/en matni). Ulashish — mavjud `share_plus` (`lib/features/share/file_export.dart`). | **BUILT_AND_TESTED** — `test/unit/pdf_report_test.dart`, `pro_learner_test.dart` |
| Ustoz bilan ishlanadigan maxsus testlar (talaba tomoni) | Guruhga qo‘shilish, “Ustoz topshiriqlari” kartasi, topshiriqni yechish va ustozga yuborish (`classes_screens.dart`, `classroom/topic_test_screens.dart` `AssignedTestsCard`) — **bepul qoladi**. | `Feature.teacherTests` katalogda bor (faqat Ustoz Pro’da YANGI yaratiladigan maxsus testlar uchun), `gated` da EMAS. | **NOT_BUILT** — maxsus testning ma’lumot modeli va ustoz tomoni (test yaratish) hali yo‘q; ustoz paneli agenti qurgach, shu testlar mavjud bo‘lgandagina ko‘rinadigan kirish nuqtasi ulanadi. Bo‘sh pullik va’da yo‘q. |
| Qo‘shimcha materiallar | Kutubxona (kitoblar, tadqiqotlar, paketlar), ma’ruzalar, atlas — bepul. | Yo‘q — katalogga qo‘shilmadi. | **NOT_BUILT** — egasi “qo‘shimcha materiallar” mazmunini va dasturiy ta’rifini bermagan; mazmun to‘qilmaydi, bo‘sh pullik bo‘lim chiqarilmaydi. Egasidan: qaysi materiallar, kim tayyorlaydi, qaysi tilda. |

## 2. Ustoz Pro (`teacherPanel`) — boshqa agent quradi

| Egasi bandi | Bugun bepul (`main`) | Katalogdagi Pro qator | Holat |
|---|---|---|---|
| Test yaratish | Slayd/mavzu testlari va umumiy test (tayyor savollardan) — topshiriq sifatida berish (`classroom/topic_test_screens.dart`, `general_test_screen.dart`) — bepul qoladi. | `teacherTestBuilder` | **NOT_BUILT** (bu agent doirasida emas — ustoz paneli agenti) |
| Talabalarni biriktirish | Guruhga taklif havolasi / QR, qo‘shilish (`classes_screens.dart`, `invite_link.dart`) — bepul. | `teacherTestAssign` | **NOT_BUILT** (ustoz paneli agenti) |
| Guruhlar | Guruh ochish, a’zolar, reja (`/learn/classes/*`) — bepul (D-71 dagi `groups` yopilishi bekor). | — (bugungi guruhlar pullik emas; kengaytma ta’rifi ustoz agentida) | — |
| Natijalarni boshqarish | Topshiriq natijalari doskasi, talaba natijasi (`/learn/classes/g/:gid/a/:aid/board`, `/s/:uid`) — bepul. | `teacherResults` | **NOT_BUILT** (ustoz paneli agenti) |

## 3. Mutaxassis Pro (`lab`) — professional laboratoriya funksiyalari

| Egasi bandi | Bugun bepul (`main`) | Pro delta (bu tarmoq) | Holat |
|---|---|---|---|
| Laboratoriya bo‘limi (leykoformula, bo‘limlar, koagulogramma, apparatlar, yo‘nalishlar, kalkulyatorlar) | Hammasi bepul (D-76 dagi “Lab — Pro” rejasi, `labGate`, `plannedLabGate` — BEKOR, kod va testlardan olib tashlandi). | — | bepul (regressiya testi: `test/widget/free_features_open_test.dart`) |
| Kalibrlash jurnali | Kalibrlash yo‘li, yozuv yaratish, jurnal, tarix (`instruments/calibration_screens.dart`) — bepul. | `Feature.calibrationExport` — jurnal ekranidagi Pro qatori → CSV (jurnal: har daraja bir qator — apparat, analit, reagent ishlab chiqaruvchi/REF/IFU, kalibrator nomi/loti/yaroqlilik, daraja qiymati va birligi, natija, keyingi QC, yozuv turi, tasdiqlagan va sana, SOP, qo‘llanma versiyasi, eski-yozuv belgisi, izoh; alohida fayl — o‘zgarishlar tarixi) va PDF (`lib/features/pro/calibration_export.dart`). Jurnalda “bajaruvchi (analitik)” maydoni yo‘q — eksportda to‘qilmaydi (faqat “tasdiqlagan”). | **BUILT_AND_TESTED** — `test/unit/lab_pro_export_test.dart`, `test/widget/pro_lab_test.dart` |
| Sifat nazorati (QC) | To‘plamlar, seriyalar, Levey–Jennings, Westgard qoidalari, CSV’ni buferga nusxalash, JSON zaxira (`qc/qc_screens.dart`, `qc_export.dart`) — bepul, o‘zgarmadi. | `Feature.qcReport` — “QC xulosa hisoboti” `/lab/qc/set/:id/report` (`lib/features/pro/qc_report.dart`, `qc_report_screen.dart`): FAQAT saqlangan seriyalardan (`evaluateRuns`) — davr, seriya xulosalari soni, har daraja × lot davri: maqsad x̄ ± SD, kuzatilgan n/x̄/SD (rad etilgan seriyalarsiz, bepul ekran qoidasi), CV, maqsaddan farq (% va SD), ishlagan qoidalar; CSV (xulosa + bepul CSV bilan bir xil seriyalar fayli) va PDF fayl. “Klinik qaror emas” izohi ekranda va har PDF sahifasida. | **BUILT_AND_TESTED** — o‘sha testlar |

## 4. Premium

Premium = Talaba Pro + Ustoz Pro + Mutaxassis Pro (`PlanMatrix`, server `TIER_CAPABILITIES` — o‘zgarmadi, D-76).

## 5. Eshik holatlari (har qurilgan funksiya uchun sinaladi)

| Holat | Natija |
|---|---|
| Bayroq o‘chiq (standart) | Pro qatorlari va yo‘llari yo‘q; bepul ekranlar `main` bilan bir xil |
| Obunasiz (yopiq) | bepul hammasi ochiq; Pro qatori → to‘lov oynasi (faqat shu funksiyani ochadigan rejalar) |
| 30 kunlik sinov / obuna | ochiq |
| Muddati o‘tgan | yangi pullik amal yopiq; saqlangan simulyatsiya hisobotlari va bepul tarix ochiq, hech narsa o‘chmagan |
| Oflayn (imzolangan kesh) | kesh muddati ichida ochiq |
| Mehmon | to‘lov oynasida obuna tugmasi o‘rniga izoh va “Hisobga kirish” (D-76 §5) |
| Obuna amal o‘rtasida tugadi | boshlangan simulyatsiya oxirigacha ishlaydi, hisobot ochiladi |

**Mehmon xaridi (Apple 5.1.1(v)) — TODO (billing agenti):** mijoz hozir `EntitlementService.purchase` ning
`BillingOutcome.signInRequired` javobiga tayanadi. Hisobsiz `learner`/`lab` xaridi kerak bo‘lsa, billing agenti
`EntitlementService` da mehmon xaridi va tiklashni (qurilma tranzaksiyasini huquq sifatida qabul qilish) beradi;
to‘lov oynasi (`purchase_screen.dart`) `ent.source.hasSession` shartini o‘sha API ga almashtiradi. Bu tarmoqda
server/billing o‘zgartirilmadi.
