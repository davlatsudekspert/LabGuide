# Mashq savollari auditi 2026-10-09

Mustaqil tekshiruv. `assets/content/core/pack.json` dagi barcha **167 ta savol**
(`quiz`) tekshirildi. Ulardan 71 tasi faqat `pack.json` da, qolgan 96 tasi
`content_src/additions/*.json` bo‘laklarida: `hematology` 46, `endocrine` 16,
`general_clinical` 14, `infection_immuno` 11, `cardio_iron` 9.

Hech bir savol tasdiqlanmadi: hammasida `review_state: pending` qoldi (167/167).

## Qanday tekshirildi

1. **Manba.** Savollarda 115 ta manba ishlatilgan. MedlinePlus, NIDDK, NHLBI va
   NCI sahifalari to‘g‘ridan-to‘g‘ri yuklab olindi. FDA biotin qo‘llanmasi va JSST
   PDF hujjatlari (Hb chegaralari 2024, flebotomiya 2010) `pdftotext` bilan
   o‘qildi. CDC sahifalari avtomatik yuklashga 403 qaytardi, shuning uchun
   WebFetch orqali o‘qildi: HCV, HBV, HIV, sifilis, gemofiliya, ostrisa ×2, DPDx,
   sil, BV, trixomoniaz va MMWR 1998 temir.

   Ikki manba boshqacha o‘qildi:
   - ODS (temir, B12, folat) 2026-10-09 da ikkala yo‘l bilan ham 403 qaytardi.
     Ular shu kuni ertalab boshqa ishchi saqlagan nusxadan o‘qildi.
   - JSST TRS 923 (revmatik isitma) — saqlangan PDF matnidan o‘qildi.

   Har savol uchun to‘g‘ri javob, har bir chalg‘ituvchi variant, izoh va `basis`
   `refs[].locator` bo‘limi matni bilan solishtirildi.
2. **Locator.** Har bir locator manba sarlavhalari bilan avtomatik
   solishtirildi. Topilmaganlari qo‘lda tekshirildi: FDA «II. Background»,
   JSST Table 2, Normative statement 2.a.1/Table 4, WHO 7.1.3 Order of draw.
   Ularning hammasi PDF matnida bor.
3. **Sonlar va mezonlar.** Quyidagilar manba bilan bitta-bitta solishtirildi:
   - glyukoza/OGTT chegaralari (NIDDK jadvali);
   - Hb < 120/130/110 g/L va 1000–1499 m uchun +8 g/L (JSST 2024);
   - trombotsitlar < 20 000/µL — og‘ir (NHLBI);
   - VIII omil < 1 % — og‘ir, ISTH (CDC);
   - transferrin to‘yinishi < 16 % (MMWR);
   - B12 150–399 pg/mL bo‘lsa MMA (ODS);
   - HIV oyna davri 18–45 kun (CDC);
   - PSA 6–8 hafta (NCI);
   - bariy 7–10 kun (DPDx);
   - balg‘am ≥ 3 ta, 8–24 soat oralab (CDC);
   - Amsel 4 tadan 3 tasi, trixomonada 1 soatda 20 % (CDC).

   Referens interval bilan diagnostik chegara yoki davolash maqsadi aralashgan
   savol topilmadi. LDL va xolesterin savollari «maqsad shaxsiy xavfga bog‘liq»
   deb to‘g‘ri yozilgan.
4. **Uch til.** Har maydondagi uz/ru/en sonlari avtomatik solishtirildi.
   Farqlar faqat yozuvda edi: «24-hour» = «суточная», «4 p.m.» = «16 часов»,
   «0,125».

   Keyin 167 savolning hammasi (savol, variantlar, izohlar, basis) ru va uz
   tillarida qo‘lda o‘qildi. Kalit indeksi uch tilda bir xil, chunki u savol
   darajasida bitta. Variantlar tartibi tillar orasida mos.
5. **Yagona javob.** Har savolda ikkinchi to‘g‘ri variant yo‘qligi tekshirildi.
   Hammasida faqat bitta to‘g‘ri variant bor.

## Tuzatishlar

