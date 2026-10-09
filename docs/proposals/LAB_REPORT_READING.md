# Taklif: tahlil natijasi rasmini o‘qish va Pro versiya

Holat: **taklif** (egasining qarori kerak). Sana: 2026-10-09.

## 1. Natija varaqasini rasmga olib o‘qish

Foydalanuvchi (bemor, shifokor, talaba) laboratoriya natija varaqasini suratga oladi →
ilova analit nomi, qiymat, birlik va **varaqadagi referens oralig‘ini** ajratadi → har
qatorni LabGuide kartasiga bog‘laydi ("bu tahlil nima", "yuqori/past bo‘lishi nimani
anglatishi mumkin", manbalar) → "shifokor bilan muhokama qiling" eslatmasi.

### Variantlar

| | A. Qurilmada (on-device OCR) | B. Server orqali AI (tavsiya) |
|---|---|---|
| Qanday | iOS Vision / Android ML Kit matnni taniydi, ilova jadvalni o‘zi tahlil qiladi | Rasm Supabase Edge Function’ga, u Claude (vision) API’ga yuboradi, tuzilgan JSON qaytadi |
| Tillar | ML Kit — faqat lotin (rus kirilli yo‘q); iOS Vision — rus tilini taniydi | O‘zbek (lotin/kiril), rus, ingliz — aralash varaqalar ham |
| Aniqlik | Jadval/ustunlar ko‘p xato beradi (qo‘l yozuvi, qiyshiq rasm) | Yuqori; jadval tuzilmasini tushunadi |
| Maxfiylik | Rasm qurilmadan chiqmaydi | Rasm serverga boradi: rozilik, saqlanmaydi, shifrlangan, PHI eslatmasi |
| Narx | Bepul | Har o‘qish uchun API to‘lovi (taxminan bir necha sent) — Pro funksiya bo‘lishi mantiqiy |
| Kerak | — | Anthropic API kaliti (faqat serverda, ilovada emas), Supabase loyihasi |

**Tavsiya:** B (Pro), A — zaxira/oflayn rejim sifatida keyin.

### Xavfsizlik va qoidalar
- Ilova **tashxis qo‘ymaydi**: natijani kartaga bog‘laydi va umumiy ma’lumot beradi;
  referens sifatida **varaqadagi laboratoriya oralig‘i** ishlatiladi (bizning raqam emas).
- Rasmda bemor ismi bo‘lsa — yuborishdan oldin kesish (crop) taklif qilinadi; serverda rasm
  saqlanmaydi, faqat javob qaytariladi; jurnalda rasm yo‘q.
- Rozilik oynasi: "Rasm tahlil uchun serverga yuboriladi va saqlanmaydi".
- Tibbiy dasturiy ta’minot sifatida tasniflanish xavfi (SaMD) — "o‘quv/ma’lumot" doirasida
  qolish, tashxis/davolash tavsiyasi bermaslik; huquqiy tekshiruv tavsiya etiladi.

### Ishlash rejasi (qaror qabul qilingach)
1. Edge Function `read-lab-report` (API kaliti secret’da), cheklov (kuniga N ta), hajm ≤ 5 MB.
2. Ilovada "Natijani rasmga olish" (kamera/galereya → kesish → rozilik → natija ro‘yxati →
   har qator kartaga bog‘langan; bog‘lanmagan qatorlar "kartasi yo‘q" deb ko‘rsatiladi).
3. Sinov: sun’iy (o‘zimiz yaratgan, real bemorsiz) varaqalar to‘plami bilan aniqlik o‘lchovi.

**Egasidan kerak:** variant tanlovi; Anthropic API kaliti (yoki boshqa provayder); Pro narxi.

## 2. Pro versiya (pullik) — taklif

| Bepul | Pro |
|---|---|
| Tahlil kartalari (draft belgisi bilan), qidiruv, kalkulyatorlar | Natija rasmini o‘qish (AI) |
| Apparatlar katalogi, kalibrlash yo‘riqnomasi | Kalibrlash va QC jurnalini eksport (PDF/CSV), cheksiz apparat |
| Mashq savollari (cheklangan) | Imtihon rejimi to‘liq, natijalar tarixi |
| Mikroskopiya atlasi (ko‘rish) | "Bu nima?" mashqi to‘liq, oflayn qo‘shimcha paketlar |
| Taklif va yordam | Ustoz uchun guruhlar (cheksiz talaba), kutubxona PDF |

StoreKit / Google Play Billing va server tekshiruvi (kvitansiya) ulanishi kerak; narx va
bepul sinov muddati — egasining qarori. Admin panelda Free/Pro soni billing ulangach chiqadi.
