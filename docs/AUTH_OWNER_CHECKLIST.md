# Kirish tizimi: faqat egasi bajaradigan ishlar

Qisqa ro‘yxat (audit 2026-10-24). Batafsil qadamlar: `docs/AUTH_SOCIAL_LOGIN.md`.
Bu yerda hech qanday sir qiymati yo‘q, faqat nomlar. Kod OAuth client ID va sozlamalarni o‘zgartirmaydi:
ularni faqat siz kiritasiz.

**Asosiy qoida (App Store 4.8):** iPhone’da Google tugmasi faqat “Sign in with Apple” bilan birga chiqadi.
Ilova buni o‘zi ta’minlaydi: Apple yo‘q buildda iPhone’da Google ham yashiriladi, faqat email-kod qoladi.
Shuning uchun iPhone’da Google kerak bo‘lsa, avval Apple’ni sozlang (2-band).

1. **Admin Gmail — 2 bosqichli himoya.** `ADMIN_EMAILS` dagi Gmail’da 2FA ni yoqing. Admin panel faqat email kod
   bilan ochiladi va sessiya 60 kun yashaydi, shuning uchun Gmail himoyasi — panel himoyasi.
2. **Apple (iOS) — Google’dan oldin yoki u bilan birga.**
   1. developer.apple.com → Identifiers → `uz.labguide.app` → **Sign in with Apple** imkoniyatini yoqing → Save.
   2. App Store provisioning profilini yangilang (qo‘lda imzoda `testflight` ni `apple_setup=true` bilan bir marta).
   3. Keys → **Sign in with Apple** kaliti → secretlar `APPLE_SIGNIN_TEAM_ID`, `APPLE_SIGNIN_KEY_ID`,
      `APPLE_SIGNIN_PRIVATE_KEY`.
   4. Services → *Sign in with Apple for Email Communication*: `alideveloper.uz` domeni va
      `labguide@alideveloper.uz` manzilini ro‘yxatdan o‘tkazing (“Hide My Email” manzillariga xat yetishi uchun).
   5. Faqat 1–2-qadamlardan keyin variable `LG_APPLE_SIGNIN=true`.
   6. Android’da Apple (Services ID, `LG_APPLE_SERVICE_ID`) hozir kerak emas — o‘z domeni talab qilinadi.
3. **Google consent screen → Production.** console.cloud.google.com → Google Auth Platform → Audience →
   **Publish app**; holat **In production** bo‘lsin. “Testing” holatida faqat 100 ta test foydalanuvchi kiradi va
   ruxsat 7 kunda tugaydi. Branding’da nom, support email, maxfiylik siyosati va shartlar havolalari bo‘lsin.
4. **Play App Signing SHA-1.** Play Console → App integrity → App signing → SHA-1 ni Google Cloud’da
   `uz.labguide.app` Android client sifatida qo‘shing (upload kaliti SHA-1 ham). Busiz Play’dan o‘rnatilgan ilovada
   Google kirishi “Kirib bo‘lmadi” beradi.
5. **iOS client ID — `GOOGLE_CLIENT_IDS` ga ham (ehtiyot chorasi).** Secret `GOOGLE_CLIENT_IDS` = Web client ID,
   so‘ng vergul bilan iOS client ID. Zarari yo‘q; iPhone’da `401 invalid_token` xavfini yo‘qotadi.
6. **CI variable’lari.** GitHub → Settings → Secrets and variables → Actions → *Variables*:
   - `LG_GOOGLE_CLIENT_ID` — Web client ID;
   - `LG_GOOGLE_IOS_CLIENT_ID` — iOS client ID, **faqat** `LG_APPLE_SIGNIN=true` bo‘lgan buildda;
   - `LG_APPLE_SIGNIN` — 2-band tugagach `true`.
   CI profilda Apple imkoniyatini topmasa `LG_APPLE_SIGNIN` ni o‘chiradi — endi bu iPhone’da Google’ni ham yashiradi.
   TestFlight job summary’da ikkala qator bo‘lishi kerak: “Sign in with Apple: entitlement …” va
   “Google (iOS): URL sxemasi …”.
7. **Server qayta joylanishi (deploy).** Kod xati endi ilova tilida (uz/ru/en) yuboriladi. Bu Worker yangilangandan
   keyin ishlaydi: Actions → LabGuide CI → `deploy_api` ni o‘zingiz ishga tushiring. Eski Worker ham ishlayveradi
   (xat o‘zbekcha keladi).
8. **Qurilmada tekshiring.**
   1. iPhone (TestFlight): avval Apple, keyin Google tugmasi; ikkalasi bir xil o‘lchamda. Apple yo‘q bo‘lsa — ikkalasi
      ham yo‘q, email-kod bor.
   2. Android (Play internal): test ro‘yxatida yo‘q Google hisob bilan kiring → rol ekrani ochiladi.
   3. Tilni Русский qiling, kod so‘rang → mavzu “LabGuide: код входа” (7-banddan keyin).
   4. Yangi o‘rnatish → `/j?c=` taklif havolasini oching → email ilovasiga o‘ting → ilovaga qayting va kiring →
      guruhga qo‘shilish ekrani ochiladi.
