# Sitologiya qo'shimchalari — da'volar va manbalar (qoralama)

17-oktabr, 2026. 6b-blok "Sitologiya qo'shimchalari" va audit (Bethesda ro'yxati).
Hamma matn **qoralama** — mutaxassis (sitolog) tekshiruvi kutilmoqda. Har da'vo shu sessiyada
ochiq to'liq matndan o'qib tekshirildi (Europe PMC / PMC to'liq matni, IARC atlas, Eurocytology,
WSLH, CAP Today). Kod: `lib/features/cytology/cytology_more.dart`, Bethesda —
`cytology_content.dart` (`bethesdaItems`).

## Manbalar

| Kod (`CytoSources`) | Manba |
|---|---|
| `pangarkar2022` | Pangarkar MA. The Bethesda System for reporting cervical cytology. CytoJournal 2022;19:28. doi:10.25259/CMAS_03_07_2021 (PMC9168399) |
| `wang2023` | Wang T, Zhang H, Liu Y, Zhao C. Updates in Cervical Cancer Screening Guidelines, TBS... J Clin Transl Pathol 2023. doi:10.14218/jctp.2023.00004 (PMC10348779) |
| `asccp2019` | Perkins RB va b. 2019 ASCCP Risk-Based Management Consensus Guidelines. J Low Genit Tract Dis 2020. doi:10.1097/LGT.0000000000000525 (PMC7147428) |
| `capToday2026` | O'Conor C, Hegde P, Reynolds J. Cytopathology in focus: Unsatisfactory Paps. CAP Today, 2026 (1-sahifa) |
| `iarcUnsat` | IARC Atlas of Colposcopy and Cytology, A1 — Unsatisfactory specimen |
| `iarcRepair` | IARC Atlas, E1a — Inflammation and repair |
| `kattoor2022` | Kattoor J, Kamal MM. The gray zone squamous lesions: ASC-US / ASC-H. CytoJournal 2022;19:30. doi:10.25259/CMAS_03_10_2021 (PMC9168398) |
| `kamal2022` | Kamal MM. The Pap smear in inflammation and repair. CytoJournal 2022;19:29. doi:10.25259/CMAS_03_08_2021 (PMC9168397) |
| `poflee2022` | Poflee SV, Bhatia JK. Cervical cytology: Radiation and other therapy effects. CytoJournal 2022;19:32. doi:10.25259/CMAS_03_12_2021 (PMC9168396) |
| `kamalTopiwala2022` | Kamal M, Topiwala F. Nonneoplastic cervical cytology. CytoJournal 2022;19:25. doi:10.25259/CMAS_03_06_2021 (PMC9063585) |
| `slhAbnormal` | Wisconsin State Laboratory of Hygiene. Gynecologic Cytology 101: Abnormal (precancerous) lesions |
| `euroReactive` | Eurocytology, Cervical cytology 9b: Reactive cytological changes |
| `wang2023Serous` | Wang M, Chandra A, Cai G. The International System for Reporting Serous Fluid Cytopathology — An Updated Review. J Clin Transl Pathol 2023. doi:10.14218/jctp.2023.00025 (PMC11451941) |
| `wojcik2026` | Wojcik EM. The Paris system for reporting urinary cytology... Histopathology 2026. doi:10.1111/his.70038 (PMC12700038) |
| `dolezal2024` | Dolezal D, Kholová I, Cai G. The WHO Reporting System for Lung Cytopathology — A Review of the First Edition. J Clin Transl Pathol 2024. doi:10.14218/jctp.2023.00068 (PMC11086742) |
| `grigoruk2024` | Григорук ОГ и др. Цитологическая диагностика железистых поражений цервикального канала. Опухоли женской репродуктивной системы 2024. doi:10.17650/1994-4098-2024-20-4-101-110 |

## 1. Bethesda ro'yxati (audit tuzatishi)

| Da'vo | Manba — joyi |
|---|---|
| Bezli toifalar: AGC (endotservikal/endometrial/bezli, NOS), AGC favor neoplastic (endotservikal/bezli), AIS, Adenokarsinoma (endotservikal, endometrial, bachadondan tashqari, NOS) | `pangarkar2022` — "The 2014 Bethesda System", Interpretation/result |
| "Favor neoplastic" — AIS yoki adenokarsinomaga yetmaydi | `wang2023` — "Atypical glandular cells" |
| AGC/AIS: kolposkopiya HPV natijasidan qat'i nazar, endotservikal namuna; atipik endometrial hujayralarda istisno | `asccp2019` — Section G.1 |
| HSIL: shifokor qaror qiladi — kolposkopiya yoki tezlashtirilgan davolash (biopsiyasiz) | `asccp2019` — Major changes, item 3; Section E.3 |
| ASC-US — HPV testi yoki takroriy surtma bilan kuzatish | `wang2023` — ASC-US; `kattoor2022` — Abstract |
| SIL ko'pincha o'z-o'zidan qaytadi | `pangarkar2022` — Introduction |
| ASC-H — kolposkopiya | `kattoor2022` — Management guidelines |
| ru: "атипичные железистые клетки, подозрительные на..." (favor neoplastic) | `grigoruk2024` — rezyume (ru/en parallel: "suspicious for adenocarcinoma (or favor for neoplastic)") |

## 2. Namuna sifati va artefaktlar

| Da'vo | Manba — joyi |
|---|---|
| Yaroqli/yaroqsiz; EC/TZ komponenti va sifat belgilari yoziladi; yaroqsizning 2 turi | `pangarkar2022` — Specimen adequacy; `wang2023` — Specimen adequacy |
| An'anaviy 8 000–12 000, suyuq asosli 5 000 yaxshi ko'rinadigan yassi/metaplastik hujayra | `wang2023` — Specimen adequacy; `capToday2026` — 1-sahifa |
| 2 000 hujayra chegarasi (atrofiya, gisterektomiya, nur/kimyoterapiya); < 2 000 — ko'p hollarda yaroqsiz | `pangarkar2022` — Cellularity; `wang2023`; `capToday2026` |
| TZ komponenti: ≥ 10 yaxshi saqlangan endotservikal yoki yassi metaplastik hujayra | `pangarkar2022` — Endocervical/transformation zone component |
| > 75 % yassi hujayra yopilgan — yaroqsiz; sabab (qon, shilliq, lubrikant, yallig'lanish, artefakt yoki kam hujayra) yoziladi | `wang2023` — Specimen adequacy; `capToday2026` |
| Suyuq asosli preparatda yopuvchi moddalar odatda kamroq muammo | `pangarkar2022` |
| Anomal hujayrali namuna ta'rifga ko'ra yaroqli | `pangarkar2022` — Specimen adequacy |
| Yaroqsiz + HPV yo'q/noma'lum/manfiy → 2–4 oyda takror; HPV triaji tavsiya etilmaydi | `asccp2019` — Section G.2 |
| Qurish artefakti → polixromaziya, to'q yadro, noto'g'ri ASC-US | `kattoor2022` — "ASC-US due to compromised specimen", Fig. 12 |
| Qurigan, qonli, yallig'langan, kam hujayrali surtmalar — yaroqsiz misollari; yallig'lanishda "mahalliy davolashdan keyin takrorlash" | `iarcUnsat` — rasm izohlari (cyt15383, cyto0000, cyto8608, cyto8510, cyto8504, cyto8502, cyto8503) |
| Qattiq qirish → qalin bo'laklar, reaktiv/o'smani farqlash qiyin | `kattoor2022` — ASC-H, hyperchromatic crowded groups |
| Vakuolali degeneratsiya koylotsitga o'xshaydi | `kattoor2022` — "ASC-US due to compromised specimen" |

## 3. Reaktiv o'zgarishlar va atipiya

| Da'vo | Manba — joyi |
|---|---|
| Reaktiv o'zgarishlar (yallig'lanish va repair, limfotsitar servitsit, nur, BIV) — NILM ichida | `pangarkar2022` — Non-neoplastic findings |
| Reaktiv: yadro < 2× oraliq hujayra yadrosi, silliq kontur, mayda och xromatin, yadrocha bo'lishi mumkin, yallig'lanish halosi, titilgan/vakuolali sitoplazma, polixromaziya, "iflos" fon | `kamal2022` — Inflammatory changes in squamous cells |
| ASC-US: yadro maydoni normal oraliq yadrodan 2,5–3× (metaplastik yadrodan ~2×), N/C biroz oshgan, kontur silliq/biroz notekis, xromatin mayda donador bir tekis, yadrocha odatda yo'q | `kattoor2022` — "ASC-US with mature cytoplasm", Summary; `slhAbnormal` — ASC-US ("2½–3 times") |
| Klassik koylotsit → LSIL; to'liq bo'lmagan koylotsitoz → ASC-US; psevdokoylotsitoz sabablari | `kattoor2022` — ASC-US; Differential diagnosis |
| LSIL: g'ayritabiiy katta, to'q yadro; ba'zan ikki/ko'p yadroli | `slhAbnormal` — LSIL |
| Ikki yadrolilik reaktiv jarayonda ham bo'ladi | `kattoor2022` — Summary |
| Repair: tekis qatlam, "sokin" yadro, mayda xromatin, bitta kichik yadrocha, qatlam ichida yallig'lanish hujayralari | `kamal2022` — Fig. 27; `euroReactive` |
| "Atipik repair" ASC-US bo'lishi mumkin | `kattoor2022` — ASC-US in metaplastic squamous cells |
| Nur: erta (6 oy) — hujayra/yadro kattalashadi, N/C saqlanadi, vakuolalar, ko'p yadroli, g'alati hujayralar; kech — atrofiya, g'alati shakl, polixromaziya | `poflee2022` — Acute / Chronic radiation changes |
| Nur o'zgarishlari uzoq saqlanishi mumkin, tirik o'sma hujayralaridan farqlash | `pangarkar2022` — Radiation-induced changes |
| BIV: endometriy hujayralari istalgan kunda; "BIV hujayralari" HSILga o'xshashi; vakuolali bezli hujayralar; Actinomyces | `kamal2022` — IUCD-associated changes; `pangarkar2022` — RCC associated with IUD |
| Shubhada: yosh, oldingi surtmalar, HPV natijasi ko'rib chiqiladi | `kattoor2022` — ASC-US |

## 4. Yetilish indeksi

| Da'vo | Manba — joyi |
|---|---|
| MI — parabazal : oraliq : yuzaki foiz nisbati; faqat yakka hujayralar sanaladi | `kamalTopiwala2022` — Hormonal cytology, MI |
| Yuzaki ustun — estrogen (ovulyatsiya); oraliq ustun — progesteron (lyutein faza, homiladorlik), erta menopauza; parabazal ustun — atrofiya, tug'ruqdan keyin; faqat progestinli kontratseptiv — chapga siljish | `kamalTopiwala2022` — Hormonal cytology; Menopause |
| Shartlar: yallig'lanish/sitoliz yo'q, yaqinda dori yo'q, nur terapiyasi/operatsiya yo'q; qin yon devori surtmasi aniqroq | `kamalTopiwala2022` — Prerequisites |
| Hisoblagich — sof arifmetika (son / jami × 100) | — |

Ataylab yozilmagan: manbadagi "0:35:65" va "90:10:0" misollari (raqamli me'yor sifatida
noto'g'ri tushunilishi mumkin; sikl kuniga bog'liq).

## 5. Boshqa namunalar

| Da'vo | Manba — joyi |
|---|---|
| Parij tizimi 2-nashr: Unsatisfactory, NHGUC, AUC, SHGUC, HGUC; LGUN NHGUC ichiga kiritilgan; asosiy maqsad HGUC | `wojcik2026` — Tables 2–3, TPS 2.0 matni |
| Seroz suyuqliklar xalqaro tizimi (IAC + ASC, 2020): ND, NFM, AUS, SFM, MAL | `wang2023Serous` — Abstract, Table 1 |
| JSST o'pka sitopatologiyasi tizimi (IAC + IARC): 5 toifa | `dolezal2024` — Introduction |
| Balg'am yetarliligi: bir nechta alveolyar makrofag va kiprikli bronx hujayralari, ≥ 2 surtmaga hajm | `dolezal2024` — Insufficient/Inadequate/Non-diagnostic |

## Tekshirib bo'lmadi — shuning uchun yozilmadi

- Bethesda kitobi (Nayar & Wilbur, 2015) va "The Pap test and Bethesda 2014" (Acta Cytol/Cancer
  Cytopathol 2015) — pullik; ma'lumotlar ochiq sharhlar orqali olindi.
- "50–75 % yopilgan bo'lsa xulosaga izoh" (Pathology Outlines) — sahifa ochilmadi (429).
- LSIL uchun raqamli yadro o'lchami (masalan, "> 3× oraliq yadro") — faqat ishonchsiz manbada.
- LSIL yadro qobig'i, yadrocha va fon belgilari — ochiq manbada alohida topilmadi (jadvalda "—").
- Reaktiv o'zgarishlar uchun "1,5–2×" chegarasi — topilmadi; o'rniga Kamal 2022 dagi "< 2×".
- Parij tizimi siydik hajmi (25/30 ml) — sharhda ikki xil jadvalda turlicha; yozilmadi.
- Seroz suyuqlik va o'pka toifalarining xavf foizlari (ROM) — qisqa sharh uchun kiritilmadi.
- Ruscha rasmiy Bethesda 2014 tarjimasi topilmadi; "подозрительные на опухолевые" — Grigoruk 2024
  dagi atamaga yaqin, mutaxassis tasdiqlashi kerak.

## Manbalar orasidagi farq (mutaxassisga)

- Pangarkar 2022 "ikkala preparatda ham minimum 5 000" deydi; Wang 2023 va CAP Today 2026 —
  an'anaviy 8 000–12 000, suyuq asosli 5 000. Ilovada ikkinchisi (Bethesda 2014 bilan mos).
- ASC-US yadro o'lchami: Kattoor 2022 va WSLH — 2,5–3×; Wang 2023 — "2–3 times the area".
  Ilovada 2,5–3×.
