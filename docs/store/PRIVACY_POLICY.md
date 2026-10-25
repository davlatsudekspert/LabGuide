# LabGuide — maxfiylik siyosati / Политика конфиденциальности / Privacy Policy

Kuchga kirgan sana / Дата вступления в силу / Effective date: **2026-10-18**\
Aloqa / Контакт / Contact: **labguide@nfcstore.uz**

## O‘zbekcha

### Qisqacha

LabGuide — klinik laboratoriya bo‘yicha o‘quv va ma’lumotnoma ilovasi (talabalar, o‘qituvchilar,
shifokorlar va laboratoriya mutaxassislari uchun). Asosiy imkoniyatlar hisobsiz (mehmon rejimida)
ishlaydi va ma’lumotlar qurilmangizda qoladi. Hisob ixtiyoriy: u ustoz guruhlari, hamjamiyat
(savol-javob) va “Taklif va yordam” murojaatlari uchun kerak. Ilovada reklama yo‘q; analitika va
kuzatuv (tracking) SDK lari, reklama identifikatori, joylashuv va kontaktlarga kirish yo‘q
(Android’dagi QR skaner kutubxonasining texnik diagnostikasi — 14-bo‘lim). Kamera faqat siz
ochgan QR skanerda va hujjat suratida ishlatiladi. Ma’lumotlaringiz sotilmaydi va reklama uchun boshqalarga berilmaydi.

### 1. Qurilmada saqlanadigan ma’lumotlar

Quyidagilar faqat qurilmangizda saqlanadi va serverga yuborilmaydi: sozlamalar (til, mavzu,
o‘lchov birliklari, rol), xatcho‘plar, qaydlar va qoralamalar, QC (sifat nazorati) qaydlari,
apparatlaringiz va kalibrlash jurnali, PDF o‘qish holati, mashq va imtihon natijalari (guruhdagi
testlar bundan mustasno — 5-bo‘lim), kunlik savol holati va eslatma sozlamasi, leykoformula
natijalari, bilim va malakani baholash belgilari va kunlik mashg‘ulot hisobi, hamjamiyatda o‘zingiz bloklagan mualliflar ro‘yxati. Ustozning guruh a’zosiga qo‘ygan
real ism belgisi va og‘zaki savol-javob baholari ham faqat ustoz qurilmasida qoladi.

Hisob bilan kirsangiz, email manzilingiz ilovada ko‘rsatish uchun qurilmada saqlanadi, sessiya
tokeni esa qurilmaning xavfsiz omborida (iOS Keychain / Android Keystore). Qurilmadagi ma’lumotlar
tizim sozlamalariga ko‘ra qurilmaning o‘z zaxira nusxasiga (iCloud yoki Google) kirishi mumkin.
Profil → Maxfiylik va ma’lumotlar → “Lokal ma’lumotlarni o‘chirish” qurilmadagi bu ma’lumotlarni
o‘chiradi va hisobdan chiqaradi.

### 2. Hisobsiz (mehmon) foydalanish

Mehmon rejimida hisob ochilmaydi va LabGuide sizni aniqlaydigan ma’lumot to‘plamaydi (o‘zingiz
email yozmasangiz). Ilova internetga faqat quyidagi hollarda murojaat qiladi:

- **Hamjamiyatni o‘qish va tarjima:** savol-javoblar LabGuide serveridan olinadi; “Tarjima
  qilish” bosilsa, post matni tarjima qilinadi (7-bo‘lim).
- **Ilova ichidan shikoyat yuborish** (Profil → Aloqa va shikoyat): siz yozgan matn, tanlangan
  tur, ixtiyoriy ishora (qaysi ekran yoki post) va ilova tili serverga yuboriladi; mehmondan hech
  qanday identifikator saqlanmaydi.
- **Qo‘shimcha kontent paketlari:** Kutubxonadagi “Oflayn paketlar” bo‘limini ochganingizda ilova
  ochiq katalogni va siz tanlagan paketlarni GitHub (GitHub, Inc.) serveridan yuklaydi. So‘rovda
  shaxsiy ma’lumot yo‘q, lekin har qanday veb-sayt kabi GitHub IP manzilingizni ko‘radi.
- **Email orqali yozish:** Profil → Aloqa va shikoyat sahifasidagi tugmalar pochta ilovangizni
  ochadi; xat faqat o‘zingiz yuborsangiz ketadi. Unda siz yozgan matn, email manzilingiz va xat
  oxiriga avtomatik qo‘shilgan ilova versiyasi hamda platforma bo‘ladi. Xat labguide@nfcstore.uz
  manzili orqali (Cloudflare Email Routing) LabGuide egasining pochta qutisiga (Gmail) yetkaziladi.
- **Tashqi havolalar** (manbalar, maqolalar) brauzerda ochiladi — o‘sha saytlarning o‘z siyosati
  amal qiladi.

LabGuide serveriga yuborilgan har qanday so‘rovda IP manzil 6-bo‘limda yozilganidek ishlanadi.

### 3. Hisob va kirish usullari (ixtiyoriy)

Hisob uchun uch usuldan birini tanlaysiz; kirishdan oldin foydalanish shartlari va shu siyosatni
qabul qilganingizni belgilaysiz.

- **Email kodi:** email manzilingizga 6 raqamli bir martalik kod yuboriladi.
- **Google bilan kirish:** Google qurilmangizdagi tizim oynasida sizni o‘z qoidalari bo‘yicha
  tasdiqlaydi va LabGuide’ga imzolangan identifikatsiya tokenini (ID token) beradi. Server
  tokenning haqiqiyligini tekshiradi va undan **faqat** uchta qiymatni oladi: Google hisobingizning
  barqaror identifikatori (`sub`), email manzilingiz va email tasdiqlanganligi belgisi. Google’ning
  standart oynasi tokenga ism va profil rasmini ham qo‘shishi mumkin — LabGuide ulardan
  foydalanmaydi va ularni saqlamaydi. Token tekshirilgach **tashlanadi — saqlanmaydi**. LabGuide
  Google hisobingizdagi boshqa ma’lumotlarga (kontaktlar, fayllar, pochta va h.k.) ruxsat
  so‘ramaydi va serverda hech qanday Google kirish ruxsatini (access yoki refresh token) saqlamaydi.
- **Apple bilan kirish** (iPhone va iPad): Apple’dan faqat email so‘raladi, ism so‘ralmaydi.
  “Emailimni yashirish” tanlansa, Apple bergan `privaterelay.appleid.com` manzili ishlatiladi.
  Server tokendan `sub`, email va tasdiq belgisini oladi; token saqlanmaydi.

Bitta email — bitta hisob: Google yoki Apple emailingiz email kodi bilan ochilgan hisobingiz
emailiga teng bo‘lsa, usullar bitta hisobga bog‘lanadi. Google va Apple’dan olingan ma’lumot faqat
sizni hisobingizga kiritish uchun ishlatiladi: reklama uchun ishlatilmaydi, sotilmaydi va
boshqalarga berilmaydi.

### 4. Xizmat ko‘rsatuvchilar

- **Cloudflare, Inc.** — server (Workers), ma’lumotlar bazasi (D1) va Workers AI (mutaxassis
  hujjatini avtomatik tekshirish va hamjamiyat postlarini tarjima qilish; modellar Cloudflare
  infratuzilmasida ishlaydi).
- **Resend** — kirish kodi xatini yuborish (email manzilingiz va kod uzatiladi). **Brevo** —
  ixtiyoriy zaxira email xizmati: server Brevo orqali yuborishga sozlangan bo‘lsa, kod xati u
  orqali ketadi (o‘sha ma’lumot; har bir xat faqat bitta xizmat orqali). Ikkala xizmat yetkazish
  jurnalini o‘z siyosatiga ko‘ra saqlashi mumkin.
- **Google LLC** va **Apple Inc.** — faqat ular bilan kirishni o‘zingiz tanlasangiz,
  identifikatsiya provayderi sifatida (3-bo‘lim). LabGuide ularga ma’lumotingizni yubormaydi:
  server tokenni tekshirish uchun faqat ularning ochiq kalitlarini o‘qiydi. Apple bilan bog‘langan
  hisobni o‘chirganingizda Apple’ga ruxsatni bekor qilish so‘rovi yuboriladi (10-bo‘lim).
