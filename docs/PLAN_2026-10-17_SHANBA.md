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

**Tartib (egasi bilan kelishilgan, 12-oktabr):** 1) audit → 2) dizayn (6e-blok) →
3) leykoformula avtomatik baholash → 4) sitologiya: domla izohlari bo'yicha tuzatish va
qo'shimchalar (yetilish indeksi, reaktiv o'zgarishlar, ASC-US/LSIL/AGC, namuna sifati) →
5) spermogramma → 6) test buildi. Vaqt qolsa: qon guruhi, roliklar, uch tilni to'liq tekshirish.

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

### 4b-blok. Tahlil varaqasini rasmdan o'qish (bepul, D-54)
- Shifokor varaqani rasmga oladi yoki galereyadan tanlaydi; ismni kesish taklif qilinadi.
- Matnni telefonning o'zi o'qiydi (iOS Vision, Android ML Kit), internetsiz va bepul.
- Ilova qatorlarni ajratadi: tahlil nomi, natija, birlik, varaqadagi me'yor oralig'i
  (uz/ru/en sinonimlar lug'ati bilan, masalan "Глюкоза", "Glucose", "Qand").
- Har qator kartaga bog'lanadi; yuqori/past/me'yorda; shifokor qo'llanmasidagi natija naqshlari
  bilan solishtiriladi va manba bilan ko'rsatiladi. Tashxis qo'yilmaydi.
- Shifokor o'qilgan qiymatlarni ko'rib, tuzata oladi; rasm hech qayerga yuborilmaydi.
- **Tayyor degani:** o'zimiz yasagan 20 ta kompyuterda bosilgan namunaviy varaqada (uz/ru/en,
  haqiqiy bemorsiz) aniqlik o'lchanadi va natija yoziladi.
- Claude API (Pro) keyinroq, kerak bo'lsa, faqat murakkab varaqalar uchun.

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

### 6b-blok. Yangi bo'limlar (egasi, 12-oktabr)
- **Sitologiya** — qoralama main'ga qo'shildi va testga chiqarildi (12-oktabr, egasi so'rovi bilan): 13 element sxemasi, qin surtmasi tozalik darajasi (I–IV), Bethesda, surtma olish va
  bo'yash, "Bu qaysi hujayra?" mashqi. Egasi qo'shimchalar beradi; domla/mutaxassis tekshiradi.
  Faqat shundan keyin main'ga va TestFlight'ga. Keyin — sitologiya roligi (ovozsiz + diktor PDF).
- **Lab bosh sahifasi:** Leykoformula kartasi kabi rasmli katta kartalar qatori — Leykoformula,
  Sitologiya, Spermogramma (keyin Qon guruhi). Sitologiya hozir pastdagi oddiy qatorda — yuqoriga,
  rasmli kartaga ko'chiriladi (egasi so'rovi, 12-oktabr skrinshoti).
- **Leykoformula: natijani avtomatik baholash.** Hozir sanashdan keyin faqat % va (WBC kiritilsa)
  mutlaq sonlar chiqadi; "Talqin" sahifasi alohida. Qo'shiladi: har hujayra bo'yicha me'yor bilan
  solishtirish (mutlaq son ustun; me'yor — laboratoriyaning o'z blankasi bo'yicha sozlanadi,
  standart qiymat manbadan), yuqori/past belgisi, mos "Talqin" kartasiga havola (masalan,
  neytrofiliya, limfotsitoz, eozinofiliya, chapga siljish) manbalari bilan; blast/"boshqa"
  hujayra yoki keskin og'ish bo'lsa "shifokor/gematologga" ogohlantirishi. Tashxis qo'yilmaydi —
  "nimaga ishora qilishi mumkin". Xuddi shu yondashuv spermogrammaga ham.
