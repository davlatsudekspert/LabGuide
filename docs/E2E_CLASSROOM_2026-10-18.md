# Ustoz–talaba testi: to‘liq e2e sinov (2026-10-18)

Egasi so‘rovi: “Ustoz–talaba testini o‘zing ishlatib ko‘r va ishlashini tekshir.” Sinov
**mahalliy Cloudflare Worker + D1** ga qarshi **haqiqiy HTTP** orqali o‘tkazildi: avval skript
bilan (server qoidalari), so‘ng ilovaning o‘zi (haqiqiy `CloudflareLabBackend`, uz, ekran
rasmlari bilan). Keyin egasining qo‘shimcha talablari bo‘yicha QR orqali qo‘shilish, ustozning
jonli natijalari va “Katta ekran” qo‘shildi va xuddi shu yo‘l bilan sinaldi.

## 1. Muhit

```sh
cd cloudflare && npm ci
npx wrangler d1 migrations apply labguide-local --local -c dev/wrangler.local.toml
npx wrangler dev --local --port 8799 -c dev/wrangler.local.toml   # dev/local.ts
```

* Kirish: email kodi. `dev/local.ts` xat yubormaydi, kodni `GET /__outbox` beradi. Bu yo‘l
  **faqat** mahalliy entry’da; deploy qilinadigan `src/index.ts` da yo‘q — buni
  `cloudflare/test/security.test.ts` (“ishlab chiqarish entry’sida … /__outbox yo‘q”) tekshiradi.
  Ishlab chiqarish autentifikatsiyasiga hech narsa qo‘shilmadi.
* Skript: `node tool/e2e/classroom_e2e.mjs` (faqat `127.0.0.1/localhost` ga ruxsat beradi).
* Ilova: `LG_LOCAL_API=http://127.0.0.1:8799 flutter test tool/screenshots/walk_classroom_live_test.dart --update-goldens`
  (LG_LOCAL_API bo‘lmasa o‘tkazib yuboriladi).
* Mahalliy OTP limiti (IP bo‘yicha soatiga 60) bir necha marta ketma-ket ishga tushirganda
  tugaydi — faqat mahalliy bazada: `npx wrangler d1 execute labguide-local --local -c dev/wrangler.local.toml --command "DELETE FROM rate_limits"`.

## 2. Skript bilan (server qoidalari) — 78 tekshiruv, hammasi o‘tdi

| Qadam | Natija |
|---|---|
| Ustoz kod bilan kiradi → rol `teacher` → `POST /v1/me/teacher` → guruh | ✅ (ustoz bo‘lmagan — `403 teacher_role_required`) |
| Talabalar A (taxallus “Lola”), B (kichik harf + chiziqcha bilan kod), C qo‘shiladi | ✅; noto‘g‘ri kod — 404; email-taxallus — 400; band taxallus (“LOLA”) — `409 nickname_taken` |
| Talaba kodni ko‘rmaydi; boshqa talabalarni ko‘rmaydi (faqat ustoz + o‘zi); begona — 404 | ✅ |
| “Guruhga topshirish”: `deck_id` + `day_id` + 5 savol + muddat + `reveal=after_due` | ✅; talaba/begona topshiriq bera olmaydi (403/404); muddatsiz `after_due` va o‘tgan muddat — 400 |
| Oddiy topshiriq (10 daqiqa, darhol natija) | ✅; boshlamasdan yuborish — `409 time_over` |
| A — 5/5, B — 2/5; javob: ball bor, `correct: null` | ✅; noto‘g‘ri javoblar soni — 400; ikkinchi yuborish — `409 already_submitted` |
| Maxfiylik: talaba faqat o‘z natijasini, guruh natijalarida ham faqat o‘zini; kalit — 403 | ✅ |
| Ustoz: hamma natija, taqsimot (40%, 100%), eng qiyin savollar, kalit, kim boshlagan (`/progress`) | ✅; talaba `/progress` — 403 |
| Ustoz yakunlaydi → talabada `correct` ochiladi; yakunlangan testni boshlash/yuborish — 409 | ✅ |
| Qisqa muddatli test: muddatdan keyin boshlash va yuborish — `409 past_due`; muddat o‘tgach javoblar o‘zi ochiladi | ✅ |
| Limitlar: kod taxmini 10×404 → 429; kodni 60 s ichida qayta so‘rash — 429 | ✅ |
| Ustoz chiqaradi; talaba chiqadi; ustoz o‘z guruhidan chiqolmaydi | ✅ |
| Hisob o‘chirish: talaba natijasi, urinishi, a’zoligi, sessiyasi, profili o‘chadi; ustoz o‘chsa — guruh, topshiriqlar, kalitlar va barcha natijalar | ✅ (D1 so‘rovi bilan tekshirildi) |

Maxfiylik siyosatiga muvofiq: guruhdan chiqqan/chiqarilgan talaba natijasi hisob yoki guruh
o‘chirilguncha ustozda qoladi (siyosatda shunday yozilgan, server ham shunday).

## 3. Ilova UI (haqiqiy HTTP, uz) — ekran rasmlari

