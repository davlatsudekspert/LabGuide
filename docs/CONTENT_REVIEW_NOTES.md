# Kontent — ekspert uchun ochiq savollar

Barcha 35 karta va 71 savol **draft**: mustaqil mutaxassis ko‘rmagan. Quyidagilar
tayyorlash vaqtida alohida belgilangan — tekshiruvda birinchi navbatda ko‘rib chiqing.
Manbalar va qoidalar: [DECISIONS.md](DECISIONS.md) D-19.

## Manbada yo‘q, shuning uchun kartada ham yo‘q
- **Direct (bog‘langan) bilirubin:** MedlinePlus bilirubin sahifasi direct/indirect farqini
  tushuntirmaydi — kartada yuqori/past natija bo‘limi yo‘q. Darslik manbasi kerak.
- **Fruktozamin:** MedlinePlus’da sahifa yo‘q; NIDDK sahifalaridan qisqa ma’lumot, natija
  bo‘limlari va birlik yo‘q.
- **Umumiy siydik tahlili:** MedlinePlus urinalysis sahifasi endi yo‘q (404); karta alohida
  sahifalardan (oqsil, glyukoza, keton, nitrit, bilirubin, urobilinogen, qon, epiteliy,
  kristallar, shilliq) yig‘ilgan. Rang, tiniqlik, solishtirma og‘irlik va pH — yo‘q.
- **Birliklar:** ALT, AST, ALP, GGT, bilirubin, albumin, umumiy oqsil, amilaza, lipaza, LDH,
  CK, siydikchil/BUN, siydik kislotasi, elektrolitlar sahifalarida birlik ko‘rsatilmagan.
- **Gemoliz va kaliy:** MedlinePlus kaliy sahifasi gemolizni aytmaydi; faqat mushtni
  qayta-qayta siqish va qora qizilmiya (licorice) ta’siri bor.

## Manbadagi, lekin ekspert qaroriga qoldirilgan iboralar
- GGT: “odatda GGT qancha yuqori bo‘lsa, jigar shikastlanishi shuncha ko‘p”.
- ALT: “ALT darajasi jigar shikastlanishi qanchalik og‘irligini ko‘rsatmaydi”.
- HbA1c: NIDDK 2018 aniqlik misoli (6.8 % qayta o‘lchanganda 6.4–7.2 %) — eskirgan bo‘lishi
  mumkin.
- OGTT: homiladorlikda qon olish oralig‘i manbalarda farq qiladi (30 daqiqa / 1 soat) — matnda
  faqat “2–3 soat davomida bir necha marta”.
- Siydik ACR: mikro/makroalbuminuriya — NIDDK 2012 qisqa ma’lumotnomasidagi eski atamalar;
  hozirgi tasnif KDIGO A1–A3 (kalkulyatorda).
- eGFR: MedlinePlus’dagi umumiy bandlar (90–100, 60–90, 15–60, < 15) birliksiz va NIDDK bilan
  zid — kiritilmagan.

## Bog‘lanishlar (related)
- LDH → GGT va CK → siydikchil faqat sahifa yon panelidagi “Related Medical Tests”
  havolalaridan; asosiy matnda yo‘q.
- Natriy/kaliy/xlorid → magniy, kalsiy → fosfat va siydik kislotasi, fosfat → eGFR — ham yon
  paneldan.

## Atamalar
- LDH kartasida “(gemoliz)” atamasi qo‘shilgan: sahifa hodisani tasvirlaydi (qon olish va
  tekshirishda eritrotsitlar yorilishi), lekin so‘zni ishlatmaydi.
- O‘zbekcha tibbiy atamalar (masalan, “oshqozonosti bezi”, “buyrak usti bezi”) — o‘zbek tilidagi
  darsliklar bilan solishtirilishi kerak (domla materiallari kelgach).