- **GitHub, Inc.** — qo‘shimcha kontent paketlari joylashgan ochiq ombor (2-bo‘lim).
- **Google LLC (Gmail)** — labguide@nfcstore.uz manziliga yozilgan xatlar egasining shu pochta
  qutisiga yetkaziladi (2-bo‘lim).

Cloudflare, Resend va Brevo ma’lumotni faqat LabGuide nomidan, xizmat ko‘rsatish uchun qayta
ishlaydi; reklama uchun ishlatmaydi va sotmaydi.

### 5. Serverda nima saqlanadi va qancha vaqt

- **Email:** ochiq holda saqlanmaydi — faqat maxfiy kalitli HMAC-hash (hisobni topish uchun) va
  niqoblangan ko‘rinish (masalan `da***@gmail.com`). Hisob o‘chirilguncha.
- **Google / Apple bog‘lanishi:** provayder nomi, `sub`, ichki hisob identifikatori va bog‘langan
  vaqt — hisob o‘chirilguncha. Tokenni qayta ishlatishdan himoya uchun token belgisining hashi —
  token amal qilish muddatigacha (odatda bir soatgacha), so‘ng kunlik tozalash o‘chiradi.
- **Kirish kodi:** faqat hash ko‘rinishida; 10 daqiqa amal qiladi, ko‘pi bilan 5 urinish;
  ishlatilgach yoki muddati o‘tgach o‘chiriladi.
- **Sessiya:** token faqat hash ko‘rinishida, kirish usuli (email kodi, Google yoki Apple) bilan;
  60 kun, so‘ng o‘chiriladi. “Chiqish” ham o‘chiradi.
- **Profil:** ichki tasodifiy identifikator, tanlangan rol va til, ro‘yxatdan o‘tgan vaqt, oxirgi
  faollik **kuni** va daqiqaga yaxlitlangan oxirgi faollik vaqti (faqat “hozir onlayn” kabi umumiy
  sonni hisoblash uchun; joylashuv va qurilma ma’lumoti yo‘q); hisob to‘xtatilgan bo‘lsa —
  to‘xtatilgan vaqt. Hisob o‘chirilguncha.
- **Ustoz:** ustoz sifatida ro‘yxatdan o‘tgan vaqt. Hisob o‘chirilguncha.
- **Guruhlar:** guruh nomi, 8 belgili qo‘shilish kodi, a’zolik (rol, qo‘shilgan vaqt), ixtiyoriy
  taxallusingiz yoki avtomatik tartib raqamingiz (“Talaba 07”). **Ism-familiya so‘ralmaydi va
  serverga yuborilmaydi.** Guruh yoki hisob o‘chirilguncha.
- **O‘quv jarayoni:** ustoz ochgan mavzular (id, ochilgan, yopilgan va dars bosqichlari o‘tilgan
  vaqt), test topshiriqlari (nom, savollar id si, vaqt chegarasi, to‘g‘ri javob kaliti — faqat
  ustozga), testni boshlagan vaqtingiz hamda **javoblaringiz, har savol natijasi va ballingiz**.
  Server og‘zaki savol-javob belgisini (natija, 1–5 baho) ham saqlay oladi, lekin ilova hozir uni
  yubormaydi. Guruh yoki hisob o‘chirilguncha.
- **“Taklif va yordam” murojaatlari:** murojaat turi (taklif, xato, savol), mavzusi, sizning va
  administratorning xabarlari, holati va vaqtlari (yuborilgan, javob berilgan, o‘qilgan). Rasm
  yoki fayl biriktirish bu versiyada qabul qilinmaydi. Javobni faqat inson (administrator) yozadi —
  avtomatik yoki AI javob yo‘q. Hisob o‘chirilguncha.
- **Ilova ichidagi shikoyatlar:** tur, matn, ixtiyoriy ishora (ekran yoki post id si), til, holat,
  administrator izohi va vaqtlar; hisob bilan yuborilgan bo‘lsa — hisobingizga bog‘lanadi.
  Avtomatik o‘chirilmaydi: hisob o‘chirilganda bog‘lanish uziladi, matn esa ko‘rib chiqish tarixi
  sifatida qoladi.
- **Hamjamiyat:** 7-bo‘lim.
- **Suiiste’molga qarshi hisoblagichlar:** urinishlar soni (kod so‘rash va tekshirish, xabar va
  shikoyat yuborish va h.k.); hisoblagich kalitida email va IP faqat hash ko‘rinishida (yoki ichki
  identifikator). Kunlik tozalash bilan odatda 1–2 sutka ichida o‘chadi.
- **Xavfsizlik va amallar jurnali:** ichki identifikatorlar, vaqt, amal turi va qisqa texnik
  tafsilot (masalan, “hisob o‘chirildi”, “Google bog‘landi”, administrator javobi yoki holat
  o‘zgarishi); email va xabar matni yo‘q. Muddatsiz saqlanadi, hisob o‘chirilgandan keyin ham
  qoladi.
- **Qo‘shimcha administratorlar:** egasi qo‘shgan admin emaili ham ochiq saqlanmaydi — faqat
  HMAC-hash va niqoblangan ko‘rinish, qo‘shilgan va olib tashlangan sana hamda kim qo‘shgani (ichki
  hash); yozuv tarix sifatida qoladi. Administratorning ikki bosqichli himoya (TOTP) kaliti
  shifrlangan holda saqlanadi.

### 6. IP manzil, jurnallar va statistika

IP manzilingiz LabGuide bazasida saqlanmaydi. Suiiste’molga qarshi limitlar uchun u server maxfiy
kaliti bilan HMAC qilinadi va qisqa teg sifatida faqat hisoblagich kalitida ishlatiladi
(5-bo‘lim). Cloudflare tarmoq xizmati sifatida so‘rovlarni (jumladan IP manzilni) o‘z siyosatiga
ko‘ra qayta ishlaydi. Server kodi jurnalga shaxsiy ma’lumot yozmaydi (faqat xato turi), Workers
jurnallarini saqlash o‘chirilgan.

Ilovada analitika va xato hisobotlari (crash reporting) SDK lari yo‘q. Qurilmangizda diagnostika
ma’lumotini ulashishga ruxsat bergan bo‘lsangiz, Apple yoki Google o‘z tizimlari orqali dasturchiga
umumlashtirilgan ishdan chiqish hisobotlarini ko‘rsatishi mumkin. LabGuide egasi admin panelida
faqat serverdagi ma’lumotlardan hisoblangan umumiy sonlarni ko‘radi (masalan, ro‘yxatdan o‘tgan va
faol hisoblar, rol va til bo‘yicha taqsimot, guruhlar, murojaat va shikoyatlar soni).

### 7. Hamjamiyat (savol-javob, ixtiyoriy)

Hisobli foydalanuvchi savol beradi, tasdiqlangan mutaxassislar javob yozadi va ovoz beradi.
**Savol va javoblar matni ilova ichida hamma uchun ochiq** (mehmonlar ham o‘qiydi); muallif ismsiz
ko‘rsatiladi — “Foydalanuvchi” yoki mutaxassis belgisi (kasb va mamlakat kodi); LabGuide egasining
postlari “LabGuide” nomi bilan chiqadi. Serverda saqlanadi: post matni, tili, ixtiyoriy mavzusi
(tahlil yoki holat id si), vaqti, ovozlar va eng yaxshi javob belgisi; muallif ichki identifikator
bilan emas, uning maxfiy kalitli hash’i bilan bog‘lanadi. Matnda email yoki telefon raqami bo‘lsa,
post qabul qilinmaydi; bemor ma’lumotini yozmang.

- **Mutaxassis tasdig‘i (ixtiyoriy):** siz tanlagan kasb va mamlakat kodi bilan birga yuklagan
  hujjat surati (diplom, sertifikat yoki ish joyi hujjati; JPEG/PNG) faqat tekshiruv vaqtida
  Cloudflare Workers AI modeliga uzatiladi va **saqlanmaydi** — na bazada, na fayl omborida, na
  jurnalda; uni inson ko‘rmaydi. Faqat natija qoladi: kasb, mamlakat kodi, holat, usul, qisqa sabab
  kodlari (hujjat turi, soha mosligi, muassasa ko‘ringani, berilgan yil, ishonch darajasi — ism
  yo‘q) va sana.
