# Kontent auditi B — 2026-10-09 (11–19-guruhlar va shifokor qo‘llanmasi)

Mustaqil tekshiruvchi (B). Qamrov: `pack.json` guruhlar ro‘yxatidagi 11–19-guruhlar
(autoimmune, tumor-markers, cardiac, iron-vitamins, hematology, coagulation,
stool-parasitology, body-fluids, cytology) — **60 karta**, va barcha **41 `conditions`**
yozuvi. 1–10-guruhlar — A tekshiruvchida. Barcha yozuvlar `draft` / review `pending`
holatida qoldi; bu audit ekspert ko‘rigini almashtirmaydi.

## Usul
1. Kartalar va holatlarda havola qilingan 197 manba ochildi (MedlinePlus, NIH/NCI/NHLBI/
   NIDDK/NICHD, OWH, AHRQ — `curl`; CDC — WebFetch; JSST PDF’lari — IRIS’dan yuklab
   olinib `pdftotext`). Har `locator` sahifada sarlavha sifatida borligi avtomatik tekshirildi.
2. Har bir uch tilli matnda raqamlar uz/ru/en bo‘yicha solishtirildi (avtomatik), so‘ng
   raqamli da’volar manba matni bilan qo‘lda solishtirildi.
3. `decision_limits` (gemoglobin, trombotsitlar, ferritin, transferrin to‘yinishi, B12,
   MMA, folat, koagulyatsiya omillari) va holatlardagi naqsh (pattern) chegaralari manba
   jadvallari bilan solishtirildi; mg/dL → mmol/L hisoblari qayta hisoblandi.
4. Har claim / panel / pattern / caution’da `refs` borligi, `status`/`review` holati.

## Natija: tekshirilgan yozuvlar
| Qism | Soni | Natija |
|---|---|---|
| Kartalar (11–19-guruh) | 60 | Raqam, birlik, probirka, tayyorgarlik — manbaga mos; tuzatish kerak bo‘lmadi |
| `conditions` | 41 | 4 ta yozuvda 5 ta aniqlik tuzatildi (pastda) |
| Locator’lar | barcha | Ochilgan sahifalarda hammasi topildi (JSST PDF’lari va NIDDK “T 4/T 3” subskript farqi bilan) |
| Ref’siz claim | 0 | — |
| `status`/`review` | 101 | Hammasi `draft` / `pending` |

### Alohida tasdiqlangan raqamlar (manba bilan)
- **Gemoglobin (JSST 2024)**: 2-jadval chegaralari (<105 … <130 g/L, homiladorlik I/II/III
  trimestr <110/<105/<110), 3-jadval og‘irlik darajalari, 4–5-jadval balandlik (1000–1499 m:
  8 g/L) va chekish (10–19 dona: 5 g/L) tuzatishlari, 5-persentil izohi — mos.
- **Trombotsitlar (NHLBI)**: <150 000, 100–150 ming yengil, 50–100 ming o‘rtacha,
  <50 ming jiddiy, <20 ming og‘ir, >450 000/µL yuqori; ×10⁹/L hisoblari to‘g‘ri.
- **Koagulyatsiya omillari (CDC/ISTH 2001)**: yengil >5–<40 %, o‘rtacha 1–5 %, og‘ir <1 %;
  me’yor 50–150 %; 2021 ISTH “tashuvchi” atamalari; IX omil 6 oygacha — mos.
- **Ferritin/transferrin (CDC MMWR 1998)**: ≤15 µg/L (anemiyasi bor ayollar), TSAT <16 %
  (sezgirlik 20 %, o‘ziga xoslik 93 %), 1 µg/L ≈ 10 mg zaxira — mos.
- **PSA (NCI)**: >4.0 ng/mL, 2.5/5 ng/mL yoshga bog‘liq misollar, 6–8 hafta, 6–7 % va 25 %,
  USPSTF 55–69/70+ — mos.
- **Orqa miya suyuqligi (MedlinePlus/A.D.A.M.)**: glyukoza 50–80 mg/dL = 2.77–4.44 mmol/L,
  oqsil 15–60 mg/dL = 0.15–0.6 g/L, bosim 90–180 mm suv — manbadagi qiymatlar, “misol,
  laboratoriyaga bog‘liq” deb belgilangan (referens, qaror chegarasi emas).
- **Holatlar**: ADA/NIDDK diabet jadvali (6.5 %, 126, 200; 5.7–6.4 %, 100–125, 140–199
  mg/dL), mmol/L konversiyalari (≈7.0, 11.1, 5.6–6.9, 7.8–11.0; GCT 135–140 → 7.5–7.8),
  NHLBI lipid/metabolik sindrom (HDL 40/50 → 1.0/1.3; non-HDL 130 → 3.4; TG 150 → 1.7;
  bel 40/35 dyuym ≈ 102/89 sm), NIDDK CKD (GFR <60, ≤15; UACR >30 mg/g), NHLBI EF
  (≤40/41–49/≥50 %), NICHD preeklampsiya (140/90, 0.3 g/24 soat, P/K >0.3), CDC HBV/HCV/HIV,
  CDC sifilis algoritmi, T-score (−1.0/−2.4/−2.5) — mos.