| # | Savol (fayl) | Muammo | Tuzatish | Manba |
|---|---|---|---|---|
| 1 | `pleural-fluid-analysis-q1` (general_clinical) | 2-variant izohidagi «me’yorda 20 ml dan kam tiniq sarg‘ish suyuqlik» manbada yo‘q | Izoh uch tilda manbaga moslandi: me’yorda oz suyuqlik bor, tahlil to‘planib qolgan suyuqlikdan olinadi, loyqa va oqsili yuqori suyuqlik — ekssudat. Ref qo‘shildi | MedlinePlus *Pleural Fluid Analysis* → «What is a pleural fluid analysis?», «What do the results mean?» |
| 2 | `folate-q1` (cardio_iron) | To‘g‘ri variant izohi «B12 tanqisligi qaytmas bo‘lgunicha yashirin qoladi» deb qat’iy aytgan. Manbada esa bu «ayrim mutaxassislar xavotiri, savol hali ochiq» | Uch tilda «ayrim mutaxassislar xavotir bildirgan (masala to‘liq aniqlanmagan)» deb yumshatildi | ODS *Folate* → «Health Risks from Excessive Folate» |
| 3 | `pap-test-q2` (general_clinical) | `basis` «Bethesda» deb boshlangan, lekin keltirilgan NCI sahifasida Bethesda yo‘q | Uch tilda «NCI:» deb o‘zgartirildi va manbadagi ta’rif qo‘shildi | NCI *Abnormal HPV and Pap Test Results* → «Pap test results…» |
| 4 | `urine-24h-q1` (general_clinical) | Yagona manba MedlinePlus Encyclopedia (A.D.A.M., public domain emas) edi | Manba public-domain MedlinePlus lab-test sahifasiga almashtirildi. Savol shu sahifa matniga moslab qayta yozildi: «birinchi siydik unitazga, vaqt yoziladi, 24 soat yig‘iladi, 24-soatdagisi oxirgi porsiya». Kalit o‘zgarmadi (0) | MedlinePlus *Creatinine Test* → «What happens during a creatinine test?» |
| 5 | `urine-culture-q1` (general_clinical) | «Clean catch» uchun A.D.A.M. ensiklopediyasiga ref bor edi | Bu ref public-domain sahifaga almashtirildi. Antibiotikdan soxta manfiy natija haqidagi asosiy ref qoldi (ochiq savollar №1 ga qarang) | MedlinePlus *Nitrites in Urine* → «What happens during a nitrites in urine test?» |
| 6 | `sputum-afb-q2` (general_clinical) | uz izohda inglizcha so‘z qolgan: «smear natijasidan» | «surtma natijasidan» | — |

**Ref to‘liqligi.** 28 savolda chalg‘ituvchi variant izohi faktni keltirilgan
bo‘limdan emas, o‘sha manbaning boshqa bo‘limidan olgan. Bunday hollarda o‘sha
bo‘lim ref sifatida qo‘shildi; matn o‘zgartirilmadi. Har bir yangi bo‘lim
sarlavhasi manbada borligi tekshirildi.

| Savol | Qo‘shilgan ref (manba → bo‘lim) |
|---|---|
| `hba1c-q1` | niddk-a1c → How is the A1C test used to diagnose type 2 diabetes and prediabetes? (och qolish shart emas) |
| `alt-q2` | medline-alt → What do the results mean? |
| `ast-q1` | medline-ast → Will I need to do anything to prepare for the test? |
| `ggt-q2` | medline-ggt → Will I need to do anything to prepare for the test? (ovqatdan keyin GGT pasayadi) |
| `crp-q1` | medline-crp → What is it used for? (virus, autoimmun, chekish) |
| `amylase-q1` | medline-amylase → What is it used for? (qonda siydikdan oldin o‘zgaradi) |
| `potassium-q1` | medline-potassium → Will I need to do anything to prepare for the test? |
| `chloride-q1` | medline-chloride → What is it used for? |
| `triglycerides-q2` | medline-triglycerides → Why do I need a triglycerides test? |
| `calcium-q1`, `calcium-q2` | medline-calcium → Is there anything else I need to know about a calcium blood test? (DEXA) |
| `ft3-q1` | medline-t3 → What is it used for? |
| `hcg-q1` | medline-pregnancy-test → Will I need to do anything to prepare for the test? (ko‘p suyuqlik hCG ni suyultiradi) |
| `insulin-q1` | medline-insulin → What is an insulin in blood test? (diabet tashxisida ishlatilmaydi) |
| `vitamin-d-q1` | medline-vitamin-d → What do the results mean? (D2 ≈ D3) |
| `cea-q1` | medline-cea → Will I need to do anything to prepare for the test? (chekish CEA ni oshiradi) |
| `ca-125-q1` | medline-ca125 → What is it used for? (endometrioz) |
| `afp-q1` | medline-afp-tumor-marker → Is there anything else I need to know about an AFP tumor marker test? |
| `troponin-q1` | medline-ck → What is it used for? (troponin CK dan yaxshiroq) |
| `lipoprotein-a-q1` | medline-lipoprotein-a → What is it used for? (muntazam skrining emas) |
| `hemoglobin-q2` | who-hb-cutoffs-2024 → Normative statement 3 Haemoglobin measurement (venoz qon; kapillyar uchun tuzatish yo‘q) |
| `wbc-count-q2` | medline-wbc-count → What do the results mean? (stress, homiladorlik) |
| `fibrinogen-q2` | medline-d-dimer → What is a D-dimer test? |
| `protein-c-s-q1` | medline-protein-c-s → What are protein C and protein S tests? (varfarin) |
| `hemoglobin-electrophoresis-q1` | medline-hb-electrophoresis → Will I need to do anything to prepare for the test? |
| `fecal-occult-blood-q1` | medline-fobt → What happens during a fecal occult blood test? (siydik aralashmasin) |
| `h-pylori-tests-q1` | medline-h-pylori → What are Helicobacter pylori (H. pylori) tests? (nafas/najas testlari) |
| `pleural-fluid-analysis-q1` | medline-pleural-fluid → What is a pleural fluid analysis? (№1 bilan birga) |