- **Tarjima:** “Tarjima qilish” bosilganda post matni Cloudflare Workers AI tarjima modeliga
  yuboriladi; tarjima serverda post o‘chirilguncha keshlanadi.
- **Shikoyat va moderatsiya:** postga shikoyat (kim, qaysi post, sabab) faqat administratorlarga
  ko‘rinadi; egasi admin panelida shikoyatlar post bo‘yicha umumlashtirib ko‘rsatiladi
  (shikoyatchi kimligi ko‘rsatilmaydi). Kamida 3 ta turli foydalanuvchi shikoyati hisobning
  hamjamiyatda yozishini administrator ko‘rib chiqquncha to‘xtatadi. Administrator postni
  o‘chirishi yoki qadashi, hisobni hamjamiyatda to‘xtatishi yoki tiklashi mumkin.
- **So‘z filtri:** savol va javob yuborilganda server matnni haqorat va so‘kinish so‘zlari
  ro‘yxati bilan solishtiradi; topilsa, post saqlanmaydi (matn ham, natija ham yozilmaydi).
- **Bloklash:** har bir foydalanuvchi muallifni bloklashi mumkin. Blok qurilmada va — hisob bilan
  kirgan bo‘lsangiz — serverda saqlanadi (sizning va muallifning hamjamiyat identifikatorlari
  juftligi; email yoki ism emas), shunda uning postlari boshqa qurilmangizda ham ko‘rinmaydi.
  Muallifga bloklangani bildirilmaydi. “Hammasini qaytarish” bloklarni o‘chiradi.

Hamjamiyat ma’lumotlari hisob o‘chirilguncha (yoki administrator postni o‘chirguncha) saqlanadi.

### 8. Kim nimani ko‘radi

- **Ustoz** faqat o‘zi yaratgan guruhni, a’zolar ro‘yxatini (taxallus yoki tartib raqami) va o‘z
  talabalarining test javoblari va ballarini ko‘radi. **Talaba** faqat o‘z a’zoligi va natijasini
  hamda ustoz belgisini ko‘radi; boshqa talabalarni va ularning natijalarini ko‘rmaydi. Test javob
  kaliti faqat ustozga ko‘rinadi.
- **Egasi admin paneli:** faqat LabGuide egasi (serverdagi maxfiy ro‘yxatdagi email) email kodi
  bilan kirib ochadi; Google yoki Apple orqali ochilgan sessiyada panel ochilmaydi. Panelda: umumiy
  statistika; foydalanuvchilar ro‘yxati — niqoblangan email, rol, til, ro‘yxatdan o‘tgan sana,
  oxirgi faol kun va holat; aniq email bo‘yicha qidiruv (server emailni hash qilib solishtiradi,
  to‘liq email ko‘rsatilmaydi) va guruh taxallusi bo‘yicha qidiruv; bitta hisob bo‘yicha — ustozligi,
  guruhlar, murojaat va shikoyatlar soni, hamjamiyat holati; murojaatlar matni va ularga javob
  yozish; ilova ichidagi shikoyatlar (matni bilan; hisob bilan yuborilgan bo‘lsa — niqoblangan
  email); hamjamiyat shikoyatlari; amallar jurnali. Egasi hisob rolini o‘zgartirishi, hisobni
  to‘xtatishi (barcha sessiyalar o‘chadi, qayta kirish rad etiladi) yoki tiklashi mumkin. Har bir
  o‘zgartirish amali jurnalga yoziladi.
- **Qo‘shimcha administratorlar** (egasi qo‘shgan email, tasdiqlangan kirish va ikki bosqichli
  himoya — TOTP) hamjamiyatni moderatsiya qiladi.
- LabGuide egasi baza va uning zaxirasiga texnik kirish huquqiga ega, lekin to‘liq emailni tiklay
  olmaydi (u saqlanmaydi). Cloudflare, Resend va Brevo xodimlari faqat o‘z xizmat shartlari
  doirasida kirishi mumkin.

### 9. Ma’lumot qayerda saqlanadi

Cloudflare D1 bazasi Cloudflare’ning Sharqiy Yevropa (EEUR) joylashuv hududida joylashgan, ya’ni
ma’lumotlaringiz **O‘zbekiston hududidan tashqarida** saqlanadi va qayta ishlanadi. Cloudflare
(jumladan Workers AI), Resend, Brevo, Google, Apple va GitHub global infratuzilmada ishlaydi;
ma’lumot boshqa mamlakatlarga, jumladan AQShga uzatilishi mumkin. Ma’lumot uzatishda shifrlanadi
(HTTPS). Hisob bilan kirib, shu shartlarga rozilik bildirasiz; rozi bo‘lmasangiz, hisobsiz (mehmon)
foydalaning — asosiy imkoniyatlar qurilmada ishlaydi.

### 10. Hisobni o‘chirish

Profil → Maxfiylik va ma’lumotlar → “Hisobni o‘chirish” serverdan butunlay o‘chiradi: profil,
barcha sessiyalar, Google va Apple bog‘lanishlari, ustoz va admin yozuvlari, guruhlardagi a’zolik
va taxallus, test javoblari, urinishlar va ballar, ustoz belgilari, “Taklif va yordam” murojaatlari
va ulardagi xabarlar, hamjamiyatdagi savol va javoblaringiz (va savollaringizga yozilgan javoblar),
ularning tarjimalari, ovozlaringiz, siz yuborgan va sizga qarshi hamjamiyat shikoyatlari, siz
qo‘ygan va sizga qo‘yilgan bloklar, mutaxassis tasdig‘i holati. Agar siz ustoz bo‘lsangiz — **siz yaratgan guruhlar ham o‘chadi**: a’zolari,
mavzulari, topshiriqlari, javob kalitlari va barcha talabalar natijalari. Shundan so‘ng qurilmadagi
lokal ma’lumotlar ham tozalanadi. O‘chirilgan ma’lumot Cloudflare D1 ning avtomatik tiklash
nusxalarida (Time Travel) cheklangan muddat qolishi mumkin, so‘ng o‘z-o‘zidan yo‘qoladi.

- **Apple:** Apple bilan bog‘langan hisobda o‘chirishdan oldin Apple tasdiq so‘raydi va LabGuide’ning
  Apple ID’ngizdagi ruxsati bekor qilinadi (tasdiqni bekor qilsangiz, hech narsa o‘chirilmaydi).
  Bekor qilish texnik sabab bilan bajarilmasa ham hisob o‘chiriladi; bunda LabGuide’ni iPhone
  Sozlamalar → Apple ID → “Apple bilan kirish” ro‘yxatidan ham olib tashlashingiz mumkin.
- **Google:** LabGuide serverda Google kirish ruxsatini saqlamaydi; xohlasangiz Google hisobingiz →
  Xavfsizlik → uchinchi tomon ilovalari ro‘yxatidan ham olib tashlashingiz mumkin.
- **Qoladi:** xavfsizlik jurnalidagi ichki identifikatorli yozuvlar (jumladan “hisob o‘chirildi”;
  email yo‘q), ilova ichidan yuborgan shikoyatlaringiz matni (hisobga bog‘lanmagan holda) va —
  agar sizni administrator qilib qo‘shilgan bo‘lsa — niqoblangan email bilan admin vakolati tarixi.
- Guruhdan chiqish faqat a’zolikni o‘chiradi; natijalaringiz hisobingiz yoki guruh o‘chirilguncha
  ustozda qoladi.
- **Email orqali so‘rov:** ilovaga kira olmasangiz (masalan, hisob to‘xtatilgan bo‘lsa yoki
  qurilma yo‘qolgan bo‘lsa), hisobga bog‘langan email manzilidan labguide@nfcstore.uz ga “hisobni
  o‘chirish” deb yozing. Administrator hisobni shu emailning aniq mosligi bo‘yicha topadi va admin
  panelidagi o‘chirish vositasi bilan **30 kun ichida** o‘chiradi — yuqoridagi bilan bir xil hajmda
  (amal xavfsizlik jurnaliga ichki identifikator bilan yoziladi) va bajarilganini javob xatida
  bildiradi. Apple bilan kirgan hisobda bu holda Apple ruxsatini server bekor qila olmasligi mumkin
  (buning uchun ilovadagi Apple tasdig‘i kerak) — LabGuide’ni iPhone Sozlamalaridan ham olib tashlang.

