# D-72. Pro — taklif (FAQAT TAKLIF; hech narsa yoqilmaydi, billing/paywall/server faol emas)
> **D-73 (2026-10-24) bilan YANGILANDI.** C va G bo'limlardagi narxlar/tariflar ESKIRDI: egasi uch darajani va narxlarni
> belgiladi (OWNER-DECIDED, lekin ENABLED EMAS) — Talaba 1.49/9.99, Ustoz 2.49/24.99, Mutaxassis 3.49/34.99 (USD,
> oylik/yillik). Admin tomonidan Pro berish ham D-73 da. Qolgan bo'limlar (A, B, D, E, F, H, I, J) hali kuchda va ochiq
> qarorlar ro'yxati D-73 §5 da. Hech narsa deploy qilinmagan yoki yoqilmagan.
Mavjud holat: `pro-next` (pushed, main'dan alohida), `proEnabled=false`, narxlar ma'lumot sifatida taklif, `freeTrialDays=null`, hech nima gate qilinmagan, D-71 da 10 ta ochiq qaror. Eski D-49 (7/14 kun), D-48/D-57 narxlari ESKIRGAN.

## A. Bepul foydalanuvchi huquqlari (bugungi main = «bepul kafolat»)
Quyidagilar main'da bepul va Pro tufayli QISQARMASLIGI taklif qilinadi (egasi tasdiqlashi kerak):
leykoformula, kalkulyatorlar, preanalitika, QC, kalibrovka jurnali, apparat katalogi + TB/OIV ma'lumotnomalar, atlas va mikroskopiya, kartalar, kunlik savollar, ustoz-talaba testi (guruh, QR, topshiriq, natijalar), umumiy test, toifa (D-40 doirasida), foydalanuvchi o'z ma'lumotini eksport/o'chirish, hisobni o'chirish.
Savol: «mavjud foydalanuvchilar hozirgi imkoniyatni saqlaydimi» — tavsiya: HA (grandfather), Pro faqat YANGI qo'shimcha imkoniyatlar (masalan: cheksiz xotira/eksport, ilg'or tahlil, jamoa panellari) uchun.
## B. Pro nima beradi (nomzod ro'yxat — tanlov egasiniki; hozir kodda hech biri yopilmagan)
Talaba / Oddiy / Ustoz bosqichlari: tavsiya qilingan farqlar (tasdiqlanmagan): Ustoz — katta guruh/ko'p topshiriq/hisobot eksporti; Oddiy — cheksiz mashq tarixi, imtihon simulyatsiyasi; Talaba — Oddiy huquqlari past narxda (talaba tasdig'i).
## C. Narxlar — D-73 bilan almashtirildi (OWNER-DECIDED 2026-10-24, ENABLED EMAS)
| Daraja | Oylik USD | Yillik USD | UZS |
|---|---|---|---|
| Talaba | 1.49 | 9.99 | do'kon narx nuqtasi (ochiq qaror) |
| Ustoz | 2.49 | 24.99 | do'kon narx nuqtasi (ochiq qaror) |
| Mutaxassis | 3.49 | 34.99 | do'kon narx nuqtasi (ochiq qaror) |
Qoida: narx ilovaga qotirilmaydi, do'kondan olinadi (D-plan 0.5). Hududiy narxlar: do'konning o'z narx jadvalidan.
Oldingi taklif (Talaba/Oddiy/Ustoz, yillik yo'q) bekor qilindi: «Oddiy» → «Mutaxassis».
## D. 30 kunlik bepul foydalanish — ikki variant (tanlov egasida)
1. **Do'konning o'z introductory offer'i** (Apple free trial / Google free trial): serverga tegmaydi, do'kon qoidalari (bir akkauntga bir marta), eng kam xavf; kamchilik: karta kerak, muddat do'kon beradigan variantlar bilan cheklangan (Apple 30 kun ruxsat etilgan).
2. **Server beradigan 30 kun** (ro'yxatdan o'tgach avtomatik): karta shart emas, o'zbek bozori uchun qulay; kamchilik: suiiste'mol (qayta ro'yxat), server tekshiruvi, hisob shartligi (mehmon uchun ishlamaydi), Apple 3.1.2 shaffoflik talablari.
Tavsiya: avval 1-variant; 2-variant faqat egasi hisob/anti-fraud qoidalarini tasdiqlasa. `freeTrialDays` o'zgaruvchisi bor, mexanizm yo'q.
## E. Do'kon va huquqiy talablar (hali YO'Q)
Obuna matni (shartlar, maxfiylik, Data safety), «Restore purchases», bekor qilish yo'riqnomasi, narx va davr ekranda, hisobni o'chirish bilan obuna aloqasi, Apple 3.1.1/3.1.2, Google obuna siyosati, talaba tasdig'i, referral, regional narx. Plagin Play BILLING ruxsatini manifestga qo'shadi → **bepul relizlar faqat main'dan**.
## F. Bepul relizga xavf yo'q qoidalari
`proEnabled=false` qorovul, `product_policy_guard`, pro-next→main faqat egasi yozma ruxsati bilan, mehmon xaridi (eski kodda mehmon sotib ola oladi — qaror kerak), mavjud foydalanuvchilar huquqini kamaytirmaslik testi.

## G. Yillik tarif — D-73 da HAL QILINDI
Yillik narxlar egasi tomonidan belgilandi (C bo'lim); kodda `yearlyUsd` qiymatlari bor, yillik mahsulotlar ro'yxatda
(`annualOffered`), lekin Pro bayrog'i o'chiq bo'lgani uchun hech narsa ko'rinmaydi. Oldingi variantlar (10x/8x) bekor.
## H. Pullik funksiyalar — nomzod ro'yxat (hech biri yopilmagan; `ProGatePolicy.gated` bo'sh)
Faqat YANGI qo'shimcha imkoniyatlar bo'lishi mumkin: natijalar va hisobotlarni eksport (PDF/CSV), kengaytirilgan tahlil paneli (ustoz), katta guruh/ko'p topshiriq limiti oshishi, cheksiz imtihon simulyatsiyasi tarixi, oflayn paketlar. Bugun bepul bo'lgan hech narsa pullikka o'tkazilmaydi (qarori: egasi). Talaba bosqichi talaba tasdig'idan keyin.
## I. Mavjud bepul foydalanuvchi huquqlari (egasi qarorisiz CHEKLANMAYDI)
Bugungi main bilan bir xil ro'yxat (A bo'lim). Regressiya himoyasi: `pro_flag_default_guard_test` (bayroq false) va `product_policy_guard_test` (paywall yo'q). Tavsiya: mavjud foydalanuvchilar hozirgi imkoniyatni saqlaydi (grandfathering).
## J. Faollashtirish sharti
Faqat egasi yozma ruxsati bilan: narxlar, yillik, 30 kun mexanizmi, gate ro'yxati, do'kon mahsulotlari va kalitlari, maxfiylik/shartlar matni, mehmon xaridi qoidasi, Data safety. Hozir: `proEnabled=false`, `LG_BILLING_ENABLED` o'chiq.
