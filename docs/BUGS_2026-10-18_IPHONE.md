# iPhone xatolari — 2026-10-18 (TestFlight, ~1 kunlik build)

Egasi haqiqiy iPhone'da ikki xatoni xabar qildi. Quyida — har birining
aniq sababi, tuzatish va regressiya testlari.

## 1. Scroll "orqaga tushib ketadi"

> "Yuqoriga surganimda, u yana pastga qaytib tushadi" — Lab tabi (hero
> karta "Kalibrlash va metodika" + ro'yxat), "Ali" guruh sahifasi (QR
> taklif paneli, "O'quv rejasi", "Topshiriqlar").

### Qayta hosil qilish

Widget testda haqiqiy iPhone o'lchamlari: 390×844, DPR 3, notch (47/34),
`TargetPlatform.iOS` → `BouncingScrollPhysics`. Ro'yxat oxirigacha
surib, so'ng yana yuqoriga tortib (overscroll) qo'yib yuborilganda:

| Sahifa | Kutilgan offset (oxiri) | Tuzatishdan oldin |
|---|---|---|
| Lab | 1107 | 915 (≈190 px pastga tushdi) |
| Bosh | 1122 | 956 |
| O'rganish | 1663 | 1510 |
| Guruh sahifasi | 541 | 358 |

Har yangi tortishda kontent yana pastroqqa tushardi (1107 → 1040 → 988 …)
— aynan egasi ko'rgan holat.

### Asosiy sabab

`LgPage` katta sarlavhasi `CollapseHysteresis` (14 px) bo'yicha yig'iladi
va kengayadi; sarlavha ro'yxat USTIDA turadi, shuning uchun uning holati
ro'yxat viewport balandligini (~75 px) va `maxScrollExtent` ni
o'zgartiradi.

1. **Bounce teskari scroll deb sanalardi.** iOS'da ro'yxat oxiridan
   cho'zilgan (overscroll) pozitsiya qo'yib yuborilgach fizika uni
   orqaga qaytaradi — bu manfiy `scrollDelta` lar. `UserScrollNotification`
   yo'nalishi ballistik harakat tugaguncha "foydalanuvchi" bo'lib turgani
   uchun gisterezis buni "foydalanuvchi yuqoriga scroll qildi" deb
   hisoblab, sarlavhani KENGAYTIRARDI.
2. Kengayish viewportni kichraytirib `maxScrollExtent` ni oshiradi;
   ishlab turgan `BallisticScrollActivity` yangi o'lchamlar bilan qayta
   boshlanadi va bounce'ning manfiy tezligini ro'yxat ichida davom
   ettiradi — kontent foydalanuvchi qo'yib yuborgan joydan PASTGA
   "tushib" ketadi.
3. Ikkinchi yo'l: ro'yxat oxiriga yaqin sarlavha yig'ilsa, `maxScrollExtent`
   sarlavha balandligiga kamayadi va joriy offset yangi chegaradan oshib
   qoladi → fizika uni qaytaradi → (1)-band → kengayish → tebranish.

Suzuvchi pastki menyu (`AppShell`) ham shu gisterezisdan foydalanadi;
u layoutni o'zgartirmaydi, lekin bounce uni ham behuda kengaytirardi.

### Tuzatish (`lib/design/widgets/collapse_hysteresis.dart`)

* Faqat chegaralar (`minScrollExtent..maxScrollExtent`) ICHIDAGI harakat
  hisoblanadi: `delta = clamp(pixels) − clamp(pixels − delta)`.
  Overscroll va bounce — fizika, foydalanuvchi yo'nalishi emas.
* Yig'ilish natijasida offset yangi chegaradan (`max − sarlavha`) oshib
  ketadigan bo'lsa, sarlavha yig'ilmaydi (pozitsiya tuzatilmaydi).
* `LgPage` va `AppShell` `minScrollExtent` ni ham beradi.

Scroll imkoniyatlari o'chirilmagan: bounce, fling, sarlavha va panelning
ixchamlashuvi avvalgidek ishlaydi.

### Testlar

