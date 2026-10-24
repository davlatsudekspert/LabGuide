# D-72. Pro — taklif (FAQAT TAKLIF; hech narsa yoqilmaydi, billing/paywall/server faol emas)
Mavjud holat: `pro-next` (pushed, main'dan alohida), `proEnabled=false`, narxlar ma'lumot sifatida taklif, `freeTrialDays=null`, hech nima gate qilinmagan, D-71 da 10 ta ochiq qaror. Eski D-49 (7/14 kun), D-48/D-57 narxlari ESKIRGAN.

## A. Bepul foydalanuvchi huquqlari (bugungi main = «bepul kafolat»)
Quyidagilar main'da bepul va Pro tufayli QISQARMASLIGI taklif qilinadi (egasi tasdiqlashi kerak):
leykoformula, kalkulyatorlar, preanalitika, QC, kalibrovka jurnali, apparat katalogi + TB/OIV ma'lumotnomalar, atlas va mikroskopiya, kartalar, kunlik savollar, ustoz-talaba testi (guruh, QR, topshiriq, natijalar), umumiy test, toifa (D-40 doirasida), foydalanuvchi o'z ma'lumotini eksport/o'chirish, hisobni o'chirish.
Savol: «mavjud foydalanuvchilar hozirgi imkoniyatni saqlaydimi» — tavsiya: HA (grandfather), Pro faqat YANGI qo'shimcha imkoniyatlar (masalan: cheksiz xotira/eksport, ilg'or tahlil, jamoa panellari) uchun.
## B. Pro nima beradi (nomzod ro'yxat — tanlov egasiniki; hozir kodda hech biri yopilmagan)
Talaba / Oddiy / Ustoz bosqichlari: tavsiya qilingan farqlar (tasdiqlanmagan): Ustoz — katta guruh/ko'p topshiriq/hisobot eksporti; Oddiy — cheksiz mashq tarixi, imtihon simulyatsiyasi; Talaba — Oddiy huquqlari past narxda (talaba tasdig'i).
## C. Narxlar (taklif; tasdiqlanmagan)
| Bosqich | Oylik USD | Yillik | UZS |
|---|---|---|---|
| Talaba | 1.49 | — (hal qilinsin) | do'kon narx nuqtasi (qaror kerak) |
| Oddiy | 3.99 | — | — |
| Ustoz | 5.99 | — | — |
Qoida: narx ilovaga qotirilmaydi, do'kondan olinadi (D-plan 0.5). Yillik narx odatda oylikning 8–10 baravari oralig'ida bo'ladi, lekin bu **tavsiya, qaror emas**. Hududiy narxlar: do'konning o'z narx jadvalidan (Apple/Google), qo'lda emas.
## D. 30 kunlik bepul foydalanish — ikki variant (tanlov egasida)
1. **Do'konning o'z introductory offer'i** (Apple free trial / Google free trial): serverga tegmaydi, do'kon qoidalari (bir akkauntga bir marta), eng kam xavf; kamchilik: karta kerak, muddat do'kon beradigan variantlar bilan cheklangan (Apple 30 kun ruxsat etilgan).
2. **Server beradigan 30 kun** (ro'yxatdan o'tgach avtomatik): karta shart emas, o'zbek bozori uchun qulay; kamchilik: suiiste'mol (qayta ro'yxat), server tekshiruvi, hisob shartligi (mehmon uchun ishlamaydi), Apple 3.1.2 shaffoflik talablari.
Tavsiya: avval 1-variant; 2-variant faqat egasi hisob/anti-fraud qoidalarini tasdiqlasa. `freeTrialDays` o'zgaruvchisi bor, mexanizm yo'q.
## E. Do'kon va huquqiy talablar (hali YO'Q)
Obuna matni (shartlar, maxfiylik, Data safety), «Restore purchases», bekor qilish yo'riqnomasi, narx va davr ekranda, hisobni o'chirish bilan obuna aloqasi, Apple 3.1.1/3.1.2, Google obuna siyosati, talaba tasdig'i, referral, regional narx. Plagin Play BILLING ruxsatini manifestga qo'shadi → **bepul relizlar faqat main'dan**.
## F. Bepul relizga xavf yo'q qoidalari
`proEnabled=false` qorovul, `product_policy_guard`, pro-next→main faqat egasi yozma ruxsati bilan, mehmon xaridi (eski kodda mehmon sotib ola oladi — qaror kerak), mavjud foydalanuvchilar huquqini kamaytirmaslik testi.

## G. Yillik tarif — taklif (tasdiqlanmagan; kodda `yearlyUsd = null`)
Variantlar (egasi tanlaydi): (1) yillik tarif umuman yo'q; (2) yillik = oylikning 10 baravari (≈ 2 oy bepul): Talaba 14.90, Oddiy 39.90, Ustoz 59.90 USD/yil; (3) yillik = oylikning 8 baravari: 11.90 / 31.90 / 47.90. Bu faqat arifmetik taklif; bozor tadqiqoti qilinmagan. Do'konning narx pog'onalariga yaxlitlash kerak.
## H. Pullik funksiyalar — nomzod ro'yxat (hech biri yopilmagan; `ProGatePolicy.gated` bo'sh)
Faqat YANGI qo'shimcha imkoniyatlar bo'lishi mumkin: natijalar va hisobotlarni eksport (PDF/CSV), kengaytirilgan tahlil paneli (ustoz), katta guruh/ko'p topshiriq limiti oshishi, cheksiz imtihon simulyatsiyasi tarixi, oflayn paketlar. Bugun bepul bo'lgan hech narsa pullikka o'tkazilmaydi (qarori: egasi). Talaba bosqichi talaba tasdig'idan keyin.
## I. Mavjud bepul foydalanuvchi huquqlari (egasi qarorisiz CHEKLANMAYDI)
Bugungi main bilan bir xil ro'yxat (A bo'lim). Regressiya himoyasi: `pro_flag_default_guard_test` (bayroq false) va `product_policy_guard_test` (paywall yo'q). Tavsiya: mavjud foydalanuvchilar hozirgi imkoniyatni saqlaydi (grandfathering).
## J. Faollashtirish sharti
Faqat egasi yozma ruxsati bilan: narxlar, yillik, 30 kun mexanizmi, gate ro'yxati, do'kon mahsulotlari va kalitlari, maxfiylik/shartlar matni, mehmon xaridi qoidasi, Data safety. Hozir: `proEnabled=false`, `LG_BILLING_ENABLED` o'chiq.
