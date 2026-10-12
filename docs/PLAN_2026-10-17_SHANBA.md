# Shanba, 17-oktabr: ish rejasi

Asos: egasi bilan kelishilgan qarorlar D-45…D-51 (`DECISIONS.md`). Bu hujjat ularni bitta
kunlik, tartiblangan ishga aylantiradi. Har bandda "tayyor" degani nimani anglatishi yozilgan.
Tekshirilmagan narsa "tayyor" deb aytilmaydi.

## 0. Hozirgi holat (12-oktabr)

| Bor | Yo'q |
|---|---|
| 119 tahlil kartasi, 43 klinik holat, kalkulyatorlar, QC, preanalitika, atlas, leykoformula | Server deploy qilinmagan (guruhlar, kirish kodi, hamjamiyat "ulanmagan") |
| Ma'ruza rejimi: 1-mavzu tayyor taqdimoti (30 slayd), qolganlari avtomatik slaydlar | Avtomatik taqdimot shablonlari, ikki ekranli rejim |
| Pro huquqlar qatlami (`EntitlementService`), narxlar tasdiqlangan (D-48…D-50) | Haqiqiy to'lov (Apple/Google), do'kondagi mahsulotlar |
| Toifa banki, imtihon rejimi, kunlik savollar | Bepul limit (kuniga 2 savol) va Pro gating ulanmagan |
| 4 ta promo rolik (talaba, shifokor, laborant, ustoz) + diktor PDF | Egasining ovozi yozilmagan; ru/en roliklar yo'q |
| TestFlight build 3, barcha testlar o'tadi | Google Play upload kaliti yo'q |

## 1. Egasidan shanbagacha kerak (bularsiz tegishli bandlar bajarilmaydi)

1. **Cloudflare deploy:** `docs/BACKEND_CLOUDFLARE.md` → "Egasi uchun qadamlar": Cloudflare API
   token va account ID'ni GitHub secrets'ga qo'yish, Resend kaliti va `alideveloper.uz` domen
   tasdig'i. Bu bo'lmasa guruhlar, kirish kodi, hamjamiyat va talaba tasdig'i ishlamaydi.
2. **App Store Connect:** obuna guruhi va 6 ta mahsulot (Pro oy/yil, Pro talaba oy/yil,
   Ustoz Pro oy/yil), sinov muddati: Pro 7 kun, Ustoz Pro 14 kun. Paid Apps shartnomasi va
   bank ma'lumotlari imzolangan bo'lishi kerak.
3. **Google Play Console:** ilova yozuvi, upload kaliti (`ANDROID_KEYSTORE_*` secrets), xuddi
   shu 6 ta obuna mahsuloti.
4. **Ovoz yozuvlari:** 4 ta rolik uchun diktor PDF bo'yicha o'qilgan fayllar.
5. **Ustoz-elchi:** qaysi o'qituvchi, qancha muddat bepul Ustoz Pro.

## 2. Shanba: ishlar tartibi

### 0-blok. To'liq audit (kun boshida, yangi ish boshlanishidan oldin)
Topilgan xatolar shu kuni tuzatiladi. Har birida "nima tekshirildi, nima topildi, nima
tuzatildi" yoziladi (`docs/AUDIT_2026-10-17.md`).
- **Mazmun:** 119 tahlil kartasi va 43 holat (me'yor, birlik, manba havolasi ochiladimi),
  toifa banki kalitlari, izohli test, mikroskopiya atlasi (rasm va nom mosligi, litsenziya).
- **Rollar bo'yicha yurib chiqish:** talaba, shifokor, laborant, ustoz uz/ru/en. Har rolga
  faqat unga mos bo'limlar ko'rinadimi (masalan, talabada toifa yo'q, shifokorda toifa yo'q).
- **Pro va bepul chegarasi:** D-53 bo'yicha nima ochiq, nima yopiq; boshlangan test
  to'xtatilmasligi; TestFlight'da hammasi ochiq.
- **Xavfsizlik va maxfiylik:** sirlar repoda yo'qligi, server qoidalari (RLS/Worker),
  maxfiylik siyosati va do'kon deklaratsiyalari amaldagi ilovaga mosligi.
- **Texnik:** `flutter analyze`, barcha testlar, 320 px, yotiq ekran, katta shrift, qorong'i
  rejim, oflayn ishlash.

### 1-blok. Avtomatik taqdimot (Ustoz Pro), D-47, eng muhim
- Ustoz mavzu yoki tahlillarni tanlaydi. Tizim faqat ilovadagi tekshirilgan mazmundan
  slaydlar yig'adi: kartalar, preanalitika, kalkulyatorlar, atlas, toifa savollari.
- 5 ta slayd shabloni (1-mavzu dizaynida): sarlavha, bandlar, jadval/me'yor, sxema/rasm,
  savol-javob. Hammasi ilova ichida chiziladi, uz/ru/en, TV'da tiniq.
- Har slaydda manba ko'rsatiladi. Ma'lumot to'qilmaydi, mazmun yetmasa slayd chiqmaydi.
- **Tayyor degani:** 5 ta mavzuda taqdimot yig'ilib, uch tilda skrinshot bilan tekshirilgan;
  widget testlari; telefon va yotiq (1920×1080) ekranda kesilish yo'q.

### 2-blok. Ikki ekranli rejim, D-49
- Tashqi ekran (iPhone AirPlay "ekranni takrorlash", Android Miracast/Cast) ulanganda:
  TV'da faqat slayd, telefonda boshqaruv, ustoz izohi va keyingi slayd.
- Tashqi ekran bo'lmasa, oddiy ma'ruza rejimi o'zgarishsiz ishlaydi.
- **Tayyor degani:** tashqi ekran simulyatsiyasi bilan test. Haqiqiy TV'da sinashni egasi
  TestFlight'da qiladi (bu yerdan qilib bo'lmaydi, shuni ochiq aytaman).