### 11. Saqlash muddati (qisqacha)

Kirish kodi — 10 daqiqa; Google/Apple token belgisi — token amal qilish muddatigacha (odatda bir
soatgacha); sessiya — 60 kun; suiiste’molga qarshi hisoblagichlar — 1–2 sutka; ilova ichidagi
shikoyatlar va xavfsizlik jurnali — muddatsiz (hisob o‘chirilganda shikoyat hisobdan uziladi);
qolgan ma’lumotlar — hisob (yoki guruh) o‘chirilguncha. Faol bo‘lmagan hisoblar avtomatik
o‘chirilmaydi.

### 12. Bemor ma’lumotlari

Ilovaga (taxallus, guruh nomi, murojaat, shikoyat va hamjamiyat postlariga ham) bemorni aniqlaydigan
ma’lumot (ism, tug‘ilgan sana, karta raqami) kiritmang. Guruhda taxallus sifatida o‘z ismingizni
ko‘rsatish shart emas.

### 13. Mikrofon va ovozli buyruqlar (ixtiyoriy, eksperimental)

Leykoformula sanashda ovozli buyruqlarni o‘zingiz yoqsangizgina mikrofonga ruxsat so‘raladi. Nutq
tizimning nutqni tanish xizmati orqali faqat qurilmaning o‘zida (oflayn) matnga aylantiriladi —
iPhone’da ham, Android’da ham (Android 12+); qurilmada oflayn tanish bo‘lmasa, rejim yoqilmaydi.
LabGuide ovozni yozib olmaydi, saqlamaydi va o‘z serveriga yubormaydi; faqat tanilgan hujayra nomi
sanaladi. Ovoz bilan bemor ismini aytmang.

### 14. Eslatmalar, ulashish va rasm

Kunlik savol va bilim va malakani baholash mashg‘uloti eslatmalari standart o‘chiq; yoqsangiz, ular qurilmada
rejalashtiriladigan lokal bildirishnomalar (push server yo‘q). Natija kartochkasi tizimning ulashish oynasi orqali faqat siz
tanlagan joyga yuboriladi; rasmda shaxsiy ma’lumot yo‘q. “Rasmni saqlash” tanlansa, foto
kutubxonasiga faqat shu rasm qo‘shiladi. Mutaxassis hujjati uchun kamera yoki galereyadan rasm faqat
siz suratga olganingizda yoki tanlaganingizda o‘qiladi va faqat tekshiruvga yuboriladi (7-bo‘lim).

Ilova ichidagi **QR skaner** (ustoz bergan guruh yoki test QR kodi) kamerani faqat siz skanerni
ochganingizda ishlatadi. Kamera kadri qurilmaning o‘zida o‘qiladi; rasm saqlanmaydi va hech qayerga
yuborilmaydi. QR dan faqat taklif kodi (va test identifikatori) olinadi va guruhga qo‘shilish uchun
serverga yuboriladi (5-bo‘lim) — xuddi kodni qo‘lda yozgandagidek. iPhone’da QR Apple’ning tizim
vositasi bilan o‘qiladi. Android’da Google ML Kit kutubxonasi (qurilmada ishlaydi) ishlatiladi;
Google ma’lumotiga ko‘ra ML Kit Google’ga texnik diagnostika (qurilma va ilova versiyasi,
unumdorlik ko‘rsatkichlari, foydalanuvchini aniqlash uchun mo‘ljallanmagan o‘rnatish
identifikatori) yuborishi mumkin — kamera tasviri yoki QR matni emas. Kamera ruxsatini tizim
sozlamalarida istalgan vaqtda o‘chirishingiz mumkin; skanersiz kodni yozish yoki havolani qo‘yish
ham ishlaydi.

### 15. Bolalar

Ilova bolalarga mo‘ljallanmagan va ulardan ataylab ma’lumot to‘plamaydi.

### 16. O‘zgarishlar va aloqa

Siyosat o‘zgarsa, yangi versiya shu sahifada sana bilan e’lon qilinadi. Savol va so‘rovlar uchun:
labguide@nfcstore.uz.

## Русский

### Коротко

LabGuide — учебное и справочное приложение по клинической лабораторной диагностике (для студентов,
преподавателей, врачей и специалистов лаборатории). Основные функции работают без аккаунта
(гостевой режим), а данные остаются на устройстве. Аккаунт необязателен: он нужен для групп
преподавателя, сообщества (вопросы и ответы) и обращений «Предложения и помощь». В приложении нет
рекламы; нет SDK аналитики и отслеживания (tracking), рекламного идентификатора, доступа к
геолокации и контактам (о технической диагностике библиотеки QR-сканера на Android — раздел 14).
Камера используется только в открытом вами QR-сканере и для фото документа. Данные не продаются и не передаются другим для рекламы.

### 1. Данные на устройстве

Только на устройстве хранятся и на сервер не отправляются: настройки (язык, тема, единицы
измерения, роль), закладки, заметки и черновики, записи контроля качества (QC), ваши приборы и
журнал калибровок, положение чтения PDF, результаты тренировок и экзаменов (кроме тестов в
группе — раздел 5), состояние вопроса дня и настройка напоминания, результаты лейкоформулы,
отметки и ежедневная статистика подготовки к экзамену на категорию, список авторов, которых вы заблокировали в сообществе. Реальное имя, которое
преподаватель ставит участнику группы как метку, и оценки устного опроса тоже остаются только на
устройстве преподавателя.

Если вы вошли в аккаунт, ваш email хранится на устройстве для показа в приложении, а токен сессии —
в защищённом хранилище устройства (iOS Keychain / Android Keystore). Данные на устройстве могут
попадать в системную резервную копию (iCloud или Google) согласно настройкам системы. Профиль →
Конфиденциальность и данные → «Удалить локальные данные» удаляет эти данные с устройства и
выполняет выход из аккаунта.

### 2. Без аккаунта (гостевой режим)

В гостевом режиме аккаунт не создаётся, и LabGuide не собирает данные, позволяющие вас
идентифицировать (если вы сами не напишете письмо). Приложение обращается к интернету только в
следующих случаях:

- **Чтение сообщества и перевод:** вопросы и ответы загружаются с сервера LabGuide; по нажатию
  «Перевести» текст записи переводится (раздел 7).
- **Жалоба из приложения** (Профиль → Контакты и жалобы): на сервер отправляются написанный вами
  текст, выбранный тип, необязательная ссылка (какой экран или запись) и язык приложения; для гостя
  никакой идентификатор не сохраняется.
- **Дополнительные пакеты контента:** при открытии раздела библиотеки «Офлайн-пакеты» приложение
  загружает открытый каталог и выбранные вами пакеты с сервера GitHub (GitHub, Inc.). В запросе
  нет персональных данных, но, как любой веб-сайт, GitHub видит ваш IP-адрес.
- **Письмо по email:** кнопки на странице Профиль → Контакты и жалобы открывают ваше почтовое
  приложение; письмо уходит, только если вы сами его отправите. В нём — написанный вами текст, ваш
  email и автоматически добавленные в конец версия приложения и платформа. Письмо доставляется через
  адрес labguide@nfcstore.uz (Cloudflare Email Routing) в почтовый ящик владельца LabGuide (Gmail).
- **Внешние ссылки** (источники, статьи) открываются в браузере — действуют правила этих сайтов.

Для любого запроса к серверу LabGuide IP-адрес обрабатывается так, как описано в разделе 6.

### 3. Аккаунт и способы входа (по желанию)

Для аккаунта вы выбираете один из трёх способов; перед входом вы отмечаете согласие с условиями
использования и этой политикой.

