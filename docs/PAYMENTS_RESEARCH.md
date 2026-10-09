# LabGuide — to'lov tadqiqoti (App Store, Google Play, Click/Payme/Uzum)

Tadqiqot sanasi: **2026-10-09**. Barcha URL'lar shu sanada ochib tekshirildi (agar boshqacha ko'rsatilmagan bo'lsa).
Belgilar: **[R]** — rasmiy manbada so'zma-so'z tasdiqlandi; **[X]** — tasdiqlanmadi (rasmiy manbada topilmadi yoki sahifa mashinada o'qilmadi); **[K]** — kuzatuv/xulosa (rasmiy matn emas).

Bog'liq: `/home/user/labguide/docs/PRO_BILLING_PLAN.md` (huquqlar qatlami tayyor, to'lov yoqilmagan).

---

## 0. Qisqa xulosa

1. **App Store, O'zbekiston:** storefront bor (UZB). O'zbekiston "Rest of World — USD" moliyaviy hisobot guruhida. Apple'ning valyuta kodlari ro'yxatida UZS yo'q, demak narx **USD** da. Xaridor faqat **"Most credit and debit cards"** bilan to'laydi: operator billing yo'q, Apple Account balansi ham ro'yxatda yo'q. Tashqi to'lovga havola (link-out) O'zbekiston uchun **ruxsat etilmagan**: bu faqat AQSh, EI/EEA, Yaponiya, Braziliya, Koreya va Niderlandiyadagi tanishuv ilovalariga tegishli.
2. **Google Play, O'zbekiston:** dasturchi va merchant ro'yxatdan o'tishi **mumkin**, merchantning standart valyutasi USD. Xaridor uchun O'zbekiston "Other countries" toifasida: faqat Visa, Mastercard, Amex va Discover kartalari. Operator billing va Humo/Uzcard ro'yxatda yo'q. User choice billing / alternative billing O'zbekistonga **tegishli emas**. Xaridor ko'radigan UZS narxlar egasi kuzatgan; rasmiy jadvalda **tasdiqlanmadi** (6-bo'limga qarang).
3. **Click/Payme/Uzum:** ilova ichida Pro (raqamli imkoniyat) sotish uchun ishlatish App Store 3.1.1 va Play Payments policy'ga **zid**. Ruxsat bor holatlar: (a) Apple 3.1.3(c) — tashkilotga to'g'ridan-to'g'ri sotilgan B2B litsenziya; (b) 3.1.3(b) — veb-saytda sotilgan obunani ilovada ochish, lekin iOS'da shu narsa IAP sifatida ham sotilishi shart va ilova ichida veb-saytga chaqiruv bo'lmasligi kerak; (c) Google Play'da faqat iste'mol qiladigan (consumption-only) ilova.
4. **Soliq:** O'zbekistonda QQS 12% (Soliq kodeksi 258-modda). Google Play'da muhim farq bor. Dasturchi **O'zbekistonda** bo'lsa, O'zbekistondagi xaridlar QQSini o'zi hisoblaydi va to'laydi. **Chet elda** bo'lsa, buni Google qiladi.
5. **Tavsiya:** A-variant — do'konlar billingi (IAP + Play Billing) bilan boshlash, B2B esa veb orqali (Click/Payme, shartnoma) parallel. Batafsil: 7-bo'lim.

---

## 1. App Store (Apple)

| Savol | Javob | Manba |
|---|---|---|
| O'zbekiston storefronti bormi? | **Ha.** Jadvalda "UZB Uzbekistan", standart til English (U.K.). [R] | https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/ (2026-10-09) |
| Narx/mavjudlik jadvalida bormi? | **Ha.** "UZB Uzbekistan" qatori bor, cheklov belgisi yo'q ("- - - -"). [R] | https://developer.apple.com/help/app-store-connect/reference/app-store-pricing-and-availability-start-times-by-country-or-region/ (2026-10-09) |
| IAP/obuna sotish mumkinmi? | Storefront narx jadvalida bor va O'zbekiston bo'yicha alohida taqiq topilmadi. Apple 2020 va 2023 yillarda O'zbekistondagi "apps and in-app purchases" narxlarini QQS sababli o'zgartirgan, demak IAP shu storefrontda sotiladi. [R/K] | https://developer.apple.com/news/?id=04142020a (2020-04-14); https://developer.apple.com/news/?id=g8dce2t4 (2023-01-27) |
| Valyuta (USD yoki UZS)? | **USD.** O'zbekiston "Rest of World — USD — WW" hisobot guruhida [R]. Apple'ning "Currency codes" ro'yxatida UZS yo'q (KZT bor) [R]. Xaridorga narx USD da ko'rsatilishi shundan kelib chiqqan xulosa [K]. | https://developer.apple.com/help/app-store-connect/reference/financial-report-regions-and-currencies/ ; https://developer.apple.com/help/app-store-connect/reference/currency-codes/ (2026-10-09) |
| Narx bosqichlari (price tiers) | Eski "tier" tizimi o'rniga **800 ta narx nuqtasi** bor, so'rov bilan yana 100 tasi (10 000 $ gacha) qo'shiladi. Bitta **bazaviy mamlakat** tanlanadi, Apple qolgan 174 storefront va 43 valyuta uchun narxni avtomatik hosil qiladi (kurs va soliqlar hisobga olinadi). Bazaviy mamlakat narxi o'zgarmaydi. Qo'lda narx qo'yilgan storefrontlarni Apple boshqa o'zgartirmaydi. [R] | https://developer.apple.com/help/app-store-connect/manage-app-pricing/set-a-price/ (2026-10-09) |
| O'zbekistonda xaridor qanday to'laydi? | Ro'yxatda O'zbekiston uchun faqat **"Most credit and debit cards"**. Operator billing, Apple Pay yoki Apple Account balansi ko'rsatilmagan. Taqqoslash uchun Qozog'istonda "Mobile phone billing: Beeline, Kcell" va balans bor. [R] (sahifa nashr sanasi: 2026-08-07) | https://support.apple.com/en-us/111741 |
| Humo/Uzcard ulanadimi? | Apple bu brendlarni nomlab tilga olmaydi. "Most credit and debit cards" Humo/Uzcard (milliy tizimlar) ishlashini **anglatmaydi**. [X] Amalda Humo/Uzcard bank tomonidan Visa/Mastercard bilan birga (co-badge) chiqarilgan kartadagina ishlashi mumkin. Bu tekshirilmagan [K]. | — |
| Operator billing (Ucell/Beeline/Mobiuz) | O'zbekiston uchun **yo'q** (ro'yxatda faqat kartalar). [R] | https://support.apple.com/en-us/111741 |
| Link-out (tashqi to'lovga havola) | 3.1.1(a): StoreKit External Purchase Link entitlement "apps on the App Store in specific regions" uchun beriladi. AQSh storefrontida entitlement shart emas. 3.1.3: boshqa storefrontlarda ilova ichida IAP'dan boshqa usulga chaqirish mumkin emas. [R] (Guidelines "Last Updated: June 8, 2026") | https://developer.apple.com/app-store/review/guidelines/ |
| Link-out qaysi mintaqalarda? | Apple External Purchase hujjatida: EU/EEA (va "the EEA and Russia" bandi), **Braziliya** (iOS 26.5+), **Yaponiya** (iOS 26.2+), Niderlandiya (faqat tanishuv ilovalari), Janubiy Koreya, AQSh (entitlementsiz). **O'zbekiston yo'q.** [R] | https://developer.apple.com/documentation/storekit/external-purchase ; https://developer.apple.com/support/storekit-external-entitlement/ (2026-10-09) |
| Komissiya | Small Business Program: yillik daromadi 1 mln USD gacha bo'lgan dasturchiga **15%**. [R] Obuna 1 yildan keyin 15% bo'lishi haqidagi umumiy qoida bu sahifada alohida tekshirilmadi [X]. | https://developer.apple.com/app-store/small-business-program/ |
| O'zbekistondan Apple Developer'ga yozilish va to'lov (bank) | Enrollment sahifasida "Enrollment may not be supported in certain regions" deyilgan. O'zbekiston bo'yicha alohida bayonot yo'q. Apple Store Online bo'lmasa, USD yechadigan karta talab qilinadi [R]. O'zbek bankiga to'lov chiqarish rasmiy hujjatda **tasdiqlanmadi** [X]. | https://developer.apple.com/support/purchase-activation/ |

---

## 2. Google Play

| Savol | Javob | Manba |
|---|---|---|
| O'zbekistonda dasturchi va merchant akkaunti | Jadvalda **"Uzbekistan ✔ ✔ USD"**: developer registration ✔, merchant registration ✔, standart valyuta USD. Demak O'zbekistondagi shaxs yoki kompaniya pulli ilova/obuna sotishi mumkin. [R] | https://support.google.com/googleplay/android-developer/answer/9306917?hl=en (2026-10-09) |
| Boshqa yo'llar (kerak bo'lsa) | Merchant to'lov profili joylashgan mamlakat valyutani va soliq rejimini belgilaydi ("Default currency is based on the location of the developer's payments profile"). [R] Chet eldagi kompaniya orqali sotish **shart emas**, lekin soliq farqi bor (5-bo'lim). | o'sha sahifa |
| Xaridorlar sotib ola oladimi? | "Country availability for Google Play apps": "Paid Android apps — Available in many countries worldwide". O'zbekiston kitoblar va Google TV ro'yxatlarida ham bor. [R] Ilova ichidagi xaridlar uchun mamlakat qatori jadvalda ko'rinmadi (6-bo'lim) [X]. | https://support.google.com/googleplay/answer/2843119?hl=en |
| Xaridor to'lov usullari | Accepted payment methods sahifasida O'zbekiston alohida ro'yxatda **yo'q**, shuning uchun "Other countries" qoidasi amal qiladi: **American Express, Discover, Mastercard, Visa** kartalari. Virtual kartalar (VCC) qabul qilinmaydi. [R] | https://support.google.com/googleplay/answer/2651410?hl=en (2026-10-09) |
| Humo/Uzcard | Ro'yxatda **yo'q**. [X] (co-badge Visa/MC bo'lsa ishlashi mumkin — tekshirilmagan [K]) | o'sha sahifa |
| Operator billing (Ucell/Beeline/Mobiuz) | O'zbekiston uchun ko'rsatilmagan. "Other countries" ro'yxatida faqat kartalar. [R: yo'q] | o'sha sahifa |
| User choice billing / alternative billing | User choice billing faqat quyidagilar uchun: **Australia, Brazil, Indonesia, Japan, South Africa, United Kingdom, EEA**. Alternativ billing alohida Janubiy Koreya va Hindiston uchun bor. AQSh uchun sud qarori asosidagi dasturlar mavjud. **O'zbekiston yo'q.** [R] | https://support.google.com/googleplay/android-developer/answer/13821247?hl=en ; https://support.google.com/googleplay/android-developer/answer/12570971?hl=en ; https://support.google.com/googleplay/android-developer/answer/10281818?hl=en |
| Xizmat haqi | Avtomatik yangilanadigan obunalar uchun **15%** "regardless of revenue". [R] | https://support.google.com/googleplay/android-developer/answer/112622?hl=en |
| Narx belgilash | Bitta bazaviy narx kiritiladi. Play uni mahalliy valyutaga o'giradi, ayrim mamlakatlarda soliq qo'shadi va mahalliy narx andozalarini qo'llaydi. Mamlakatlar bo'yicha narxni qo'lda o'zgartirish mumkin. Mahalliy valyuta qo'llab-quvvatlanmasa, narx USD yoki EUR da bo'ladi. "The currency used in each country is set and can't be changed." [R] | https://support.google.com/googleplay/android-developer/answer/6334373?hl=en ; https://support.google.com/googleplay/android-developer/answer/1169947?hl=en |
| Soliq kiritilgan narx | O'zbekiston "tax-inclusive pricing" qo'llab-quvvatlanadigan mamlakatlar ro'yxatida bor. [R] | https://support.google.com/googleplay/android-developer/answer/138000?hl=en |

---

## 3. Click / Payme / Uzum: do'kon qoidalari bilan muvofiqlik

### Qoidalar (rasmiy matn)
- **Apple 3.1.1:** "If you want to unlock features or functionality within your app (… subscriptions … access to premium content …), you must use in-app purchase." [R] https://developer.apple.com/app-store/review/guidelines/ (Last Updated: June 8, 2026)
- **Apple 3.1.3(a) Reader apps:** faqat jurnal, gazeta, kitob, audio, musiqa va video ilovalari uchun. LabGuide (tibbiy laboratoriya qo'llanmasi, kalkulyator va imtihon tayyorgarligi) bu toifaga **kirmaydi** [K, ta'rifga ko'ra]. https://developer.apple.com/support/reader-apps/
- **Apple 3.1.3(b) Multiplatform:** foydalanuvchi veb-saytda yoki boshqa platformada olgan obunani ilovada ishlatishi mumkin, "**provided those items are also available as in-app purchases within the app**". [R]
- **Apple 3.1.3(c) Enterprise:** "If your app is only sold directly by you to organizations or groups for their employees or students … you may allow enterprise users to access previously-purchased content or subscriptions. **Consumer, single user, or family sales must use in-app purchase.**" [R] Bu laboratoriya va kollej litsenziyalari uchun to'g'ridan-to'g'ri asos.
- **Apple 3.1.3 umumiy:** AQSh storefronti va 3.1.1(a)/3.1.3(a) bandlaridan tashqari ilova ichida boshqa to'lov usuliga undash mumkin emas. Ilovadan **tashqarida** (email va h.k.) xabar berish mumkin. [R]
- **Google Payments policy:** Play'dan tarqatiladigan ilovada raqamli imkoniyat va obunalar uchun "must use Google Play's billing system". Ilova ichida (tugma, havola, webview, ro'yxatdan o'tish oqimi) boshqa to'lov usuliga yo'naltirish taqiqlangan. [R] https://support.google.com/googleplay/android-developer/answer/9858738?hl=en
- **Google consumption-only:** "Google Play allows any app to be consumption-only, even if it is part of a paid service… access content paid for somewhere else." Shart: ilova ichida hech narsa sotilmaydi. Ilovadan tashqarida foydalanuvchiga boshqa narxlar haqida xabar berish mumkin. Ilovalar orasida narx tengligi (parity) talab qilinmaydi. [R] https://support.google.com/googleplay/android-developer/answer/10281818?hl=en

### Xulosa
| Holat | Apple | Google |
|---|---|---|
| Ilova ichida Pro tugmasi → Click/Payme sahifasi | **Zid** (3.1.1, 3.1.3) | **Zid** (Payments policy) |
| Ilova ichida faqat IAP/Play Billing; veb-saytda alohida Click/Payme sotuvi; ilova ikkalasini ham taniydi | Ruxsat (3.1.3(b)), agar ilovada IAP ham bo'lsa va ilova ichida veb-saytga chaqiruv bo'lmasa | Policy matni ilova ichida yo'naltirishni taqiqlaydi, boshqa joyda sotilganini tan olishni taqiqlamaydi. Aralash model haqida FAQ'da alohida tasdiq **topilmadi** [X] |
| Ilovada umuman sotuv yo'q, faqat veb-saytda sotilgan hisob bilan kirish | Reader app emas, shu sabab 3.1.3(b) talabi (IAP ham bo'lishi) qo'llanadi. Faqat 3.1.3(f) "free stand-alone companion to a paid web based tool" holati bor, lekin u VoIP, bulut va email kabi xizmatlar uchun. LabGuide'ga mosligi **noaniq** [K] | **Ruxsat** (consumption-only) |
| Laboratoriya yoki kollejga to'g'ridan-to'g'ri litsenziya (shartnoma, Click/Payme yoki bank o'tkazmasi) | **Ruxsat** (3.1.3(c)), lekin faqat tashkilot xodimlari/talabalari uchun | Consumption-only qoidasi doirasida mumkin. Alohida B2B istisno topilmadi [X] |

### Mahalliy provayderlar texnik imkoniyatlari
- **Payme Subscribe API:** karta tokeni (`cards.create`, `cards.verify` SMS-kod bilan, `cards.check`, `cards.remove`) va chek usullari (`receipts.create`, `receipts.pay`, …, `receipts.set_fiscal_data`). Talab: ilovada "Powered by Payme" yorlig'i. Hujjatda saqlangan token bilan to'lashdan oldin PIN so'rash tavsiya etiladi [R]. Avtomatik yangilanadigan (foydalanuvchisiz) obuna to'lovi alohida **tasdiqlanmadi** [X]. Android SDK bor. https://developer.help.paycom.uz/protokol-subscribe-api ; https://developer.help.paycom.uz/metody-subscribe-api/ ; https://developer.help.paycom.uz/integratsiya-s-mobilnym-prilozheniem/
- **Click:** Shop API (Prepare/Complete), Merchant API, Click Pass, fiskalizatsiya, "Мобильная интеграция" va "Оплата по карте" bo'limlari bor. Hujjat JS orqali yuklanadi, karta tokeni orqali takroriy yechish matni **tasdiqlanmadi** [X]. https://docs.click.uz/
- **Uzum Bank:** Checkout, Merchant, FastPay va boshqa API hujjatlari bor. Obuna/rekurrent imkoniyati **tasdiqlanmadi** [X]. https://developer.uzumbank.uz/
- Uchala provayderda ham fiskalizatsiya bo'limi bor. Mahalliy sotuvda fiskal chek talabining aniq qonuniy asosi bu tadqiqotda tekshirilmadi [X].

### Xavflar
- Ilova ichida tashqi to'lovga havola bo'lsa, App Review rad etadi yoki ilova o'chiriladi. Play'da policy buzilishi akkaunt jazosigacha olib kelishi mumkin.
- 3.1.3(c) faqat tashkilot xodimlari va talabalari uchun ishlaydi. Shaxsiy foydalanuvchiga "kollej narxi" bilan sotish iste'molchi savdosi hisoblanadi va IAP talab qiladi.
- Veb va do'kon narxi farq qilsa, ilova ichida bu haqda gapirish taqiqlangan (AQShdan tashqari).

---

## 4. Global imkoniyatlar

| Mavzu | Apple | Google |
|---|---|---|
| Mintaqaviy narx (PPP) | Bazaviy mamlakat bo'yicha avtomatik ekvivalent. Kurs va soliqqa qarab avtomatik yangilanadi. Har storefrontga qo'lda narx qo'yish mumkin. PPP (xarid qobiliyati) asosida avtomatik narx **yo'q**: bu kurs va soliq ekvivalenti, PPP narxini dasturchi o'zi qo'yadi [R/K]. https://developer.apple.com/help/app-store-connect/manage-app-pricing/set-a-price/ | Bazaviy narx mahalliy valyutaga o'giriladi va "locally relevant pricing patterns" qo'llanadi. Mamlakat bo'yicha qo'lda narx qo'yish mumkin [R]. https://support.google.com/googleplay/android-developer/answer/6334373 |
| Bepul sinov | Introductory offers (shu jumladan bepul sinov), promotional va win-back offers [R]. https://developer.apple.com/app-store/subscriptions/ | Offerlar "free trials and/or introductory pricing" beradi. Eligibility: yangi mijoz, upgrade va h.k. Bitta obunada 250 tagacha base plan va offer, 50 tasi faol [R]. https://support.google.com/googleplay/android-developer/answer/12154973 |
| Oilaviy obuna | Family Sharing: obunani **5 tagacha** oila a'zosi bilan bo'lishish mumkin (dasturchi yoqadi) [R]. https://developer.apple.com/app-store/subscriptions/ | Play obunalari uchun oilaviy bo'lishish rasmiy manbada **tasdiqlanmadi** [X] |
| Talaba chegirmasi / kodlar | Offer codes: bir martalik (18 xonali) yoki maxsus kodlar (masalan SPRINGPROMO), chegirma yoki bepul davr bilan [R]. Talaba ekanini Apple tekshirmaydi, kod tarqatishni dasturchi boshqaradi [K]. https://developer.apple.com/app-store/subscriptions/ | Promo codes: bir martalik yoki maxsus kodlar. Obuna uchun **3–90 kunlik** bepul sinov. In-app Promotions integratsiyasi talab qilinadi [R]. https://support.google.com/googleplay/android-developer/answer/6321495 |
| B2B (laboratoriya/kollej) | Apple Business (Manager) feature jadvalida O'zbekiston uchun **"Get Apps" (Volume Purchase) yo'q**. Faqat Brand and Location, Branded Mail, Built-in device management, Managed Apple Accounts va Zero-touch bor [R]. Demak VPP orqali O'zbekistonda litsenziya sotib bo'lmaydi, yo'l **3.1.3(c)** (to'g'ridan-to'g'ri shartnoma). https://support.apple.com/guide/business/feature-availability-axmef1c47twq/web | Managed Google Play'da pullik ommaviy litsenziya mexanizmi rasmiy manbada **tasdiqlanmadi** [X]. B2B uchun amaliy yo'l: veb/shartnoma orqali sotib, ilovada server-entitlement bilan ochish (consumption-only qoidasiga e'tibor bering) |

---

## 5. Soliq (QQS) — kim to'laydi

- **O'zbekiston QQS stavkasi: 12%.** Soliq kodeksi, 258-modda (2022-12-30 dagi ЎРҚ-812 tahriri, 2023-01-01 dan). [R] https://lex.uz/docs/4674902
- **Chet el kompaniyalari elektron xizmatlari:** Soliq kodeksi 279-modda (elektron shaklda xizmat ko'rsatuvchi chet el yuridik shaxslarini hisobga qo'yish) va 282-modda (realizatsiya joyi O'zbekiston). Vositachi chet el yuridik shaxsi soliq agenti deb e'tirof etilishi mumkin. Sahifada "2026 yil 12 dekabrdan kuchga kiradigan o'zgarishlarga qarang" degan izoh bor, ya'ni yaqin orada o'zgarish kutilmoqda. [R] https://lex.uz/docs/4674902
- **Google Play [R]** (https://support.google.com/googleplay/android-developer/answer/138000?hl=en):
  - Dasturchi **O'zbekistonda** bo'lsa: "you're responsible for determining, charging, and remitting Uzbekistan VAT for all Google Play Store paid app and in-app purchases made by customers in Uzbekistan". Jismoniy shaxs yoki yakka tadbirkor bo'lsa, Google xizmat haqiga mahalliy QQS qo'shadi. Tashkilot bo'lsa, qo'shmaydi, lekin self-assess talab qilinishi mumkin. Ma'lumot Play Console → Payments profile → "Uzbekistan tax info" bo'limiga kiritiladi.
  - Dasturchi **O'zbekistondan tashqarida** bo'lsa: O'zbekistondagi xaridlar QQSini Google hisoblaydi va to'laydi.
- **Apple:** 2020-04-14 va 2023-01-27 yangiliklarida O'zbekiston narxlari QQS sababli o'zgartirilgan, "proceeds … calculated based on the tax-exclusive price". 2023 yangiligida "proceeds will increase for local developers selling in … Uzbekistan" deyilgan. [R] Apple O'zbekiston QQSini kim nomidan to'lashi (mahalliy dasturchi uchun) aniq yozilgan joy **topilmadi** [X]. https://developer.apple.com/news/?id=04142020a ; https://developer.apple.com/news/?id=g8dce2t4
- **Click/Payme (to'g'ridan-to'g'ri sotuv):** QQS, aylanma solig'i va fiskal chek majburiyati sotuvchida (LabGuide yuridik shaxsi yoki YaTT) [K]. Aniq rejim (QQS yoki aylanmadan olinadigan soliq) soliq maslahatchisi bilan tasdiqlanishi kerak [X].

---

## 6. UZS bo'yicha alohida bo'lim (egasining kuzatuvi bo'yicha)

Egasi kuzatgan: o'g'li O'zbekistonda Android telefonda Google Play orqali Claude ilovasida obuna oynasini ochgan va narxlar so'mda (UZS) ko'rsatilgan.

### Google Play
| Savol | Javob |
|---|---|
| Xaridor valyutalari ro'yxatida O'zbekiston/UZS bormi? | Rasmiy ro'yxat "Supported locations for distribution to Google Play users" sahifasida: https://support.google.com/googleplay/android-developer/answer/138294 va https://support.google.com/googleplay/android-developer/answer/10532353 jadvalni alohida ilovaga yo'naltiradi: https://play.google.com/supported-locations?hl=en. Bu sahifa jadvalni JavaScript/RPC orqali yuklaydi. Uning statik HTML va JS to'plamida faqat umumiy lokal formatlari bor (`"uz" → "UZS"` raqam formati), mamlakat qatori yo'q. Shuning uchun **UZS xaridor valyutasi ekani rasmiy manbada mashinada tasdiqlanmadi [X]**. Egasining kuzatuvi UZS qo'llab-quvvatlanishiga **kuchli dalil** [K]. Brauzerda yuqoridagi havolani ochib "Uzbekistan" qatorini ko'rib qo'yish tavsiya etiladi (1 daqiqalik ish). |
| Bilvosita rasmiy dalillar | (1) O'zbekiston "tax-inclusive pricing" mamlakatlari ro'yxatida bor [R] (answer/138000). (2) Google: "When Google adds support for a new buyer currency in a country where you already distribute your app, we'll automatically generate a price…". Obunalarda bu "New countries/regions" narxidan hosil qilinadi [R] (answer/1169947). (3) Mahalliy valyuta bo'lmasa narx USD yoki EUR bo'ladi [R] (answer/6334373). Egasi USD emas, UZS ko'rgani bu holat emasligini bildiradi [K]. |
| Dasturchi narxni UZS da belgilay oladimi? | Google: Play bazaviy narxni har mamlakat valyutasiga o'giradi, mamlakat bo'yicha narxni qo'lda o'zgartirish mumkin. Har mamlakat valyutasi "set and can't be changed" [R]. Demak O'zbekiston uchun UZS qo'llab-quvvatlansa, O'zbekiston qatoriga **UZS da** narx qo'yiladi. Bazaviy (standart) narx esa merchant valyutasida (O'zbekistondagi merchant uchun **USD**) [R] (answer/9306917). O'zbekiston qatori Play Console'da UZS da ko'rsatilishi Console'da tekshirilmadi [X]. |
| O'zbekistonda Play'da qaysi to'lov usullari ishlaydi? | "Other countries" qoidasi: **Visa, Mastercard, American Express, Discover** [R]. Humo/Uzcard ro'yxatda **yo'q** [X]. Operator billing **ko'rsatilmagan** [R]. https://support.google.com/googleplay/answer/2651410 |
| Pulni olish | O'zbekistondagi merchant uchun to'lov USD da (standart valyuta) [R]. O'zbek bankiga o'tkazish tafsilotlari tekshirilmadi [X]. |

### Apple App Store
| Savol | Javob |
|---|---|
| UZS bormi? | **Yo'q.** Apple "Currency codes" ro'yxatida UZS yo'q (masalan KZT bor) [R]. O'zbekiston "Rest of World — USD (WW)" guruhida [R]. Xaridor narxni USD da ko'radi [K, ikki rasmiy jadvaldan xulosa]. https://developer.apple.com/help/app-store-connect/reference/currency-codes/ ; https://developer.apple.com/help/app-store-connect/reference/financial-report-regions-and-currencies/ |
| Dasturchi UZS da narx qo'ya oladimi? | Yo'q. O'zbekiston storefronti uchun narx USD narx nuqtalaridan tanlanadi yoki bazaviy mamlakatdan avtomatik hosil qilinadi [R/K]. |
| To'lov usullari | Faqat "Most credit and debit cards" [R]. Operator billing yo'q, Humo/Uzcard nomi tilga olinmagan [X]. https://support.apple.com/en-us/111741 |

**Amaliy oqibat [K]:** Android'da O'zbekiston foydalanuvchisi narxni so'mda ko'radi, lekin Visa/Mastercard kartasi bilan to'laydi. iOS'da narx dollarda. Milliy Humo/Uzcard kartasi bor, lekin xalqaro kartasi yo'q foydalanuvchi ikkala do'konda ham to'lay olmasligi mumkin. O'zbekiston bozorida B2B va veb kanali (Click/Payme) muhimligi shundan kelib chiqadi.

---

## 7. LabGuide uchun tavsiya

### A-variant — Do'kon billingi + B2B veb kanali (tavsiya etiladi)
- iOS: StoreKit 2 auto-renewable subscription. Android: Play Billing. Flutter'da `in_app_purchase` paketi ishlatiladi; mavjud `PurchaseAdapter` va `verify-purchase` Edge Function ulanadi.
- Laboratoriya va kollejlar: shartnoma va hisob-faktura, to'lov Click/Payme/bank orqali. Server `entitlements` jadvaliga `source='b2b'` bilan yoziladi. Apple'da bu 3.1.3(c), Google'da consumption-only qoidasiga moslanadi (ilova ichida sotuv tugmasi va narx yo'q).
- **Afzallik:** policy xavfi past, global bozor, avtomatik narxlash, sinov, offer va promo kodlar. B2B Humo/Uzcard muammosini qisman yopadi.
- **Xavf:** 15% komissiya. Xalqaro kartasi yo'q jismoniy shaxslar sotib ololmaydi. O'zbekistondagi Play merchant QQSni o'zi to'laydi.

### B-variant — Faqat veb-sotuv (Click/Payme/Uzum) + ilovalar faqat "kirish"
- Android: consumption-only, policy bo'yicha ruxsat [R]. iOS: 3.1.3(b) IAP ham bo'lishini talab qiladi va LabGuide reader app emas, shuning uchun iOS'da **rad etish xavfi yuqori** [K].
- **Afzallik:** Humo/Uzcard bilan to'lash mumkin, komissiya past, narx UZS da.
- **Xavf:** iOS'da qabul qilinmasligi mumkin. Ilova ichida "saytda sotib oling" deyish taqiqlangan, natijada konversiya past. Rekurrent yechish va fiskalizatsiya o'zingizda.

### C-variant — Gibrid (A + veb-sotuv jismoniy shaxslarga ham)
- Ilovada IAP/Play Billing. Veb-saytda ham Click/Payme orqali obuna sotiladi. Server ikkalasini birlashtiradi. Ilova ichida veb-saytga havola yoki eslatma yo'q, aloqa faqat ilovadan tashqarida (email, Telegram).
- **Afzallik:** milliy kartalar va do'kon qamrovi birga.
- **Xavf:** ikki billing (refund, bekor qilish, ikki marta to'lash). Google aralash model bo'yicha aniq FAQ tasdig'i topilmadi [X].

### Birinchi qadamlar
1. Brauzerda https://play.google.com/supported-locations?hl=en sahifasini ochib, "Uzbekistan" qatorini tekshirish (UZS, price range) va skrinshotni saqlash.
2. Yuridik shaxs/YaTT holatini aniqlash. Play'da O'zbekistondagi merchant QQSni o'zi to'laydi (answer/138000), shuning uchun soliq maslahatchisi bilan rejimni tasdiqlash.
3. Apple Developer Program (Organization, D-U-N-S) va Paid Apps Agreement. O'zbek bank hisobini App Store Connect'da qo'shib ko'rish, rad etilsa muqobil yo'l izlash.
4. Play Console: Payments profile → "Uzbekistan tax info"; subscription product, base plan va bepul sinov offer yaratish.
5. Narx: bazaviy USD narxni tanlash, O'zbekiston uchun alohida (pastroq) narx qo'yish (Play: UZS, Apple: USD narx nuqtasi).
6. `verify-purchase` Edge Function'ni ulash: App Store Server API, Server Notifications V2, Google Play Developer API va RTDN (Pub/Sub). Refund va revoke `entitlement_apply()` ga yo'naltiriladi.
7. B2B: 3.1.3(c) asosida shartnoma shabloni, server tomonida `b2b` manbali entitlement va tashkilot kodi bilan kirish. Ilova ichida narx ko'rsatilmaydi.
8. (Ixtiyoriy, C-variant) Payme Subscribe API va Click Merchant API sandbox; fiskalizatsiya talabini tekshirish.

---

## Tasdiqlanmagan bandlar (ro'yxat)
- Google Play xaridor valyutasi sifatida UZS: rasmiy jadval JS'da, mashinada o'qilmadi (egasining kuzatuvi bor).
- Humo/Uzcard kartalari App Store yoki Google Play'da ishlashi.
- O'zbek bankiga Apple/Google to'lovini chiqarish tafsilotlari.
- Apple O'zbekiston QQSini mahalliy dasturchi uchun kim to'lashi.
- Google Play obunalari uchun oilaviy bo'lishish.
- Managed Google Play'da pullik ommaviy litsenziya.
- Click/Uzum orqali rekurrent (avtomatik) yechish. Payme'da token bor, lekin foydalanuvchisiz yechish aniq yozilmagan.
- Mahalliy savdoda fiskal chek majburiyatining aniq qonuniy moddasi.
