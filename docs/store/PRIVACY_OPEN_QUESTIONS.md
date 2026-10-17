# Maxfiylik siyosati — ochiq savollar (ichki, e’lon qilinmaydi)

`docs/store/PRIVACY_POLICY.md` 2026-10-17 da kodga qarab yangilandi (`cloudflare/src`,
`cloudflare/migrations` 0001–0009, `lib/`). Siyosatdan olib tashlangan ichki “Eslatma” bloki
mazmuni va kodda javobi yo‘q savollar shu yerda. Siyosat matni faqat kod qiladigan narsani aytadi;
quyidagilar **egasi yoki yurist qarori** — taxmin bilan yozilmagan.

## A. Egasi tasdiqlashi kerak (e’lon qilishdan oldin)

1. **Sana va aloqa.** Kuchga kirish sanasi `2026-10-17` va `labguide@nfcstore.uz` — taklif qilingan
   qiymatlar. Manzil Cloudflare Email Routing orqali egasining **Gmail** qutisiga yo‘naltirilishi
   (`lib/core/contact.dart` izohi) siyosatda yozilgan — haqiqatan shundayligini va sinov xati
   yetib borishini tekshiring. Boshqa pochta bo‘lsa, siyosatdagi “Gmail” qatorlarini o‘zgartiring.
2. **Ma’lumotlar operatori kim.** Siyosatda egasining ismi/tashkilot nomi va manzili yo‘q (faqat
   “LabGuide egasi” va email). Do‘konlar va Google OAuth “Developer” nomini alohida so‘raydi;
   qonun operatorni ko‘rsatishni talab qilishi mumkin — kimni (jismoniy shaxs, YaTT, MChJ)
   yozishni egasi hal qiladi.
3. **Brevo.** `wrangler.toml` da `EMAIL_PROVIDER = "resend"`; Brevo faqat zaxira sifatida kodda bor.
   Brevo umuman ishlatilmasa — siyosatdan olib tashlash mumkin (hozir “ixtiyoriy zaxira” deb
   yozilgan, bu kodga mos).
4. **Google / Apple kirishi do‘kon buildida yoqilganmi.** Siyosat ularni “o‘zingiz tanlasangiz”
   deb yozadi — yoqilmagan bo‘lsa ham to‘g‘ri, lekin Google OAuth “In production” uchun siyosat
   va bosh sahifa havolalari kerak (`site/`).

## B. Huquqiy (yurist bilan; bu huquqiy maslahat emas)

5. **O‘zbekiston, “Shaxsga doir ma’lumotlar to‘g‘risida”gi qonun (O‘RQ-547).** Qonun O‘zbekiston
   fuqarolarining shaxsiy ma’lumotlarini internetda qayta ishlashda ularni O‘zbekiston hududidagi
   texnik vositalarda saqlashni va ma’lumotlar bazasini davlat reyestrida ro‘yxatdan o‘tkazishni
   talab qiladi. Server Cloudflare D1, joylashuv hududi **EEUR** (Sharqiy Yevropa) — siyosatda bu
   neytral fakt sifatida ochiq yozilgan. Muvofiqlik, reyestr va zarur bo‘lsa ma’lumotni mahalliy
   saqlash bo‘yicha qaror — yuristda.
6. **“EI” (Yevropa Ittifoqi) so‘zi olib tashlandi.** D1 baza joylashuv *maslahati* (location hint)
   `EEUR` bilan yaratilgan, `jurisdiction = "eu"` bilan emas; EEUR hududi faqat EI davlatlaridan
   iboratligi kodda kafolatlanmagan. EI deb yozish kerak bo‘lsa — Cloudflare hujjati bilan
   tekshiring yoki bazani EU yurisdiksiyasi bilan qayta yarating.
7. **Google “Limited Use” bayonoti.** Google OAuth tekshiruvi ko‘pincha shu jumlani so‘raydi:
   “LabGuide’s use and transfer of information received from Google APIs adheres to the Google API
   Services User Data Policy, including the Limited Use requirements.” Kod bunga mos (faqat `sub`,
   `email`, `email_verified`; token saqlanmaydi, uzatilmaydi), lekin bu majburiyat — qo‘shishni
   egasi hal qiladi. Siyosatda hozir faktik ekvivalenti bor (3-bo‘lim oxiri).
8. **Rozilik va huquqlar.** Ilovada kirishdan oldin “shartlar va siyosatni qabul qilaman” belgisi
   bor (`authConsent`). Ma’lumotga kirish/nusxa olish, tuzatish va e’tiroz huquqlari, javob
   muddati — siyosatda va’da qilinmagan (eksport vositasi yo‘q). Qonun talab qilsa, matn qo‘shing.