Turlari bo‘yicha:
- javob kaliti noto‘g‘ri yoki ikki to‘g‘ri javob: **0**;
- sonlar, birliklar, namuna turi yoki klinik mezon xatosi: **0**;
- RI va diagnostik chegara yoki maqsad aralashuvi: **0**;
- manbada yo‘q yoki manbaga nisbatan kuchaytirilgan izoh/basis: **3** (№1, №2, №3);
- litsenziya: A.D.A.M. ensiklopediya refi public-domain manbaga almashtirildi: **2** (№4, №5);
- tarjima: **1** (№6);
- ref yoki locator to‘liq emas, ref qo‘shildi: **28** savol (28 ta ref).

Keyin `python3 tool/build_core_pack.py` ishga tushirildi: pack va manifest
qayta qurildi (quiz: 167).

## Testlar

- `flutter test test/unit --concurrency=1` — **400 ta test, hammasi o‘tdi**.
- To‘liq `flutter test` bu ishchida yuritilmadi. Koordinator xotira tanqisligi
  (OOM) sababli uni faqat o‘zi yuritishni buyurdi.

## Ochiq savollar (domla yoki koordinator qarori kerak)

1. **A.D.A.M. (MedlinePlus Encyclopedia) manbalari qoldi.**
   - `csf-analysis-q1` → `medline-ency-csf-glucose` («Normal Results», «What
     Abnormal Results Mean»). Public-domain MedlinePlus *CSF Analysis*
     lab-test sahifasida likvor glyukozasini qon glyukozasi bilan solishtirish
     haqida gap yo‘q.
   - `urine-culture-q1` → `medline-ency-urine-culture` («Considerations»:
     antibiotikdan soxta manfiy natija). NIDDK UTI sahifasida ham bu fakt
     yo‘q.

   Ikkala savolda fakt to‘g‘ri, faqat litsenziya masalasi bor. Variantlar:
   (a) public-domain manba topilguncha savolni olib tashlash yoki
   yashirish; (b) savolni ensiklopediya matnisiz, o‘z so‘zlarimiz bilan va
   faqat fakt sifatida qoldirish (yuridik qaror kerak).
2. **Manbasiz 3 savol** (`dilution-equation`, `unit-factor`,
   `instrument-instructions`; `pack.json`): ularda `refs` yo‘q, faqat bo‘sh
   `source_ids` bor. Mazmuni to‘g‘ri: glyukoza ≈ 18,0 va kreatinin
   ≈ 11,3 mg/dL har 1 mmol/L ga; formula mmol/L = mg/dL × 10 / M. Lekin
   «manbada yo‘q narsa yozilmaydi» qoidasiga ko‘ra ularga manba (masalan,
   NIST SI qo‘llanmasi yoki ishlab chiqaruvchi IFU) yoki «hisoblash/umumiy
   qoida» belgisi kerak.
3. **ODS sahifalari** (`ods-iron`, `ods-vitamin-b12`, `ods-folate`) 2026-10-09
   da avtomatik va WebFetch yo‘li bilan 403 qaytardi. Ular shu kuni ertalab
   saqlangan nusxadan tekshirildi; nashr oldidan qo‘lda qayta ochish kerak.
4. **Umumiy bilimga tayangan chalg‘ituvchi izohlar** manbada so‘zma-so‘z yo‘q,
   lekin to‘g‘ri:
   - «osteoartrit autoimmun emas» (`anti-ccp-q1`);
   - «KOH asosan zamburug‘lar uchun» (`vaginal-wet-mount-q2`);
   - «prealbumin buyrak tekshiruviga kirmaydi» (`urine-acr-q1`);
   - «EChT nospetsifik» (`lymphocytes-q2`);
   - «fluorid probirka glikolizni to‘xtatadi» (`platelets-q2`).

   Kalitga ta’sir qilmaydi, shuning uchun o‘zgartirilmadi.
5. **Atama izchilligi (uz):** NSAID va NYaQV aralash ishlatilgan. Savollarda
   `fecal-occult-blood-q1` da «NSAID», `g6pd-q1` da «NYaQV». Kartalar bilan
   birga bitta atamaga keltirish kerak; bu kartalar auditiga tegishli.
6. **`anti-hcv-q1`** to‘g‘ri variantida «xuddi shu yoki keyingi namunada» deyilgan.
   CDC sahifasi faqat «laboratoriya avtomatik ravishda NAT qiladi» deydi va
   namuna haqida aniq gapirmaydi. Ma’no to‘g‘ri; aniqroq ifodalash mumkin.