- **Spermogramma** (yangi bo'lim, leykoformula uslubida; tartib: audit → spermogramma → qon guruhi
  → sitologiya qo'shimchalari): JSST 2021 (6-nashr) pastki chegaralari — hajm 1,4 ml, konsentratsiya
  16 mln/ml, umumiy son 39 mln, umumiy harakatchanlik 42 %, progressiv 30 %, tiriklik 54 %, normal
  shakl 4 %, pH ≥ 7,2 (manba bilan qayta tekshiriladi); harakatchanlik va morfologiya sanash
  hisoblagichi; atamalar (oligo-, asteno-, terato-, azoospermiya) mezonlari bilan; morfologiya
  sxemalari (bosh/bo'yin/dum nuqsonlari, o'zimiz chizamiz yoki egasi bergan sxemalar tekshiriladi);
  preanalitika (2–7 kun saqlanish, 1 soat ichida tahlil, harorat); mashq va rolik.
- **Sitologiya qo'shimchalari:** yetilish indeksi (gormonal/atrofik surtma), reaktiv o'zgarishlar va
  atipiyadan farqi, ASC-US / LSIL / AGC sxemalari, namuna sifati va artefaktlar, balg'am, seroz
  suyuqliklar va siydik sitologiyasi.
- **Qon guruhini aniqlash usullari** (keyingi bo'lim): ABO va Rh(D) — standart zardoblar /
  tsoliklonlar bilan, kross usul, gel-kartalar; moslik sinamalari; xatolar va ularning sabablari
  (sovuq agglyutinatsiya, rulo hosil bo'lishi, zaif A2 va h.k.). Manbalar: JSST qon xavfsizligi
  qo'llanmalari, AABB/ochiq darsliklar; sxemalar o'zimiz chizamiz. Rolik bilan.
- Ikkalasi ham **Pro** imkoniyatlari qatoriga kiradi (7 kunlik bepul sinov, D-49); bepul qism —
  kiritish va ko'rish, mashqlar va to'liq jadvallar — Pro (aniq chegara audit kuni yoziladi).
- Qoida: tibbiy mazmunda xato bo'lmasligi uchun har bo'lim "qoralama" belgisi bilan chiqadi va
  domla tasdig'idan keyin "tekshirilgan"ga o'tadi; rasm nomga mosligi ko'z bilan tekshiriladi.

### 6c-blok. Hammasi uch tilda (uz/ru/en)
- Hozir 3 tilda: interfeys, 119 karta, 173 izohli test, toifa 488 test + 289 og'zaki savol,
  sitologiya. Faqat o'zbekcha: 1-mavzu taqdimoti (30 slayd), domla bergan 529 yangi savol.
- Shanba: yangi bo'limlar (spermogramma, qon guruhi, sitologiya qo'shimchalari) birdaniga 3 tilda;
  1-mavzu taqdimoti ru/en; domla savollari — avval domla kalitni tasdiqlaydi (34 shubhali + 8 zid),
  keyin ru/en tarjima. Toifa rasmiy matni o'zbekcha qoladi, ru/en — yordamchi tarjima belgisi bilan.
- **Rus tili — to'liq teng til** (O'zbekistondagi rus guruhlari toifani rus tilida topshiradi):
  toifa 488 test + 289 og'zaki savolning ruscha matni rasmiy rus atamalari (ГОСТ Р ИСО 15189,
  klinik tavsiyalar) bilan qayta tekshiriladi; SSV toifa savollarining rasmiy ruscha varianti
  qidiriladi (avval domla bergan 300 talik kirill to'plam) — topilsa matn shunga moslanadi va
  "yordamchi tarjima" belgisi olib tashlanadi. Begona (masalan, RF akkreditatsiya) test banklari
  ko'chirilmaydi — faqat mavzu qamrovi uchun ko'riladi, bo'sh mavzularga o'z savollarimiz tuziladi.
- Tarjimalar tibbiy atamalar lug'ati bo'yicha tekshiriladi; ona tilida so'zlashuvchi mutaxassis
  ko'rib chiqishi alohida qayd etiladi (hali yo'q).
- Roliklar va diktor PDF ham ru/en.

### 6d-blok. Marketing rejasi (hujjat)
- `docs/MARKETING_PLAN.md`: bosqichlar (1k → 10k → 100k → 1M), kanallar (Telegram kanallari va
  guruhlari, Instagram/TikTok roliklari, YouTube o'quv videolari, ustoz-elchi, kollej/institutlar),
  pullik reklama sinovi ($50–100: Google App Campaigns, Apple Search Ads, Meta) va o'lchovlar
  (yuklab olish narxi, Pro'ga o'tish, 7 kunlik sinovdan keyin to'lash, qaytish). Shart: reklamadan
  oldin Pro to'lovi ulangan va ilova do'konda ochiq bo'lsin.

### 6e-blok. Dizaynni kundalik foydalanishga qulay qilish (egasi topshirig'i, 12-oktabr)
Palitra (to'q yashil, sutrang, och yashil), logo va uslub saqlanadi. Avval mavjud kod tekshiriladi —
ishlayotgan qismlar qayta qurilmaydi (masalan, scrollda ixchamlashadigan sarlavha va tab xotirasi
allaqachon bor — faqat sinab, kerak bo'lsa tuzatiladi).
1. Bosh sahifa: molekulali rasm va tanishtiruv kartasi balandligi ~30–35% kamayadi (matn
   kichraymaydi — rasm balandligi va bo'shliqlar hisobiga); birinchi ekranda asosiy amallar ko'rinadi.
2. Qidiruv tepada: "Tahlil, apparat yoki mavzu qidirish" — haqiqiy qidiruv; natijalar guruhlangan
   (tahlillar, apparatlar, o'quv materiallari); uz lotin/kirill, RU/EN nomlar va qisqartmalar.
3. Rolga mos tezkor tugmalar: shifokor — tahlillar, kalkulyatorlar, shifokor qo'llanmasi;
   laborant — leykoformula, sifat nazorati, mening apparatim; talaba — mavzular, testlar, xatolar
   ustida ishlash; ustoz — guruhlar, topshiriqlar, natijalar. Rol almashganda mazmun ham o'zgaradi.
4. Lab sahifasi: "Apparat → reagent → metod" o'rniga "Kalibrlash va metodika", ostida kichik
   "Apparat → reagent → usul"; leykoformula, sifat nazorati, preanalitika, kalkulyatorlarga tez kirish.
5. Atamalar: "QC" → "Sifat nazorati (QC)"; preanalitika izohi — "Namunani olish, saqlash va
   tashish". Hammasi UZ/RU/EN ARB orqali.
6. Pastki menyu: oxirgi karta menyu ortida qolmasin (menyu balandligi + safe area); menyu biroz
   ixcham, lekin yozuv va bosish maydoni kichraymaydi; tab holati saqlanadi.
7. Scrollda yuqori panel silliq qisqaradi va qaytadi, sakrash yo'q; "harakatni kamaytirish" hisobga
   olinadi.
8. Yagona vizual tizim: oraliqlar, ichki bo'shliqlar, burchaklar, ikonka o'lchamlari, sarlavha
   darajalari; dekorativ rasmlar ish tugmalarini pastga surmaydi; kontrast yetarli.
Tekshiruv: 4 rol × 3 til × kunduzgi/tungi × kichik ekran (320 px) × shrift 1.3x; qidiruv,
klaviatura, scroll va menyu bir-biriga xalaqit bermasligi. Natija: bosh sahifa va Lab sahifasining
oldingi/keyingi skrinshotlari, qayerda tekshirilgani (Flutter widget testlari va web-build, iOS
TestFlight'da egasi), keyin test buildi.

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