- **Код по email:** на ваш email отправляется одноразовый 6-значный код.
- **Вход через Google:** Google подтверждает вас в системном окне устройства по своим правилам и
  выдаёт LabGuide подписанный токен личности (ID token). Сервер проверяет подлинность токена и берёт
  из него **только** три значения: постоянный идентификатор вашего аккаунта Google (`sub`), адрес
  email и отметку о его подтверждении. Стандартное окно Google может добавить в токен также имя и
  фото профиля — LabGuide их не использует и не сохраняет. После проверки токен **отбрасывается — не
  хранится**. LabGuide не запрашивает доступ к другим данным вашего аккаунта Google (контакты, файлы,
  почта и т. п.) и не хранит на сервере никаких прав доступа Google (access или refresh token).
- **Вход с Apple** (iPhone и iPad): у Apple запрашивается только email, имя не запрашивается. Если
  выбрано «Скрыть e-mail», используется адрес `privaterelay.appleid.com`, выданный Apple. Сервер
  берёт из токена `sub`, email и отметку подтверждения; токен не хранится.

Один email — один аккаунт: если email Google или Apple совпадает с email аккаунта, созданного по
коду из письма, способы входа привязываются к одному аккаунту. Данные, полученные от Google и Apple,
используются только для входа в ваш аккаунт: не используются для рекламы, не продаются и не
передаются другим.

### 4. Поставщики услуг

- **Cloudflare, Inc.** — сервер (Workers), база данных (D1) и Workers AI (автоматическая проверка
  документа специалиста и перевод записей сообщества; модели работают на инфраструктуре Cloudflare).
- **Resend** — отправка письма с кодом входа (передаются ваш email и код). **Brevo** — необязательный
  резервный почтовый сервис: если сервер настроен на отправку через Brevo, письмо с кодом уходит
  через него (те же данные; каждое письмо — только через один сервис). Оба сервиса могут хранить
  журнал доставки по своей политике.
- **Google LLC** и **Apple Inc.** — только если вы сами выбрали вход через них, как провайдеры
  идентификации (раздел 3). LabGuide не отправляет им ваши данные: сервер лишь читает их публичные
  ключи для проверки токена. При удалении аккаунта, связанного с Apple, в Apple отправляется запрос
  на отзыв доступа (раздел 10).
- **GitHub, Inc.** — открытое хранилище дополнительных пакетов контента (раздел 2).
- **Google LLC (Gmail)** — письма на адрес labguide@nfcstore.uz доставляются в этот почтовый ящик
  владельца (раздел 2).

Cloudflare, Resend и Brevo обрабатывают данные только от имени LabGuide для оказания услуги; не
используют их для рекламы и не продают.

### 5. Что хранится на сервере и сколько

- **Email:** в открытом виде не хранится — только HMAC-хеш с секретным ключом (для поиска аккаунта)
  и маскированный вид (например `da***@gmail.com`). До удаления аккаунта.
- **Привязка Google / Apple:** название провайдера, `sub`, внутренний id аккаунта и время привязки —
  до удаления аккаунта. Для защиты от повторного использования токена — хеш-метка токена на срок
  его действия (обычно до часа), затем её удаляет ежедневная очистка.
- **Код входа:** только хеш; действует 10 минут, не более 5 попыток; удаляется после использования
  или по истечении срока.
- **Сессия:** токен только в виде хеша, вместе со способом входа (код по email, Google или Apple);
  60 дней, затем удаляется. «Выйти» тоже удаляет.
- **Профиль:** внутренний случайный идентификатор, выбранные роль и язык, время регистрации,
  **день** последней активности и время последней активности, округлённое до минуты (только для
  общих чисел вроде «сейчас онлайн»; без местоположения и данных устройства); если аккаунт
  приостановлен — время приостановки. До удаления аккаунта.
- **Преподаватель:** время регистрации в роли преподавателя. До удаления аккаунта.
- **Группы:** название, 8-значный код присоединения, участие (роль, время), ваш необязательный
  псевдоним или автоматический порядковый номер («Студент 07»). **Имя и фамилия не запрашиваются и
  не отправляются на сервер.** До удаления группы или аккаунта.
- **Учебный процесс:** открытые преподавателем темы (id, время открытия, закрытия и прохождения
  этапов занятия), тестовые задания (название, id вопросов, лимит времени, ключ ответов — только для
  преподавателя), время начала теста и **ваши ответы, результат по каждому вопросу и балл**. Сервер
  умеет хранить и отметки устного опроса (результат, оценка 1–5), но приложение сейчас их не
  отправляет. До удаления группы или аккаунта.
- **Обращения «Предложения и помощь»:** тип обращения (предложение, ошибка, вопрос), тема, ваши
  сообщения и сообщения администратора, статус и время (отправки, ответа, прочтения). Вложения
  (изображения, файлы) в этой версии не принимаются. Отвечает только человек (администратор) —
  автоматических или AI-ответов нет. До удаления аккаунта.
- **Жалобы из приложения:** тип, текст, необязательная ссылка (id экрана или записи), язык, статус,
  заметка администратора и время; если отправлена из аккаунта — связана с аккаунтом. Автоматически
  не удаляются: при удалении аккаунта связь разрывается, а текст остаётся как история
  рассмотрения.
- **Сообщество:** раздел 7.
- **Счётчики защиты от злоупотреблений:** число попыток (запрос и проверка кода, отправка
  сообщений и жалоб и т. п.); в ключе счётчика email и IP только в виде хеша (или внутренний
  идентификатор). Удаляются ежедневной очисткой, обычно в течение 1–2 суток.
- **Журнал безопасности и действий:** внутренние идентификаторы, время, тип действия и краткая
  техническая деталь (например, «аккаунт удалён», «привязан Google», ответ администратора или
  смена статуса); без email и текста сообщений. Хранится бессрочно, в том числе после удаления
  аккаунта.
- **Дополнительные администраторы:** email добавленного владельцем администратора тоже не хранится
  в открытом виде — только HMAC-хеш и маскированный вид, даты добавления и удаления и кто добавил
  (внутренний хеш); запись остаётся как история. Ключ двухфакторной защиты (TOTP) администратора
  хранится в зашифрованном виде.

### 6. IP-адрес, журналы и статистика

Ваш IP-адрес не хранится в базе LabGuide. Для лимитов защиты от злоупотреблений он хешируется
(HMAC) секретным ключом сервера и используется как короткая метка только в ключе счётчика
(раздел 5). Cloudflare как сетевой сервис обрабатывает запросы (в том числе IP-адрес) по своей
политике. Код сервера не записывает в журналы персональные данные (только тип ошибки), хранение
журналов Workers отключено.

В приложении нет SDK аналитики и отчётов о сбоях (crash reporting). Если вы разрешили на устройстве
передачу диагностических данных, Apple или Google могут через свои системы показывать разработчику
обобщённые отчёты о сбоях. Владелец LabGuide в панели администратора видит только общие числа,
посчитанные по данным сервера (например, зарегистрированные и активные аккаунты, распределение по
ролям и языкам, группы, число обращений и жалоб).

### 7. Сообщество (вопросы и ответы, по желанию)

Пользователь с аккаунтом задаёт вопрос, подтверждённые специалисты отвечают и голосуют. **Тексты
вопросов и ответов открыты всем внутри приложения** (читают и гости); автор показывается без имени —
«Участник» или значок специалиста (профессия и код страны); записи владельца LabGuide подписаны
«LabGuide». На сервере хранятся: текст записи, язык, необязательная тема (id анализа или
состояния), время, голоса и отметка лучшего ответа; автор связан не внутренним идентификатором, а
его хешем с секретным ключом. Запись с email или номером телефона в тексте не принимается; не
пишите данные пациентов.

- **Подтверждение специалиста (по желанию):** фото документа (диплом, сертификат или документ с
  места работы; JPEG/PNG), загруженное вместе с выбранными вами профессией и кодом страны,
  передаётся модели Cloudflare Workers AI только на время проверки и **не сохраняется** — ни в
  базе, ни в файловом хранилище, ни в журналах; человек его не видит. Остаётся только результат:
  профессия, код страны, статус, способ, короткие коды причины (тип документа, соответствие
  области, видно ли учреждение, год выдачи, уровень уверенности — без имени) и дата.
- **Перевод:** по нажатию «Перевести» текст записи отправляется модели перевода Cloudflare Workers
  AI; перевод кешируется на сервере до удаления записи.
