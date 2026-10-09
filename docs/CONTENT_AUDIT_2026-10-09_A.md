# Kontent auditi 2026-10-09 — A qism (guruhlar 1–10)

Mustaqil tekshiruv. Qamrov: `pack.json` dagi guruhlar ro‘yxatining 1–10-o‘rinlari —
`carbohydrate`, `kidney`, `liver`, `lipids`, `proteins`, `electrolytes`, `enzymes`,
`urine`, `endocrine`, `infection-serology` — jami **59 karta, 558 da’vo**
(11–19-guruhlar ikkinchi tekshiruvchida).

Hech bir karta, da’vo yoki savol tasdiqlanmagan: hammasi `status: draft`,
`content_state: sourced_sample`, `review.state: pending`, `translation_review`
uch tilda `pending` bo‘lib qoldi.

## Qanday tekshirildi

1. **Manba.** 94 ta manbaning har biri ochildi (2026-10-09): MedlinePlus, NIDDK,
   NHLBI, NICHD sahifalari va FDA biotin qo‘llanmasi (PDF) to‘g‘ridan-to‘g‘ri
   yuklab olindi. CDC sahifalari (HBV, HCV, HIV ×2, STI syphilis) avtomatik
   yuklashga 403 qaytardi, shuning uchun ular WebFetch orqali o‘qildi. Har
   da’voning sonlari, birliklari, namuna turi, tayyorgarlik va klinik mezonlari
   ko‘rsatilgan bo‘lim matni bilan solishtirildi.
2. **Locator.** Har bir `refs[].locator` (yoki eski formatdagi `locator`) manba
   sarlavhalari bilan avtomatik solishtirildi. Mos kelmagan 3 tasi qo‘lda
   tekshirildi va manbada borligi aniqlandi: NHLBI kirish xatboshisi va NIDDK
   UACR izohi 1. FDA uchun «II. Background» PDF matnida bor.
3. **RI va DL.** `reference_intervals` 59 kartaning hammasida bo‘sh (testlar
   shuni talab qiladi). `decision_limits` 5 ta kartada bor: glyukoza, HbA1c,
   OGTT, eGFR va UACR. Ularning hammasi rasmiy NIDDK qo‘llanmasidagi diagnostik
   chegaralar. Ularda aholi, izoh va manba bor, `low_exclusive`/`high_exclusive`
   manbadagi «dan ko‘p / dan kam» bilan mos. `analyte_screen.dart` RI va DL ni
   alohida panellarda ko‘rsatadi; har bir DL o‘z bloki, aholisi va manbasi bilan
   chiqadi. RI va DL aralashgan holat topilmadi.
4. **Ref.** 558 da’voning har birida kamida bitta manba va locator bor.
5. **Uch til.** Har bir uz/ru/en matnidagi raqamlar avtomatik solishtirildi.
   Farqlar faqat yozuvdagi farqlar edi: «24-hour» = «суточная», «4 p.m.» =
   «soat 16», kirill «Т4». Uzunlik nisbatlari bo‘yicha qisqarib qolgan tarjima
   topilmadi. Inkor va kuchaytiruvchi so‘zlar bo‘yicha 40 dan ortiq da’vo qo‘lda
   o‘qildi.

## Tuzatishlar

| # | Karta (fayl) | Da’vo | Nima noto‘g‘ri edi | Nima qilindi | Manba |
|---|---|---|---|---|---|
| 1 | `hdl-c` (pack.json) | claims[6], limitations | «Yuqori HDL ba’zi kattalarda foydali bo‘lmasligi mumkin» deb umumlashtirilgan edi. Manbada bu bitta tadqiqot natijasi va u «some Black and White adults» haqida. | Uch tilda «NHLBI keltirgan tadqiqotga ko‘ra, ba’zi qora tanli va oq tanli kattalarda…» deb aniqlashtirildi. | NHLBI, *Blood Cholesterol Causes and Risk Factors* → «Race or ethnicity» |
| 2 | `glucose-plasma-fasting` (pack.json) | decision_limits[0], [1] | DL da faqat `source_ids` bor edi, manbadagi joy (locator) ko‘rsatilmagan edi. | Ikkala DL ga `locator: "Test results for diagnosis of prediabetes and diabetes"` qo‘shildi. Qiymatlar (100–125; ≥126 mg/dL) jadval bilan mos. | NIDDK, *Diabetes Tests & Diagnosis* → jadval |
| 3 | `cortisol` (endocrine.json) | claims[8], low_result | Manbada «most people» deyilgan, kartada esa uzoq davom etgan ikkilamchi yetishmovchilikda kortizol har doim ko‘tarilmaydi degan ma’no chiqardi. Qisqa muddatli ikkilamchi yetishmovchilikda test noaniq bo‘lishi mumkinligi haqidagi cheklov tushib qolgan edi. | Uch tilda «ko‘pchilik odamlarda» qo‘shildi va qisqa muddatli ikkilamchi yetishmovchilik haqidagi cheklov kiritildi. | NIDDK, *Adrenal Insufficiency — Diagnosis* → «ACTH stimulation test» |
| 4 | `insulin` (endocrine.json) | claims[8], limitations | Prediabet testlari (A1C, FPG, OGTT) asosiy bo‘limda emas, «Blood tests» kichik bo‘limida yozilgan. | Ikkinchi ref qo‘shildi: `niddk-insulin-resistance` → `Blood tests`. | NIDDK, *Insulin Resistance & Prediabetes* → «Blood tests» |
| 5 | `pth` (endocrine.json) | claims[4], high_result (ru, uz) | Manbada «parathyroid cancer, which is rare». ru «очень редкий рак», uz «juda kam uchraydigan saraton» deb kuchaytirilgan edi, en esa to‘g‘ri edi. | ru: «редкий рак паращитовидной железы»; uz: «kam uchraydigan paratireoid saraton». | MedlinePlus, *PTH Test* → «What do the results mean?» |
| 6 | `progesterone` (endocrine.json) | claims[3], high_result (ru, uz) | Manbada «may be a sign of an adrenal gland disorder in both females and males». ru/uz da bu qat’iy «повышает / oshiradi» bo‘lib qolgan edi, en esa «can raise» edi. | ru: «может повышать»; uz: «oshirishi mumkin». | MedlinePlus, *Progesterone Test* → «What is it used for?» |
| 7 | `urine-culture` (general_clinical.json) | claims[8], limitations | «Aralash yoki juda oz o‘sishni shifokor belgilar bilan birga baholaydi» degan gap manbada yo‘q edi. | Uch tilda manba matniga qaytarildi: laboratoriyalar orasidagi farq, ba’zan bir nechta bakteriya yoki ularning oz miqdori topilishi, aniq natijani shifokor tushuntirishi. | MedlinePlus, *Urine Culture* (ency 003751) → «Normal Results», «What Abnormal Results Mean» |