## 2-sessiya o‘zgarishlari — reviewer e’tibori uchun
- **Tarjima sharhi** bo‘yicha ma’no tuzatishlari: kalsiy (og‘ir kasal *yoki* jarrohlik),
  siydikdagi bilirubin (“erta belgisi bo‘lishi mumkin”), yassi epiteliy va kristallar
  (“bo‘lishi mumkin”), ruscha “натощак” faqat manbada “fasting” bo‘lgan joylarda.
- **Mashq noto‘g‘ri variantlari** (D-31): 40 savoldagi 76 variant uzunlik bo‘yicha
  muvozanatlash uchun qayta yozildi; to‘g‘ri variantlar va manbalar o‘zgarmagan. 4 ta izoh
  moslashtirildi: `bilirubin-direct-q1` (1), `crp-q1` (2), `cholesterol-total-q1` (2),
  `hdl-c-q1` (0). Qisqa qoldirilgan: `sodium-q1` “Diabetes insipidus”, `potassium-q2`
  “Addison disease” (uzaytirish noaniqlik tug‘dirardi).
- **Hisoblangan mmol/L** (glyukoza, OGTT): manbada faqat mg/dL; ekranda “hisoblangan” deb
  belgilangan va izoh bor — reviewer yaxlitlashni (1 kasr) tasdiqlashi kerak.
- Fruktozamin (`niddk-a1c`) va ALT (`medline-ast`) kartalaridan hech bir da’voda
  keltirilmagan manbalar olib tashlandi.

## Gormonlar (16 karta, `content_src/additions/endocrine.json`) — reviewer uchun
- **Manbada yo‘q, kartada ham yo‘q:** TSH uchun kun vaqti talabi (MedlinePlus TSH
  sahifasida yo‘q); birliklar (mIU/L, pmol/L va h.k.) — sahifalarda ko‘rsatilmagan;
  referens oraliqlar va D vitamini toifalarining raqamlari; anti-TPO uchun “musbat”
  chegarasi. NIH ODS D vitamini sahifasi (25(OH)D jadvali bilan) avtomatik so‘rovga 403
  qaytardi — ishlatilmadi.
- **FT3:** MedlinePlus’ga ko‘ra mutaxassislar *umumiy* T3 ni aniqroq deb hisoblaydi — kartada
  ochiq yozilgan; karta nomi topshiriqdagidek “erkin T3”.
- **hCG:** MedlinePlus’da miqdoriy hCG uchun alohida public-domain lab-test sahifasi yo‘q
  (`/lab-tests/hcg-blood-test-quantitative/` — 404; ensiklopediya maqolasi A.D.A.M.
  mualliflik huquqida) — karta “Pregnancy Test” sahifasi va NICHD’dan.
- **Biotin:** FDA qo‘llanmasi umumiy (“hormone tests”); qaysi reagent ta’sirlanishi IFU’da —
  13 ta gormon kartasida bir xil da’vo. Anti-TPO, C-peptid va D vitaminida yo‘q (manba
  ularni nomlamaydi).
- **Tarjima atamalari tekshirilsin:** “Lyuteinlovchi gormon”, “Follikulani stimullovchi
  gormon”, “tireoperoksidazaga antitanalar”, “pufakli ko‘chish” (molyar homiladorlik),
  “buyrak usti bezining tug‘ma giperplaziyasi (BUTG)”, “alkogolga ruju”, “Greyvs/Xashimoto
  kasalligi”.
- **Bog‘lanishlar:** TSH↔FT4/FT3/anti-TPO, PTG→kalsiy/fosfat/D vitamini, D vitamini→PTG/kalsiy, insulin↔C-peptid/
  glyukoza/HbA1c, prolaktin→TSH (gipotireoz prolaktinni oshiradi), hCG→TSH/FT4 (NIDDK:
  homiladorlikda o‘lchanadigan qalqonsimon bez gormonlari oshadi), kortizol→glyukoza/insulin/
  C-peptid (Kushing sindromi). Mavjud kartalardan gormonlarga teskari havola qo‘shilmadi
  (mavjud yozuvlar o‘zgartirilmadi).