## Tuzatishlar (`content_src/additions/conditions.json`)
1. **gestational-diabetes** (monitoring paneli): “tug‘ruqdan taxminan 12 hafta keyin” →
   “tug‘ruqdan keyingi **12 hafta ichida**” (NIDDK: “usually within 12 weeks after
   delivery”). uz/ru/en.
2. **sepsis** (prokalsitonin “biroz ↑” naqshi): manbada “biroz yuqori” daraja — mahalliy
   bakterial yoki boshqa sababli (virusli) infeksiya; “tizimli infeksiyaning erta bosqichi”
   esa “o‘rtacha–biroz yuqori” toifaga tegishli. Ma’no shunga ko‘ra ajratildi. uz/ru/en.
3. **preeclampsia** (og‘ir belgi naqshi): ≥160/110 bosim NICHD’da “kamida 4 soat oraliqda
   ikki marta” sharti bilan — shart qo‘shildi. uz/ru/en.
4. **prostate-psa** (naqsh): “PSA doimiy ↑ yoki tez o‘smoqda → qo‘shimcha test va biopsiya”
   NCI’dagi ikki xil vaziyatni aralashtirgan edi. Endi: “oshishda davom etsa (ayniqsa tez)
   yoki tugun topilsa → qo‘shimcha testlar yoki biopsiya; yuqoriligicha qolsa (oshmasa) —
   takroriy PSA va to‘g‘ri ichak tekshiruvi bilan kuzatuv”. uz/ru/en.
5. **sepsis** (ogohlantirish): “mushtni siqish va jismoniy mashq laktatni vaqtincha
   oshiradi” jumlasining `medline-lactate-test` locator’i noto‘g‘ri bo‘limga (“Is there
   anything else…”) ko‘rsatardi — “What happens during a lactate test?” va “Will I need to
   do anything to prepare for the test?” ga almashtirildi.

Keyin `python3 tool/build_core_pack.py` — `pack.json` va `manifest.json` qayta qurildi.

## Ochiq savollar (ekspert / mahsulot egasi uchun)
1. **NIH ODS fakt varaqlari ochilmadi** (Cloudflare 403, curl va WebFetch). `ods-iron`,
   `ods-folate`, `ods-vitamin-b12` ga tayangan raqamlar (ferritin <30 / <10 µg/L; folat
   >3 ng/mL zardob, >140 ng/mL eritrotsit; B12 200/250 pg/mL = 148/185 pmol/L, 150–399 pg/mL
   = 111–294 pmol/L; MMA >0.271 µmol/L; gomotsistein 16 / 12–14 / >15 µmol/L; B12 zaxirasi
   1–5 mg) ODS’ning ma’lum matniga va pg/mL→pmol/L (×0.738) hisobiga mos keladi, lekin bu
   auditda sahifa bilan bevosita solishtirilmadi — brauzerdan qayta tekshirish kerak.
2. **MedlinePlus Encyclopedia (A.D.A.M.)** sahifalari (`medline-ency-*`: CSF, plevral va
   sinovial suyuqlik, najas yog‘i va rangi, Gram) — davlat public domain matni emas,
   A.D.A.M. litsenziyasi ostida. Matn o‘z so‘zlarimiz bilan, lekin raqamli “misol me’yorlar”
   (CSF, najas yog‘i <7 g/24 soat) shu manbadan. `reuse_rights: verify_before_distribution`
   — tarqatishdan oldin huquqiy tekshiruv.
3. **Metabolik sindrom, glyukoza mezoni**: NHLBI sahifasi “och qoringa ≥126 mg/dL yoki
   dori” deb yozadi (karta shunga mos), NCEP ATP III / IDF mezoni esa ≥100 mg/dL. Ekspert
   qaysi mezonni ko‘rsatishni hal qilsin.
4. **Preeklampsiya, ≥5 g/24 soat proteinuriya** og‘irlik belgisi sifatida NICHD sahifasida
   bor, ammo ACOG 2013+ uni og‘irlik mezonlaridan chiqargan. Manbaga mos qoldirildi — ekspert
   ko‘rsin.
5. **Trombotsitlar**: NHLBI “me’yor 150 000–400 000”, “yuqori >450 000” — 400–450 ming
   oralig‘i manbada aniqlanmagan; kartada faqat manbadagi chegaralar.
6. **CDC hemofiliya, TB, STI, ARF/PSGN, pinworm, DPDx sahifalari** WebFetch orqali
   (xulosa model orqali) tekshirildi, to‘liq matn emas — kalit iboralar iqtibos bilan
   tasdiqlandi.
7. **Mashq savollari** (11–19-guruhga bog‘langan 73 ta): faqat `review_state: pending` va
   `refs` borligi tekshirildi; mazmuni chuqur ko‘rilmadi.