Turlari bo‘yicha:
- manbaga nisbatan noaniq yoki manbada yo‘q da’vo: 3 ta (№1, №3, №7);
- tarjimada ma’no kuchaytirilgan (ru/uz ≠ en/manba): 2 ta (№5, №6);
- ref yoki locator to‘liq emas: 2 ta (№2, №4);
- sonlar, birliklar, namuna yoki probirka xatosi: 0;
- RI va DL aralashuvi: 0.

Keyin `python3 tool/build_core_pack.py` ishga tushirildi: pack va manifest
qayta qurildi.

## Ochiq savollar (tuzatilmadi, domla qarori kerak)

1. **`urine-24h` claims[1], [2].** Matnda MedlinePlus «example» qiymatlari bor:
   800–2000 mL/kun, oqsil <100 mg/kun (<10 mg/dL). Ular «laboratoriyaga qarab
   farq qiladi» izohi bilan berilgan. `general_clinical` testi shu formatni
   talab qiladi («sonli me’yorlar faqat matnda»). Shu bilan birga kartaning RI
   panelida «referens interval berilmagan» yozuvi chiqadi. Matnda qolsinmi yoki
   olib tashlansinmi — qaror kerak.
2. **`ogtt` claims[1].** Unda glyukoza-challenge testining chegarasi bor:
   135–140 mg/dL (NIDDK). Bu boshqa testning qaror chegarasi va da’vo matnida
   turibdi. Uni `decision_limits` ga o‘tkazish OGTT natijasi bilan adashtirishi
   mumkin, shuning uchun matnda qoldirildi.
3. **Lipid kartalari.** MedlinePlus va NHLBI «healthy level» va xavfga
   asoslangan LDL maqsadlarini (mg/dL) beradi. Kartalarda ular ataylab yo‘q.
   Ularni `decision_limits` qilib qo‘shish kerakmi? Bu maqsad qiymatlari,
   referens emas, va yosh/jins bo‘yicha bo‘lingan.
4. **`crp`.** Manba «0.8–1.0 mg/dL yoki undan past — sog‘lom» deydi. Kartada
   raqam yo‘q, `units: ["mg/dL"]` bor. Metodga bog‘liq bo‘lgani uchun hozirgi
   holat to‘g‘ri, ammo domla tasdiqlashi kerak.
5. **`related` g‘alati juftliklari.** `ck → urea` va `ldh → ggt` da’vo emas.
   Ammo `ck → creatinine` mantiqan yaqinroq ko‘rinadi.
6. **Manba kolliziyasi.** Homiladorlikdagi OGTT uchun NIDDK «har soatda,
   2–3 soat», MedlinePlus (*Diabetes Tests*) esa «har 30 daqiqada» deydi.
   Kartada neytral «2–3 soat davomida bir necha marta» deb yozilgan.
   `discrepancies[]` ga yozish kerakmi?
7. **CDC sahifalari** avtomatik yuklashda 403 qaytardi va faqat WebFetch
   xulosasi orqali o‘qildi (iqtiboslar tekshirildi). Domla brauzerda bir marta
   ko‘rib chiqishi tavsiya etiladi.
8. **Quiz savollari** (shu guruhlar bo‘yicha 91 ta, hammasi `pending`) bu audit
   doirasida tekshirilmadi.