Rasmlar: `tool/screenshots/out/walk/classroom_live_uz/` (git’da emas — qayta yasaladi).

| № | Rasm | Nima |
|---|---|---|
| 01–04 | `topshirish_ekrani`, `sozlandi_5_savol`, `yuborildi`, `yuborilganlar_royxati` | Ustoz taqdimotdan “Guruhga topshirish” |
| 05–16 | `lola_*`, `bobur_*` | Talaba: Bosh sahifadagi test → boshlash → savol (izohsiz) → tasdiq → natija (ball, javoblar yopiq) |
| 17–21 | `ustoz_natijalar`, `ustoz_taqsimot`, `ustoz_eng_qiyin`, `yakunlash_tasdiq`, `yakunlandi` | Ustoz natijalari va **yangi** “Testni yakunlash” |
| 22–23 | `bobur_javoblar_ochildi`, `bobur_xatolar_tahlili` | Yakunlangach talabada javoblar va slayd havolalari |
| 24–25 | `kech_test_yakunlangan`, `kech_guruh_royxati` | Boshlamagan talaba: “Test yakunlandi” (avval “Boshlash” chiqardi) |
| 26–28 | `qr_taklif_paneli`, `qr_ustoz_topshiriq`, `qr_test_dialog` | QR (havola), “Test QR”, “Katta ekran” tugmalari |
| 29–33 | `qr_yangi_1…5` | Yangi foydalanuvchi: havola → kirish taklifi → email → taxallus → test → 1-savol |
| 34 | `qr_kirgan_taxallus_tayyor` | Kirgan talaba: taxallus oldingi guruhdan oldindan to‘ldirilgan |
| 35–38 | `katta_ekran_1920x1080`, `katta_ekran_1280x720`, `katta_ekran_jonli_3_topshirdi`, `katta_ekran_yakunlandi_eng_qiyin` | Katta ekran: jonli reyting, “Yechmoqda…”, QR + kod, yakunlangach eng qiyin savollar |
| 39 | `qr_ustoz_natijalar` | Telefonda ustoz natijalari (taxalluslar, ball) |

### Skanerdan birinchi savolgacha bosishlar (o‘lchandi)

* **Kirgan talaba:** 2 bosish — “Qo‘shilish” (taxallus tayyor bo‘lsa) → “Boshlash”.
* **Yangi foydalanuvchi (email kodi):** 5 bosish — “Kirish” → shartlar belgisi → “Kod olish” →
  (6 raqam kiritilgach kod o‘zi tekshiriladi) → “Qo‘shilish” → “Boshlash”; yozish: email,
  kod, taxallus. Google/Apple bilan: “Kirish” → shartlar → “Google/Apple bilan” → (tizim
  oynasi) → “Qo‘shilish” → “Boshlash”.
* Telefon kamerasi QR’ni saytda ochadi; u yerdagi “Ilovada ochish” — yana bitta bosish.

## 4. Topilgan va tuzatilgan xatolar

1. **Deckdan berilgan testni ustoz yakunlay olmasdi.** “Muddat tugagach” tanlansa, javoblar
   faqat muddat o‘tgach ochilardi; `closeAssignment` serverda bor, ilovada chaqirilmasdi.
   Tuzatish: topshiriq sahifasida “Testni yakunlash” (tasdiq bilan). Test:
   `test/widget/topic_test_assign_test.dart`.
2. **Yakunlangan testda boshlamagan talabaga “Boshlash” chiqardi** (bosilsa — server xatosi).
   Endi “Test yakunlandi”; guruh ro‘yxatida ham. Test: o‘sha fayl.
3. **Qurilma soati oldinda bo‘lsa javoblar muddatdan oldin ochilardi** (server `correct: null`
   bersa ham lokal kalitdan). Endi server hal qiladi. Test: o‘sha fayl.
4. **QR faqat xom kodni saqlardi, ilovada skaner yo‘q** — kamera bilan skanerlagan talaba
   faqat matn ko‘rardi. Endi QR — havola (`labguide.nfcstore.uz/j/?c=KOD[&a=TEST]`), sayt
   sahifasi kodni katta ko‘rsatadi va “Ilovada ochish” (`labguide://app/j?...`); ilovada
   “Havolani qo‘yish”, kod maydoniga butun havola/taklif matni qo‘yilsa kod ajratiladi.
   Testlar: `test/unit/invite_link_test.dart`, `test/widget/classroom_qr_join_test.dart`,
   `python3 tool/site/check_site.py`.
5. **Taxallus takrorlanishi va so‘kinish** — ustoz (va katta ekran) natijalarni adashtirishi
   mumkin edi. Endi taxallus guruhda yagona va `moderation.ts` filtridan o‘tadi. Test:
   `cloudflare/test/groups.test.ts`.
6. **Ustoz natijalari qo‘lda yangilanardi.** Endi har 10 s o‘zi va pastga tortib yangilanadi.
7. **Katta ekranda ustozning shaxsiy eslatmasi (lokal ism) chiqib qolishi mumkin edi** —
   `memberLabel` lokal ismni qo‘shadi. Katta ekran faqat taxallus/“Talaba NN” ko‘rsatadi.