* `test/widget/scroll_snapback_test.dart` — Lab, Bosh, O'rganish va guruh
  sahifasi (ustoz, QR taklif, 4 ta topshiriq), iOS fizikasi: ostona
  atrofida sekin tortishlar (qo'yilgan offset saqlanadi), oxirida
  4 marta overscroll (offset = oxiri, viewport o'zgarmaydi), fling, va
  oxirgi kontent suzuvchi panel (Lab tugmasi bilan) ustida to'liq
  ko'rinadi. Tuzatishsiz 5 testning 5 tasi yiqiladi.
* `test/unit/core_logic_test.dart` — overscroll/bounce e'tiborsiz,
  tepadagi overscroll, chegarani kesadigan yig'ilish yo'q.

## 2. "Talaba sifatida testga qo'shila olmayman"

Egasi "Ali" guruhining ustozi edi, keyin talaba sifatida sinab ko'rdi.
Har bir ehtimoliy yo'l kod va mahalliy Worker (`wrangler dev --local`,
`dev/local.ts`, migratsiyalar) bilan tekshirildi.

| Holat | Avval | Sabab | Endi |
|---|---|---|---|
| Ustoz o'z guruhi kodini / test QR'ini ochdi (o'sha hisob) | "Guruhga qo'shildingiz" va ustoz sahifasi — test yechilmaydi, sabab aytilmaydi | Server a'zoni qayta qo'shmaydi (`200 {group_id}`), ustoz ustozligicha qoladi | Aniq panel: **"Siz bu guruhning ustozisiz"** + izoh, "Ustoz sifatida ochish" / test bilan kelganda "Talaba ko'rinishida sinash", "Boshqa hisob bilan kirish". Server javobida `role` va `already_member` |
| Profilda rol "ustoz"→"talaba" almashtirildi | Xuddi yuqoridagidek | Ilovadagi rol server huquqi emas (a'zolik guruh bo'yicha) | Panel matni buni aytadi |
| Ustoz testni talaba ko'zi bilan ko'rmoqchi | Imkoni yo'q edi | — | Ustoz test sahifasida **"Talaba ko'rinishida sinash"**: xuddi shu savollar va vaqt, sessiya faqat xotirada, serverga hech narsa yuborilmaydi; oxirida "Sinov tugadi: X / Y" |
| Ikkinchi hisob, taxallusda o'zbekcha apostrof (G'ayrat, O'tkir) | **400 → "Server ma'lumotni qabul qilmadi — maydonlarni tekshiring"** | iPhone Smart Punctuation `'` ni `’` (U+2019) ga aylantiradi; server `NICK_RE` faqat ASCII `'` ni qabul qilardi | Server va ilova `’ ‘ ʻ ʼ \` ´ ′` ni `'` ga keltiradi (yagonalik ham shunga ko'ra) |
| Taxallusda emoji / `!` / chiziqcha bilan boshlanish | Umumiy "Server ma'lumotni qabul qilmadi" | `invalid_nickname` umumiy `invalid` ga tushardi | Ilova yuborishdan oldin server qoidasi bilan tekshiradi; aniq matn `classesNicknameInvalid` |
| Kod kichik harf / bo'shliq / chiziqcha bilan | Ishlaydi | — | Testlar bilan mustahkamlandi |
| Kodda 0, O, 1, I (qo'lda noto'g'ri o'qilgan) | "Bu kod bilan guruh topilmadi" | Alifboda bu belgilar yo'q | "Kodda 0, O, 1 va I belgilari bo'lmaydi…" |
| Guruh to'la (200) | "Juda ko'p so'rov" | `group_full` 429 umumiy `rateLimited` ga tushardi | "Guruh to'lgan (200 kishi) — ustozingizga ayting" |
| Band taxallus, so'kinish filtri | Aniq matn bor edi | — | O'zgarmadi; 30 ta keng tarqalgan o'zbek ismi filtrdan o'tishi Worker testida |
| Tarmoq xatosi / sessiya tugagan / limit | `errNetwork` / `errSessionExpired` / `errRateLimited` | — | Testda tasdiqlandi |
| Yangi o'rnatilgan ilova (ikkinchi telefon), QR → "Ilovada ochish" | Onboarding'ga yo'naltirilib, **kod yo'qolardi** | Redirect `/j` ni faqat onboarding tugagan holatda qayta ishlardi | Taklif eslab qolinadi, onboarding tugagach qo'shilish ekrani kod va test bilan ochiladi |
| Rol avtomatik "talaba" | Ishlaydi (rol tanlanmagan bo'lsa) | — | Ustozning o'z guruhida rol o'zgartirilmaydi |

### Ishlab chiqarish sozlamasi

* Ilova API manzili: `LG_API_URL` (`--dart-define`), CI'da standart
  `https://labguide-api.davlatsudekspert.workers.dev` — TestFlight
  (`flutter build ipa` / `--config-only`) ham uni oladi.
* `curl …/v1/health` → `200 {"ok":true,"api":1}`;
  `…/v1/auth/providers` → `200 {"google":true,"apple":true,…}`;
  `POST …/v1/groups/join` (tokensiz) → `401 unauthorized` — endpoint
  ochiq va ishlaydi.
* **Deploy kerak:** Worker o'zgarishi (apostrof normallashuvi, `role`)
  ishlab chiqarishga `wrangler deploy` bilan chiqadi; ilova tomonidagi
  tekshiruvlar eski Worker bilan ham ishlaydi (ustoz guruhi ilovada
  guruhlar ro'yxatidan aniqlanadi, apostrof ilovada ham almashtiriladi).

### Testlar

* Worker: `cloudflare/test/groups.test.ts` — "qo'shilish: iPhone xatolari"
  (6 ta test: ustoz o'z guruhiga, ikkinchi hisob, kod variantlari,
  apostroflar, ismlar va so'kinish filtri, `invalid_nickname`).
* Mahalliy e2e: `tool/e2e/classroom_e2e.mjs` 9b-qadam;
  `test/integration/classroom_local_worker_test.dart` (haqiqiy HTTP).
* Widget: `test/widget/classroom_join_iphone_test.dart` — ustoz o'z kodi
  (Profilda rol "talaba"), ro'yxat yuklanmagan holat, test QR →
  talaba ko'rinishida sinash (hech narsa yuborilmaydi), ikkinchi hisob +
  `’`, noto'g'ri taxallus va 0/O/1/I kod, onboarding'dan keyingi taklif,
  server xatolari matni.