### 3-blok. Pro: limit va gating, D-48 va D-49
- Bepul: kuniga 5 ta savol (kunlik savol, D-53). Xatolarni qayta ishlash cheklanmaydi. Boshlangan test yoki
  sanash hech qachon to'lov oynasi bilan to'xtatilmaydi.
- Pro'ga ulanadi: cheksiz savollar, imtihon simulyatsiyasi, to'liq toifa banki, zaif
  mavzular tahlili, atlas mashqlari. Ustoz Pro'ga ulanadi: guruhlar, testlar, hisobotlar,
  avtomatik taqdimot, ikki ekranli rejim.
- To'lov ekrani: narxlar do'kondan olinadi (qo'lda yozilmaydi), sinov muddati, "Tiklash",
  shartlar va maxfiylik havolalari (Apple 3.1.2 talabi).
- **Tayyor degani:** har Pro imkoniyat uchun "bepul → yopiq, Pro → ochiq" testi; TestFlight'da
  hamma ochiq (D-qoida 4).

### 4-blok. Haqiqiy to'lov, faqat 1-bo'limdagi 2 va 3-band bajarilgan bo'lsa
- `in_app_purchase` adapteri, Worker'da `verify-purchase` (Apple App Store Server API,
  Google Play Developer API), `entitlements` jadvaliga yozish, refund va muddat tugashi.
- **Tayyor degani:** Sandbox (Apple) va License testing (Google) xaridi serverda tasdiqlanadi.
  Do'kon mahsulotlari bo'lmasa, bu blok kelgusi haftaga qoladi va ilova hammasi bepul
  holatda qoladi ("To'lov hali yoqilmagan" yozuvi do'kon versiyasida yashiriladi, D-48).

### 5-blok. Server deploy, faqat 1-bo'limdagi 1-band bajarilgan bo'lsa
- Worker va D1 migratsiyalarini deploy qilish, ilovani `LG_API_URL` bilan yig'ish.
- Admin panelda "Pro berish (muddat bilan)" funksiyasi: faqat server tomonida, audit bilan
  (ustoz-elchi uchun, D-50).
- **Tayyor degani:** TestFlight'da haqiqiy email kodi bilan kirish, guruh yaratish, talaba
  qo'shilishi va test natijasi oxirigacha ishlaydi.

### 6-blok. Promo roliklar
- Egasining ovozini 4 ta rolikka joylash (gap-gap, vaqt bo'yicha), musiqa ovoz paytida pasayadi.
- ru/en: matn tarjimasi va ilovaning ru/en ekranlaridan qayta yozish. Ovozni o'sha tilda
  ona tili darajasida gapiradigan inson o'qiydi; sun'iy ovoz faqat egasi rozi bo'lsa.
- Yakuniy yozuv: ilova do'konda chiqmaguncha "Tez kunda", chiqqandan keyin "Hoziroq yuklab oling".

### 7-blok. Yakun
- `flutter analyze`, barcha testlar, uch tilda skrinshotlar, 320 px va yotiq ekran tekshiruvi.
- TestFlight build 4, egasiga nima yangiligi va nima tekshirish kerakligi ro'yxati.
- `PROGRESS.md` va `DECISIONS.md` yangilanadi.

## 3. Shanba kuni qilinmaydi (keyingi bosqich, D-47 tartibi)
- Offline tushuntirishlar va og'zaki mashq, keyin online AI Ustoz, keyin telefon ichidagi model.
- Talaba holatini bilet bilan tasdiqlash (server deploy'dan keyin).
- Chromecast qabul qiluvchisi.

## 4. Xavflar
- **Do'kon mahsulotlari va server kalitlari bo'lmasa**, 4 va 5-bloklar bajarilmaydi. Bu holda
  kun 1, 2, 3, 6 va 7-bloklarga sarflanadi.
- **Apple review:** to'lovsiz "Pro" yozuvlari rad etilishga sabab bo'ladi. Shuning uchun do'kon
  versiyasi yo hamma narsa bepul, yo to'lov to'liq ulangan holda yuboriladi.
- **Tibbiy mazmun:** kartalar va savollar hali mustaqil ekspert tekshiruvidan o'tmagan,
  "qoralama" belgisi saqlanadi.