8. Taklif panelidagi yo‘riqnoma QR’ni tilga olmasdi — matn yangilandi (uz/ru/en).
9. Sinov vositasi: `wrangler dev` bo‘sh keep-alive ulanishni yopadi (“Connection closed before
   full header”); skript va ilova testi har so‘rovga yangi ulanish ochadi / bir marta qayta
   urinadi. Ilova kodi o‘zgartirilmadi; Cloudflare edge’da shunga o‘xshash uzilish bo‘lsa, ilova
   “Internetga ulanib bo‘lmadi — qayta urinish” ko‘rsatadi (haqiqiy qurilmada kuzatish kerak).

## 5. Qo‘shilgan imkoniyatlar (egasi talabi)

* **Test QR** (topshiriq sahifasida va katta ekranda): havola guruh kodi + test id; talaba
  kiradi → taxallus → qo‘shiladi → **test darhol ochiladi**. Rol tanlanmagan yangi
  foydalanuvchiga rol avtomatik “talaba” (alohida rol ekrani yo‘q).
* **Katta ekran** (`…/a/:aid/board`): gorizontal (lecture “aylantiraymizmi?” oynasi,
  eslab qolish bilan), to‘liq ekran, ekran o‘chmaydi (wakelock), shrift ekranga qarab
  (720p/1080p), har 5 s yangilanadi; har talaba bir qator: o‘rin, taxallus, holat
  (kutilmoqda / yechmoqda… / topshirdi), ball, sarflangan vaqt; qatorlar yangi natijada
  silliq o‘rin almashadi; yon panelda QR + kod (kechikkanlar uchun). “Muddat tugagach”
  testida faqat ball; eng qiyin savollar — ustoz yakunlagach. Faqat taxalluslar, email yo‘q.
  “x/N javob berildi” ko‘rsatilmaydi: server javoblarni faqat topshirilganda oladi (har
  javobni yuborish — bepul tarif yozuv limitiga og‘ir); o‘rniga “yechmoqda…” (`/progress`).

### Qo‘shimcha: variantli test (D-66, keyinroq)

Egasi savoli: “bir mavzuda hamma har xil savol oladimi?” — avval **yo‘q** edi (hammaga bir xil
to‘plam, faqat savollar va variantlar tartibi aralashardi). Endi “Guruhga topshirish”da
**“Har bir talabaga boshqa savollar”**: hovuz ≥ 2 × N bo‘lsa standart yoqiq, aks holda o‘chiq
va sababi yoziladi. Skriptga **6b-qadam** qo‘shildi (hovuz 12, har talabaga 4, 3 talaba):
server bergan to‘plam skriptdagi mustaqil hisob bilan bir xil, 3 talaba — 3 xil to‘plam, har
kichik mavzudan kamida 1 ta, begona savol id si bilan yuborish — `400 invalid_questions`, ustoz
natijalarida har talabaning `question_ids` si, eng qiyin savollar faqat ularni olganlar orasida.
Mahalliy Worker’da qayta ishga tushirildi: **97 tekshiruv, hammasi o‘tdi**. Dart mijoz ham
(`test/integration/classroom_local_worker_test.dart`) shu Worker bilan bir xil to‘plamni hisobladi.

## 6. Qilinmagan va sababi

* **Ilova ichidagi kamera skaneri (mobile_scanner)** qo‘shilmadi: yangi native plagin
  (Android CameraX + ML Kit, iOS AVFoundation/Vision, yangi `CAMERA` ruxsati) — bu muhitda
  Android/iOS build qilib tekshirib bo‘lmaydi (diskda joy yo‘q, macOS yo‘q), CI build’ini
  buzish xavfi bor. O‘rniga: telefonning o‘z kamerasi QR’ni o‘qiydi → sayt → “Ilovada ochish”,
  hamda “Havolani qo‘yish”. Kamera skaneri keyin alohida, CI build bilan qo‘shilishi mumkin.
* **Universal Links / App Links (https havola to‘g‘ridan-to‘g‘ri ilovani ochishi)**: iOS
  Associated Domains entitlement’i va Android `assetlinks.json` uchun imzo sertifikati
  barmoq izi kerak (Play App Signing) — bu muhitda yo‘q. Hozircha custom scheme
  (`labguide://app/j`) — entitlement talab qilmaydi.
* **Emailsiz “tezkor” hisoblar** — egasi qarori bilan bekor qilindi (talabalar ro‘yxatdan
  o‘tgan foydalanuvchi bo‘lishi kerak). Boshlangan migratsiya va endpointlar olib tashlandi;
  maxfiylik siyosatiga bunday matn qo‘shilmadi.
* Onboarding tugamagan (ilova birinchi marta ochilgan) qurilmada havola onboarding’dan keyin
  saqlanmaydi — talaba kodni sayt sahifasidan kiritadi.
* Push-bildirishnomalar (yangi test berilganda) — yo‘q; haqiqiy email (Resend) — mahalliy
  sinovda xat yuborilmaydi; Google/Apple kirish oynalari — mahalliy testda soxta provayder.
  Bularni faqat haqiqiy qurilmada TestFlight / ichki test build bilan tekshirish mumkin.