- **Жалобы и модерация:** жалобу на запись (кто, на какую запись, причина) видят только
  администраторы; в панели владельца жалобы показываются сгруппированными по записи (кто
  пожаловался, не показывается). Жалобы не менее 3 разных пользователей приостанавливают
  возможность писать в сообществе до проверки администратором. Администратор может удалить или
  закрепить запись, приостановить или восстановить аккаунт в сообществе.
- **Фильтр слов:** при отправке вопроса или ответа сервер сверяет текст со списком оскорбительных и
  нецензурных слов; если они найдены, запись не сохраняется (ни текст, ни результат проверки).
- **Блокировка:** каждый пользователь может заблокировать автора. Блокировка хранится на устройстве
  и — если вы вошли в аккаунт — на сервере (пара идентификаторов сообщества ваш/автора; не email и
  не имя), поэтому его записи не видны и на другом вашем устройстве. Автор о блокировке не
  уведомляется. «Вернуть всех» удаляет блокировки.

Данные сообщества хранятся до удаления аккаунта (или до удаления записи администратором).

### 8. Кто что видит

- **Преподаватель** видит только созданную им группу, список её участников (псевдоним или номер) и
  ответы и баллы своих студентов. **Студент** видит только своё участие и результат, а также метку
  преподавателя; других студентов и их результаты не видит. Ключ ответов теста виден только
  преподавателю.
- **Панель владельца:** открывает только владелец LabGuide (email из секретного списка на сервере),
  войдя по коду из письма; в сессии, открытой через Google или Apple, панель не открывается. В
  панели: общая статистика; список пользователей — маскированный email, роль, язык, дата
  регистрации, день последней активности и статус; поиск по точному email (сервер сравнивает хеш,
  полный email не показывается) и по псевдониму в группе; по одному аккаунту — роль
  преподавателя, группы, число обращений и жалоб, статус в сообществе; тексты обращений и ответы на
  них; жалобы из приложения (с текстом; если отправлены из аккаунта — маскированный email); жалобы
  сообщества; журнал действий. Владелец может изменить роль аккаунта, приостановить аккаунт (все
  сессии удаляются, повторный вход отклоняется) или восстановить его. Каждое изменение записывается
  в журнал.
- **Дополнительные администраторы** (email, добавленный владельцем, подтверждённый вход и
  двухфакторная защита — TOTP) модерируют сообщество.
- Владелец LabGuide имеет технический доступ к базе и её копиям, но не может восстановить полный
  email (он не хранится). Сотрудники Cloudflare, Resend и Brevo могут получать доступ лишь в рамках
  условий своих услуг.

### 9. Где хранятся данные

База Cloudflare D1 размещена в регионе расположения Cloudflare «Восточная Европа» (EEUR), то есть
ваши данные хранятся и обрабатываются **за пределами территории Узбекистана**. Cloudflare (включая
Workers AI), Resend, Brevo, Google, Apple и GitHub работают на глобальной инфраструктуре; данные
могут передаваться в другие страны, в том числе в США. При передаче данные шифруются (HTTPS).
Входя в аккаунт, вы соглашаетесь с этими условиями; если не согласны, пользуйтесь без аккаунта
(гостевой режим) — основные функции работают на устройстве.

### 10. Удаление аккаунта

Профиль → Конфиденциальность и данные → «Удалить аккаунт» полностью удаляет с сервера: профиль,
все сессии, привязки Google и Apple, записи преподавателя и администратора, участие и псевдоним в
группах, ответы на тесты, попытки и баллы, отметки преподавателя, обращения «Предложения и помощь» и
сообщения в них, ваши вопросы и ответы в сообществе (и ответы на ваши вопросы), их переводы, ваши
голоса, жалобы сообщества, отправленные вами и на вас, поставленные вами и на вас блокировки,
статус подтверждения специалиста. Если вы
преподаватель — **созданные вами группы тоже удаляются**: их участники, темы, задания, ключи
ответов и результаты всех студентов. После этого очищаются и локальные данные на устройстве.
Удалённые данные могут ограниченное время оставаться в автоматических точках восстановления
Cloudflare D1 (Time Travel), после чего исчезают сами.

- **Apple:** для аккаунта, связанного с Apple, перед удалением Apple попросит подтверждение, и
  доступ LabGuide к вашему Apple ID отзывается (если отменить подтверждение, ничего не удаляется).
  Если отзыв не удался по технической причине, аккаунт всё равно удаляется; тогда LabGuide можно
  убрать и в настройках iPhone → Apple ID → «Вход с Apple».
- **Google:** LabGuide не хранит на сервере прав доступа Google; при желании приложение можно убрать
  и в аккаунте Google → Безопасность → список сторонних приложений.
- **Остаётся:** записи журнала безопасности с внутренним идентификатором (в том числе «аккаунт
  удалён»; без email), текст отправленных вами из приложения жалоб (без связи с аккаунтом) и — если
  вас добавляли администратором — история прав администратора с маскированным email.
- Выход из группы удаляет только участие; ваши результаты остаются у преподавателя до удаления
  аккаунта или группы.
- **Запрос по email:** если вы не можете войти в приложение (например, аккаунт приостановлен или
  устройство утеряно), напишите «удалить аккаунт» на labguide@nfcstore.uz с email, привязанного к
  аккаунту. Администратор находит аккаунт по точному совпадению этого email и удаляет его
  инструментом удаления в панели администратора **в течение 30 дней** — в том же объёме, что и выше
  (действие записывается в журнал безопасности с внутренним идентификатором), и сообщает об этом в
  ответном письме. Для аккаунта, связанного с Apple, сервер в этом случае может не суметь отозвать
  доступ Apple (для этого нужно подтверждение Apple в приложении) — уберите LabGuide и в настройках
  iPhone.

### 11. Сроки хранения (кратко)

Код входа — 10 минут; метка токена Google/Apple — на срок действия токена (обычно до часа); сессия
— 60 дней; счётчики защиты от злоупотреблений — 1–2 суток; жалобы из приложения и журнал
безопасности — бессрочно (при удалении аккаунта жалоба отвязывается от него); остальные данные — до
удаления аккаунта (или группы). Неактивные аккаунты автоматически не удаляются.

### 12. Данные пациентов

Не вводите в приложение (в том числе в псевдоним, название группы, обращения, жалобы и записи
сообщества) данные, позволяющие идентифицировать пациента (ФИО, дату рождения, номер карты). В
группе указывать своё имя в качестве псевдонима не обязательно.

### 13. Микрофон и голосовые команды (по желанию, экспериментально)

Доступ к микрофону запрашивается, только если вы сами включите голосовые команды при подсчёте
лейкоформулы. Речь распознаётся системной службой только на самом устройстве (офлайн) — и на
iPhone, и на Android (Android 12+); если офлайн-распознавания нет, режим не включается. LabGuide не
записывает, не хранит и не отправляет звук на свой сервер; учитывается только распознанное название
клетки. Не называйте вслух имя пациента.

### 14. Напоминания, «Поделиться» и изображения

Напоминания о вопросах дня и о подготовке к категории по умолчанию выключены; если их включить, это
локальные уведомления, запланированные на устройстве (push-сервера нет). Карточка результата отправляется через системное
окно «Поделиться» только туда, куда выберете вы; персональных данных в ней нет. При выборе
«Сохранить изображение» в фотоальбом добавляется только эта картинка. Для документа специалиста снимок с
камеры или изображение из галереи читается, только когда вы сами снимаете или выбираете его, и
отправляется только на проверку (раздел 7).

Встроенный **QR-сканер** (QR-код группы или теста от преподавателя) использует камеру, только когда
вы сами открываете сканер. Кадр обрабатывается на самом устройстве; изображение не сохраняется и
никуда не отправляется. Из QR-кода берётся только код приглашения (и идентификатор теста), который
отправляется на сервер для вступления в группу (раздел 5) — так же, как при ручном вводе кода. На
iPhone QR-код читается системным средством Apple. На Android используется библиотека Google ML Kit
(работает на устройстве); по данным Google, ML Kit может отправлять Google техническую диагностику
(версии устройства и приложения, показатели производительности, идентификатор установки, не
предназначенный для идентификации пользователя) — но не изображение с камеры и не текст QR-кода.
Доступ к камере можно в любой момент отключить в системных настройках; без сканера можно ввести код
или вставить ссылку.

