# KDL dars rejalari va `curriculum.json` — solishtirish (2026-10-17)

Maqsad: Drive "KDL" papkasidagi dars jadvallari / dastur fayllarini ilovadagi o‘quv dasturi
(`assets/curriculum/curriculum.json`: 864 kredit, 143 kun, 9 modul, 188 mavzu yozuvi) bilan
solishtirish va faqat aniq yangi/aniqroq joyda yangilash.

**Xulosa: `curriculum.json` o‘zgartirilmadi.** To‘rt fayldan uchtasi ilovadagi rejani tasdiqlaydi
yoki shu rejaning boshqa guruhga moslangan (bayram sababli siljitilgan) varianti; to‘rtinchisi
(dastur hujjati) modul soatlarini tasdiqlaydi. Ilovaga kirishi kerak bo‘lgan yangi mavzu, nom
yoki soat topilmadi. Guruhga xos sanalar `sanitize.py` / D-42 qoidasi bo‘yicha asset’ga
**ataylab** kiritilmaydi (kurator ismi, baza, sana — shaxsiy/ichki; ilovada sana ustoz
tanlagan boshlanish kunidan hisoblanadi).

## Ko‘rilgan fayllar (Drive `1EKY5M-lqJqplFgo6XfTJ2MNWbfRRklA8`)

| Belgi | Fayl | Guruh / davr | Kunlar | Eslatma |
|---|---|---|---|---|
| **K** | `1_864_2025_2026_6_oylik_Каримова_Зумрадхон_.pdf` | Z.R. Karimova, 05.01–30.06.2026 | **143** | `curriculum.json` aynan shu jadvaldan olingan |
| **T1** | `дарс жадвали 1. тулик.doc` | D.A. Turg‘unova, 20.02–15.08.2026 (sarlavhada 18.08) | 144 | bayram siljishlari yo‘q, har kun 6 soat |
| **T2** | `дарс_жадвали_тулик_энг_охирги_Тургунова_Д_хайитга_узгаргани.doc` | D.A. Turg‘unova, 20.02–14.08.2026 | 142 | "eng oxirgi, hayitga o‘zgargani" — bayramga moslangan variant |
| **P** | `КЛД_ихтисослаштириш_864_кредит_Тўлиқ_дастур_Печатсиз.doc` | ADTI dasturi, 864 kredit | — | modul jadvali (soatlar), adabiyotlar, attestatsiya tartibi |

K va T2 oxirida bir xil jami qatori bor: "Ma’ruza 138 kredit, amaliy yo‘nalishdagi
mashg‘ulotlar 672 kredit, attestatsiya 54 kredit" (T1 da bu qator yo‘q). Boshqa Drive fayllari
(test banklari `.doc`/`.xlsx`, darsliklar, atlaslar) jadval emas; katta kitoblar yuklanmadi.

## Solishtirish natijasi

### 1. Tartib, nomlar, soatlar (modul bo‘yicha kun raqamlari)

| Modul | `curriculum.json` | K | T1 | T2 |
|---|---|---|---|---|
| M1 | d001–d004 | №1–4 | №1–4 | №1–4 |
| M2 | d005–d009 | №5–9 | №5–9 | №5–9 |
| M3 | d010–d023 | №10–23 | №10–23 | №10–23 (+ №24 ortiqcha kun, pastga qarang) |
| M4 | d024–d034 | №24–34 | №24–34 | №25–35 |
| M5 | d035–d039 | №35–39 | №35–39 | №36–40 |
| M6 | d040–d053 (14 kun) | №40–53 | №40–53 | №41–53 (**13 kun**) |
| M7 | d054–d074 | №54–74 | №54–74 | №54–74 |
| M8 | d075–d089 (15 kun) | №75–89 | №75–89 | №75–88 (**14 kun**) |
| M9 | d090–d143 (54 kun) | №90–143 | №90–**144** (55 kun) | №89–142 |

- Mavzu nomlari va ularning tartibi K bilan `curriculum.json` da **1:1** mos (d001–d143; ma’ruza
  kunlari M9 da d090, 095, 101, 106, 112, 116, 121, 127 ham mos). Manbadagi imlo xatolari
  (`diantologiya`, `axamiyati`, `Ishqoriy fosfotaza`, `Qonnig`, `kassaligi`, `tekshrish`,
  `-GTP`) `curriculum.json` da avvaldan tuzatilgan; uz/ru/en sarlavhalar o‘zgarmagan.
- **Haftalar:** `curriculum.json` dagi `week` (1–26) K jadvalining kalendar haftalariga (05.01
  dushanba boshlanishi, bayram uzilishlari bilan) 143 kunning 143 tasida mos — tekshirildi.