9. **Yosh chegarasi.** Play “Target audience” 18+ deb belgilangan (PLAY_CONSOLE_UPLOAD.md), siyosat
   esa faqat “bolalarga mo‘ljallanmagan” deydi. Talabalar orasida 18 yoshgacha bo‘lishi mumkin —
   aniq minimal yoshni (13/16/18) egasi tanlaydi.
10. **Foydalanish shartlari.** Ilovada “Foydalanish shartlari — yakuniy matn tayyorlanadi”. Google
    OAuth branding sahifasi shartlar havolasini (ixtiyoriy) so‘raydi; `site/` da shartlar sahifasi
    yo‘q.

## C. Jarayon (kodda vosita yo‘q)

11. **Email orqali hisobni o‘chirish.** Siyosat va `site/delete-account/` email bilan so‘rovni
    taklif qiladi (“qo‘lda ko‘rib chiqiladi”). Admin panelda **hisobni o‘chirish tugmasi yo‘q** —
    egasi buni `wrangler d1 execute` bilan qo‘lda (auth.ts `deleteAccount` dagi barcha jadvallar
    tartibida) qilishi yoki alohida admin endpoint qo‘shishi kerak. Javob muddati (masalan, 30 kun)
    va shaxsni tasdiqlash usuli (shu emaildan yozish yetarlimi) yozilmagan.
12. **Ilova ichidagi shikoyatlar va jurnal muddati.** `complaints` matni avtomatik o‘chirilmaydi
    (hisob o‘chirilganda faqat `user_id = NULL`); `audit_log` va `admin_grants` ham muddatsiz.
    Siyosat buni ochiq aytadi. Saqlash muddatini (masalan, 1–2 yil) belgilash va tozalashni
    qo‘shish — egasi qarori (kod o‘zgarishi kerak).
13. **labguide@nfcstore.uz ga kelgan xatlar** Gmail’da qancha saqlanishi belgilanmagan.
14. **D1 tiklash nusxalari (Time Travel).** Siyosat “o‘chirilgan ma’lumot avtomatik tiklash
    nusxalarida cheklangan muddat qolishi mumkin” deydi, aniq muddatni yozmaydi: Cloudflare
    hujjatiga ko‘ra u tarifga bog‘liq (Workers Free — 7 kun, Paid — 30 kun). Hisob tarifini
    tekshirib, kerak bo‘lsa aniq muddatni siyosatga qo‘shing. Qo‘lda eksport/zaxira olinsa — ular
    ham shu siyosatga bo‘ysunishi kerak.
15. **To‘xtatilgan hisob.** To‘xtatilgan foydalanuvchi ilovaga kira olmaydi, demak ilovada hisobni
    o‘chira olmaydi — faqat email orqali (11-band).

## D. Kodda / boshqa hujjatlarda nomuvofiqlik (bu o‘zgarishda tegilmagan)

16. `lib/core/contact.dart` `privacyPolicyUrl` hali GitHub’dagi `.md` ga ishora qiladi. `site/`
    joylangach `https://nfcstore.uz/labguide/privacy/` ga almashtiring (App Store Connect / Play
    Console maydonlari bilan bir xil bo‘lsin).
17. Ilova matnlari (`lib/l10n/app_*.arb`): `privacyBody` faqat Resend va “oxirgi faol kun”ni
    aytadi (endi daqiqagacha yaxlitlangan faollik vaqti ham saqlanadi; Google/Apple, murojaatlar,
    shikoyatlar yo‘q); `accountDeleteBody` “biriktirilgan rasmlar”ni aytadi, Cloudflare serveri esa
    biriktirma qabul qilmaydi. Qisqa ilova matnini siyosatga moslang.
18. `docs/APPLE_2026_REQUIREMENTS.md` Age rating jadvalida “Advertising — Yes (hamkor reklamalari)”
    deyilgan — do‘kon buildida hamkor reklamasi kompilyatsiyadan chiqarilgan
    (`lib/core/build_flags.dart`), APP_STORE.md 7-bo‘limi shunga moslandi. `ios/Runner/PrivacyInfo.xcprivacy`
    ni ham App Privacy jadvali bilan solishtiring.
19. Kod xati `labguide@alideveloper.uz` (`cloudflare/src/email.ts` standart yuboruvchi) dan keladi —
    foydalanuvchi uchun `nfcstore.uz` bilan bir xil domen yaxshiroq bo‘lishi mumkin (maxfiylikka
    ta’sir qilmaydi).
20. Hamkor (reklama) jadvallari (`partners`, `partner_requests`, `partner_events`) va
    tekshiruvchi qarorlari (`content_reviews`) sxemada bor, endpointlari `501` yoki do‘kon buildida UI yo‘q —
    siyosatda tilga olinmagan. Ishga tushirilsa, siyosat va do‘kon deklaratsiyalarini yangilang.