### 15. Дети

Приложение не предназначено для детей и намеренно не собирает их данные.

### 16. Изменения и контакт

При изменении политики новая версия публикуется на этой странице с датой. Вопросы и запросы:
labguide@nfcstore.uz.

## English

### Summary

LabGuide is a learning and reference app for clinical laboratory diagnostics (for students,
teachers, physicians and laboratory specialists). The core features work without an account (guest
mode) and your data stays on your device. An account is optional: it is needed for teacher groups,
the community (Q&A) and “Feedback & help” requests. The app contains no ads, and has no analytics or
tracking SDKs, no advertising identifier and no access to location or contacts (for the QR
scanner library’s technical diagnostics on Android, see section 14). The camera is used only in the
QR scanner you open and for a document photo. Your data is not
sold or shared with others for advertising.

### 1. Data stored on your device

The following stay only on your device and are not sent to a server: settings (language, theme,
units, role), bookmarks, notes and drafts, quality-control (QC) records, your instruments and
calibration log, PDF reading position, practice and exam results (except group tests — section
5), daily-question state and
reminder setting, differential-count results, category-exam preparation marks and daily practice stats, and the list of
authors you blocked in the community. A real-name label a teacher puts on a group member and oral
Q&A grades also stay only on the teacher’s device.

If you sign in, your email address is kept on the device to show it in the app, and the session
token is kept in the device’s secure storage (iOS Keychain / Android Keystore). Data on the device
may be included in the system backup (iCloud or Google) according to your system settings.
Profile → Privacy and data → “Delete local data” removes this data from the device and signs you
out.

### 2. Without an account (guest mode)

In guest mode no account is created and LabGuide does not collect data that identifies you (unless
you write an email yourself). The app
goes online only in these cases:

- **Reading and translating the community:** questions and answers are loaded from the LabGuide
  server; when you tap “Translate”, the post text is translated (section 7).
- **Sending a complaint in the app** (Profile → Contact & reports): the text you write, the
  chosen type, an optional reference (which screen or post) and the app language are sent to the
  server; no identifier is stored for a guest.
- **Additional content packs:** when you open the “Offline packs” section of the library, the app downloads a public
  catalogue and the packs you choose from GitHub (GitHub, Inc.). The request contains no personal
  data, but, like any website, GitHub sees your IP address.
- **Writing an email:** the buttons on Profile → Contact & reports open your mail app; the email is
  sent only if you send it yourself. It contains the text you write, your email address and the app
  version and platform added automatically at the end. It is delivered through the
  labguide@nfcstore.uz address (Cloudflare Email Routing) to the LabGuide owner’s mailbox (Gmail).
- **External links** (sources, articles) open in your browser — those websites’ own policies apply.

For any request to the LabGuide server, the IP address is handled as described in section 6.

### 3. Account and sign-in methods (optional)

You choose one of three methods for an account; before signing in you confirm that you accept the
terms of use and this policy.

- **Email code:** a one-time 6-digit code is sent to your email address.
- **Sign in with Google:** Google verifies you in the system sheet on your device under its own
  rules and gives LabGuide a signed identity token (ID token). The server verifies the token and
  takes **only** three values from it: the stable identifier of your Google account (`sub`), your
  email address and whether that email is verified. Google’s standard sign-in sheet may also add
  your name and profile picture to the token — LabGuide does not use or store them. After
  verification the token is **discarded — it is not stored**. LabGuide does not request access to
  any other data in your Google account (contacts, files, mail, etc.) and keeps no Google access
  grant (access or refresh token) on the server.
- **Sign in with Apple** (iPhone and iPad): only your email is requested from Apple, not your name.
  If you choose “Hide My Email”, the `privaterelay.appleid.com` address provided by Apple is used.
  The server takes `sub`, the email and the verification flag from the token; the token is not
  stored.

One email, one account: if your Google or Apple email equals the email of an account created with
the email code, the sign-in methods are linked to that one account. Data received from Google and
Apple is used only to sign you in to your account: it is not used for advertising, not sold and not
shared with others.

### 4. Service providers

- **Cloudflare, Inc.** — the server (Workers), the database (D1) and Workers AI (automatic check of
  a specialist’s document and translation of community posts; the models run on Cloudflare’s
  infrastructure).
- **Resend** — sending the sign-in code email (your email address and the code are passed to it).
  **Brevo** — an optional fallback email service: if the server is configured to send through Brevo,
  the code email goes through it (the same data; each email goes through only one service). Both
  services may keep a delivery log under their own policies.
- **Google LLC** and **Apple Inc.** — only if you choose to sign in with them, as identity providers
  (section 3). LabGuide does not send them your data: the server only reads their public keys to
  verify the token. When you delete an account linked to Apple, a request to revoke access is sent
  to Apple (section 10).
- **GitHub, Inc.** — the public repository that hosts additional content packs (section 2).
- **Google LLC (Gmail)** — emails written to labguide@nfcstore.uz are delivered to the owner’s
  mailbox there (section 2).

Cloudflare, Resend and Brevo process data only on LabGuide’s behalf to provide the service; they do
not use it for advertising or sell it.

### 5. What the server stores, and for how long

- **Email:** never stored in the clear — only a keyed HMAC hash (to find your account) and a masked
  form (e.g. `da***@gmail.com`). Until account deletion.
- **Google / Apple link:** the provider name, `sub`, your internal account id and the time of
  linking — until account deletion. To stop a token being replayed, a hash mark of the token for as
  long as the token is valid (usually up to an hour), then removed by the daily cleanup.
- **Sign-in code:** hash only; valid for 10 minutes, at most 5 attempts; removed once used or
  expired.
- **Session:** the token is stored only as a hash, together with the sign-in method (email code,
  Google or Apple); 60 days, then removed. “Sign out” also removes it.
- **Profile:** an internal random identifier, your chosen role and language, sign-up time, the
  **day** of your last activity and the time of your last activity rounded to the minute (only for
  aggregate numbers such as “online now”; no location or device data); if the account is suspended,
  the time of suspension. Until account deletion.
- **Teacher:** the time you registered as a teacher. Until account deletion.
- **Groups:** group name, 8-character join code, membership (role, join time), your optional
  nickname or an automatic sequence number (“Student 07”). **No first or last name is asked for or
  sent to the server.** Until the group or account is deleted.
- **Teaching activity:** topics a teacher opened (ids and the times they were opened, closed and
  lesson stages completed), test assignments (title, question ids, time limit, answer key — teacher
  only), the time you started a test, and **your answers, per-question result and score**. The
  server can also store oral Q&A marks (result, 1–5 grade), but the app does not send them at
  present. Until the group or account is deleted.
- **“Feedback & help” requests:** the request type (suggestion, bug, question), subject, your
  messages and the administrator’s messages, status and times (sent, answered, read). Attachments
  (images, files) are not accepted in this version. Replies are written only by a person (the
  administrator) — there are no automatic or AI replies. Until account deletion.
- **In-app complaints:** type, text, an optional reference (screen or post id), language, status,
  administrator note and times; if sent while signed in, linked to your account. Not deleted
  automatically: when the account is deleted the link is removed and the text remains as a review
  record.
- **Community:** section 7.
- **Abuse-protection counters:** the number of attempts (requesting and verifying a code, sending
  messages and complaints, etc.); the counter key holds an email or IP only as a hash (or an
  internal identifier). Removed by the daily cleanup, usually within 1–2 days.
- **Security and activity log:** internal identifiers, time, action type and a short technical
  detail (e.g. “account deleted”, “Google linked”, an administrator reply or status change); no
  email and no message text. Kept indefinitely, including after account deletion.
- **Additional administrators:** an administrator email added by the owner is not stored in the
  clear either — only an HMAC hash and a masked form, the dates added and removed and who added it
  (internal hash); the record remains as history. An administrator’s two-factor (TOTP) key is
  stored encrypted.

### 6. IP address, logs and statistics

Your IP address is not stored in LabGuide’s database. For abuse-protection limits it is hashed
(HMAC) with the server’s secret key and used as a short tag only inside a counter key (section 5).
Cloudflare, as a network service, handles requests (including the IP address) under its own policy.
The server code writes no personal data to logs (only the error type), and Workers log storage is
turned off.