- **Modul soatlari:** `curriculum.json` modul jami 24/30/84/66/30/84/126/90/330 = 864 =
  P jadvalidagi modul soatlari (18/24/78/60/24/78/120/84/324) + har modulga 6 soat attestatsiya.
  Ma’ruza 6/8/26/14/2/12/12/10/48 = 138 (P bilan mos). M9 dagi `extra: 6` K dagi oxirgi
  oltita kun (№137–№142) "6+1" soati bilan izohlanadi.
- Mavzu darajasidagi soatlar (amaliy 4 + ma’ruza 2, yoki 6; attestatsiya 6) K bilan mos.

### 2. Farqlar (faqat boshqa guruh jadvallarida)

**T1 (144 kun).** M1–M8 (№1–№89) bilan bir xil. M9 da bitta qo‘shimcha "Laborator tekshiruv
usullarini amaliyotda o‘zlashtirish" kuni bor (54 ta amaliyot/ma’ruza kuni + №144 yakuniy
attestatsiya 15.08, ADTI TEST MARKAZI); 144 × 6 = 864 soat, K dagi "6+1" o‘rniga. Sanalarda
xato: №137 va №138 — "07.06 / 08.06" (aslida 07.08 / 08.08). Sarlavhada tugash sanasi 18.08,
oxirgi qatorda 15.08.

**T2 (142 kun, bayramga moslangan).** Mavzu to‘plami va modul soatlari bir xil, lekin:
1. **LDG / ishqoriy fosfataza kuni ko‘chirilgan:** K/T1 da bu d050 (M6, "Laktatdegidrogenaza,
   ishqoriy fosfataza fermentlarini tekshirish"); T2 da u №24 (23.03.2026, M3 attestatsiyasidan
   keyin, M4 sarlavhali kundan oldin), M6 esa 13 kun.
2. **Bezgak (d078) alohida kun emas:** T2 №77 (26.05) — "Jinsiy yo‘l bilan yuqadigan
   infeksiyalar… Vasserman. Bezgak kasalligining laborator diagnostikasi" bitta kunda
   (6+2 soat, ma’ruza 2 soat bezgak bo‘yicha); 27.05 (Qurbon hayit) tushib qolgan → M8 14 kun.
3. **+2 soatlik qo‘shimcha blok (13:35–14:55)** №69–№77 va №136–№141 kunlarida ("6+2", "4+2").
4. Sana xatosi: №136 va №137 — "07.06 / 08.06" (aslida 07.08 / 08.08).
5. Tugash 14.08.2026 (№142 attestatsiya). Bayram uzilishlari K dan farq qiladi: 19.03 → 23.03
   (K da 19.03 → 24.03) va 26.05 → 01.06 (K da 26.05 → 30.05).

Moslik jadvali (T2 → `curriculum.json`): №1–23 = d001–d023; №24 = d050 mavzusi (ko‘chirilgan);
№25–50 = d024–d049 (n−1); №51–76 = d051–d076 (n); №77 = d077 + d078; №78–142 = d079–d143 (n+1).

### 3. Nima uchun o‘zgartirilmadi

- K ilovadagi rejaning manbasi; T1 va T2 — boshqa guruh jadvallari: kun soni (144 / 142),
  kalendar sanalari, bazalar va kurator farq qiladi, mavzu mazmuni va soatlar emas.
- T2 dagi siljitish (LDG / ishqoriy fosfataza kuni ko‘chirilgani, bezgak bilan birlashishi) — bayram sababli
  **jadval tuzilmasi**, o‘quv dasturi o‘zgarishi emas; modul soatlari va attestatsiyalar bir xil.
  Dasturda (P) ham shunday mavzu o‘zgarishi yo‘q.
- Guruhga xos aniq sana/hafta (T1, T2) D-42 bo‘yicha asset’ga kiritilmaydi; ilova sana/haftani
  ustoz belgilagan boshlanish kunidan hisoblaydi. Agar T2 kabi "bayramga siljitilgan variant"
  ilovada kerak bo‘lsa, bu alohida qaror (D-42 ni qayta ko‘rish yoki `variants` maydoni) — hozir
  qilinmadi.
- `curriculum.json` modul jadvalidagi `lab`/`seminar` (P da amaliy / laboratoriya ishi / seminar
  ustunlari, sarlavhasi buzilgan) — mavjud `null` qoldirildi: ustun ma’nosi hujjatda aniq emas.

## Tekshirilmagan / cheklovlar

- `.doc` fayllar Drive matn ko‘rinishida o‘qildi (jadval qatorlari to‘g‘ri chiqdi); PDF (K) da
  ayrim qatorlar tartibi buzilgan (sana va mavzu aralashgan) — shu sabab №23–№24 va №36 kabi
  joylar jadvalning boshqa nusxalari (T1/T2) bilan o‘zaro solishtirib o‘qildi, farq yo‘q.
- Jadvallardagi vaqtlar (8:30–13:25 va h.k.) va baza nomlari asset’ga kiritilmaydi.