The app contains no analytics or crash-reporting SDKs. If you have allowed sharing of diagnostic
data on your device, Apple or Google may show the developer aggregated crash reports through their
own systems. In the admin panel the LabGuide owner sees only aggregate numbers calculated from the
server data (e.g. registered and active accounts, breakdown by role and language, groups, the number
of requests and complaints).

### 7. Community (Q&A, optional)

A signed-in user asks a question; verified specialists answer and vote. **Question and answer texts
are public inside the app** (guests can read them too); the author is shown without a name —
“Member” or a specialist badge (profession and country code); posts by the LabGuide owner are shown
as “LabGuide”. The server stores: the post text, its language, an optional topic (test or condition
id), time, votes and the best-answer mark; the author is linked not by the internal identifier but
by a keyed hash of it. A post containing an email address or phone number is rejected; do not write
patient data.

- **Specialist verification (optional):** the photo of your document (diploma, certificate or
  employment document; JPEG/PNG), uploaded together with the profession and country code you
  choose, is passed to a Cloudflare Workers AI model only for the duration of the check and is
  **not stored** — not in the database, not in file storage, not in logs; no person looks at it.
  Only the result is kept: profession, country code, status, method, short reason codes (document
  type, field match, whether an institution is visible, year of issue, confidence level — no name)
  and date.
- **Translation:** when you tap “Translate”, the post text is sent to a Cloudflare Workers AI
  translation model; the translation is cached on the server until the post is deleted.
- **Reports and moderation:** a report on a post (who, which post, reason) is visible only to
  administrators; the owner’s panel shows reports grouped by post (who reported is not shown).
  Reports from at least 3 different users suspend the account’s ability to post in the community
  until an administrator reviews it. An administrator can delete or pin a post, and suspend or
  restore an account in the community.
- **Word filter:** when a question or answer is sent, the server checks the text against a list of
  abusive and profane words; if one is found, the post is not saved (neither the text nor the check
  result is stored).
- **Blocking:** each user can block an author. The block is kept on the device and — if you are
  signed in — on the server (a pair of your and the author’s community identifiers; not an email
  or name), so their posts are hidden on your other devices too. The author is not notified.
  “Unblock all” removes the blocks.

Community data is kept until the account is deleted (or an administrator deletes the post).

### 8. Who can see what

- A **teacher** sees only the group they created, its member list (nickname or number) and the
  answers and scores of their own students. A **student** sees only their own membership and result
  and the teacher’s label — not other students or their results. The test answer key is visible
  only to the teacher.
- **Owner’s admin panel:** opened only by the LabGuide owner (an email on a secret server-side list)
  after signing in with an email code; it does not open in a session started with Google or Apple.
  The panel shows: aggregate statistics; the user list — masked email, role, language, sign-up date,
  last active day and status; search by exact email (the server compares a hash; the full email is
  not shown) and by group nickname; for a single account — teacher status, groups, the number of
  requests and complaints, community status; the text of requests and replying to them; in-app
  complaints (with their text; for a signed-in sender, the masked email); community reports; the
  activity log. The owner can change an account’s role, suspend an account (all sessions are
  removed and signing in again is refused) or reactivate it. Every change is written to the log.
- **Additional administrators** (an email added by the owner, a verified sign-in and two-factor
  authentication — TOTP) moderate the community.
- The LabGuide owner has technical access to the database and its backups but cannot recover a full
  email address (it is not stored). Cloudflare, Resend and Brevo personnel may access data only as
  allowed by their own service terms.

### 9. Where data is stored

The Cloudflare D1 database is located in Cloudflare’s Eastern Europe (EEUR) location region, so your
data is stored and processed **outside the territory of Uzbekistan**. Cloudflare (including Workers
AI), Resend, Brevo, Google, Apple and GitHub run on global infrastructure; data may be transferred to
other countries, including the US. Data is encrypted in transit (HTTPS). By signing in you accept
these terms; if you do not, use the app without an account (guest mode) — the core features work on
the device.

### 10. Deleting your account

Profile → Privacy and data → “Delete account” permanently removes from the server: your profile,
all sessions, Google and Apple links, teacher and admin records, group memberships and nicknames,
test answers, attempts and scores, teacher marks about you, “Feedback & help” requests and their
messages, your community questions and answers (and answers to your questions), their translations,
your votes, community reports made by you and about you, blocks you set and blocks set on you, and
your specialist verification status.
If you are a teacher, **the groups you created are deleted too**: their members, topics,
assignments, answer keys and all students’ results. Local data on the device is then cleared as
well. Deleted data may remain for a limited time in Cloudflare D1’s automatic restore points (Time
Travel) and then disappears on its own.

- **Apple:** for an account linked to Apple, Apple asks you to confirm before deletion and
  LabGuide’s access to your Apple ID is revoked (if you cancel the confirmation, nothing is
  deleted). If the revocation fails for a technical reason, the account is still deleted; you can
  then also remove LabGuide in iPhone Settings → Apple ID → “Sign in with Apple”.
- **Google:** LabGuide keeps no Google access grant on the server; you can also remove the app in
  your Google Account → Security → the list of third-party apps.
- **What remains:** security-log entries with an internal identifier (including “account deleted”;
  no email), the text of complaints you sent in the app (no longer linked to the account) and — if
  you were added as an administrator — the administrator-rights history with a masked email.
- Leaving a group removes only your membership; your results stay with the teacher until your
  account or the group is deleted.
- **Request by email:** if you cannot sign in to the app (for example, the account is suspended or
  the device is lost), write “delete my account” to labguide@nfcstore.uz from the email linked to
  the account. An administrator finds the account by an exact match of that email and deletes it
  with the deletion tool in the admin panel **within 30 days** — to the same extent as above (the
  action is recorded in the security log with an internal identifier) — and confirms by reply. For
  an account linked to Apple the server may then be unable to revoke Apple access (that needs the
  Apple confirmation in the app) — also remove LabGuide in iPhone Settings.

### 11. Retention (summary)

Sign-in code — 10 minutes; Google/Apple token mark — while the token is valid (usually up to an
hour); session — 60 days; abuse-protection counters — 1–2 days; in-app complaints and the security
log — indefinitely (a complaint is unlinked from the account when the account is deleted); all other
data — until the account (or group) is deleted. Inactive accounts are not deleted automatically.

### 12. Patient data

Do not enter information that identifies a patient (name, date of birth, record number) anywhere in
the app, including nicknames, group names, requests, complaints and community posts. In a group you
do not have to use your own name as a nickname.

### 13. Microphone and voice commands (optional, experimental)

Microphone access is requested only if you turn on voice commands in the differential counter.
Speech is recognised by the system speech service on the device itself only (offline) — on iPhone
and on Android 12+; if on-device recognition is unavailable, the mode stays off. LabGuide does not
record, store or send audio to its own server; only the recognised cell name is counted. Do not say
a patient’s name aloud.

### 14. Reminders, sharing and images

The daily question and qualification-practice reminders are off by default; if you turn them on,
they are local notifications scheduled on the device (no push server). A result card is shared through the system share sheet
only to the destination you choose; it contains no personal data. If you choose “Save Image”, only
that image is added to your photo library. For a specialist document, a camera photo or a gallery image
is read only when you take or pick it yourself, and is sent only for the check (section 7).

The in-app **QR scanner** (a group or test QR code from your teacher) uses the camera only while you
have the scanner open. The camera image is read on the device itself; it is not saved and not sent
anywhere. Only the invite code (and test identifier) is taken from the QR code and sent to the
server to join the group (section 5) — the same as typing the code. On iPhone the QR code is read by
Apple’s system framework. On Android the Google ML Kit library (running on the device) is used;
according to Google, ML Kit may send Google technical diagnostics (device and app versions,
performance metrics, a per-installation identifier not intended to identify the user) — not the
camera image or the QR text. You can turn camera access off in system settings at any time; typing
the code or pasting the link works without the scanner.

### 15. Children

The app is not directed to children and does not knowingly collect their data.

### 16. Changes and contact

If this policy changes, the new version is published on this page with its date. Questions and
requests: labguide@nfcstore.uz.
