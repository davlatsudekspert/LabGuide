# LabGuide server — Cloudflare Workers + D1

Egasi qarori (2026-10-10): server **Cloudflare Workers + D1** bepul tarifida,
email kodlari **Brevo** transactional API orqali (bepul — kuniga 300 xat).
Supabase kodi (`supabase/`) xavfsizlik qoidalari manbai sifatida qoladi.

> Holat: kod, testlar va CI tayyor. **Deploy qilinmagan** — buning uchun
> quyidagi “Egasi uchun qadamlar” kerak.

## Arxitektura

```
Flutter ilova ──HTTPS/JSON──▶ Worker `labguide-api` (cloudflare/src) ──▶ D1 `labguide-db`
   (CloudflareLabBackend)          │                                     (SQLite, EEUR)
                                   └──▶ Brevo API (faqat kirish kodi xati)
```

| Joy | Nima |
|---|---|
| `cloudflare/src/app.ts` | marshrutlar, umumiy xato ishlovi (ichki tafsilot chiqmaydi), CORS, kunlik tozalash (cron) |
| `cloudflare/src/auth.ts` | email OTP, sessiyalar, profil, admin TOTP, hisobni o‘chirish |
| `cloudflare/src/groups.ts` | guruhlar, a’zolik, mavzular, savol-javob belgilari, test sessiyalari, natijalar |
| `cloudflare/src/crypto.ts` | HMAC, SHA-256, AES-GCM, TOTP (faqat WebCrypto) |
| `cloudflare/src/email.ts` | Brevo yuboruvchi |
| `cloudflare/migrations/` | D1 sxemasi: `0001_auth`, `0002_classroom`, `0003_planned_ports` (faqat sxema) |
| `cloudflare/test/` | vitest + `@cloudflare/vitest-pool-workers` (haqiqiy workerd va lokal D1) |
| `lib/core/backend/cloudflare_backend.dart` | ilova adapteri `CloudflareLabBackend` |
| `test/unit/cloudflare_backend_test.dart` | adapter testlari (soxta HTTP) |

Ilova qaysi serverni ishlatishini build vaqtida biladi (`lib/main.dart`):
`--dart-define=LG_API_URL=https://…` berilsa — Cloudflare; aks holda
`LG_SUPABASE_URL/KEY` bo‘lsa — Supabase; ikkalasi ham bo‘sh — “server hali
ulanmagan” (mehmon rejimi va oflayn kontent o‘zgarmaydi).

Bepul tarif hisobdagi **barcha** Workerlar uchun umumiy (kuniga 100 000
so‘rov). Shuning uchun: ilova ochilganda sessiya tarmoqsiz tiklanadi (token
birinchi so‘rovda tekshiriladi), har endpoint bitta-ikkita D1 so‘rovi yoki
`batch`, tozalash kuniga bir marta (cron). Deploy faqat `labguide-api` nomiga
— hisobdagi boshqa Workerlarga tegilmaydi.

## Endpointlar (`/v1`)

Javoblar JSON. Xato: `{"error": "<kod>", ...}`; HTTP holati: 400 noto‘g‘ri
ma’lumot, 401 sessiya yo‘q, 403 ruxsat yo‘q, 404 topilmadi (yoki begona guruh —
borligi ham bildirilmaydi), 409 holatga zid (masalan, ikkinchi topshirish),
413/415 tana, 429 limit (`retry_after` soniya), 501 hali ko‘chirilmagan,
503 server sozlanmagan, 500 `internal` (tafsilotsiz).

### Auth va hisob

| Metod va yo‘l | Kim | Nima |
|---|---|---|
| `GET /v1/health` | hamma | `{ok:true}` |
| `POST /v1/auth/otp/request` `{email, language?}` | hamma | 6 raqamli kod Brevo orqali; `{retry_after:60, valid_for:600}` |
| `POST /v1/auth/otp/verify` `{email, code}` | hamma | `{token, user_id, expires_at}` (sessiya 60 kun) |
| `POST /v1/auth/logout` | sessiya | joriy tokenni bekor qiladi |
| `POST /v1/auth/logout-all` | sessiya | hamma qurilmalardan chiqish |
| `GET /v1/me` | sessiya | `{user_id, role, language, admin_account, aal, admin, reviewer}` |
| `PUT /v1/me/profile` `{role?, language?}` | sessiya | rol: `doctor/lab/student/teacher` (boshqasi — 400) |
| `DELETE /v1/me` | sessiya | hisob va unga bog‘liq hamma narsa o‘chadi |
| `GET /v1/auth/mfa` | admin hisobi | TOTP holati |
| `POST /v1/auth/mfa/enroll` | admin hisobi, faktor hali yo‘q | TOTP kalit va `otpauth://` URI |
| `POST /v1/auth/mfa/verify` `{code}` | admin hisobi | sessiya `aal2` bo‘ladi |

### Ustoz–talaba

| Metod va yo‘l | Kim | Nima |
|---|---|---|
| `GET /v1/groups` | sessiya | mening guruhlarim; kod faqat ustozga |
| `POST /v1/groups` `{name, display_name?}` | rol `teacher` | guruh (kod 8 belgi, `0/O/1/I` siz), ≤ 10 ta |
| `POST /v1/groups/join` `{code, display_name?}` | sessiya | taklif kodi (QR) bilan qo‘shilish |
| `DELETE /v1/groups/:g` | o‘sha guruh ustozi | guruhni o‘chirish |
| `POST /v1/groups/:g/leave` | talaba | guruhdan chiqish |
| `POST /v1/groups/:g/code` | ustoz | yangi kod (eski QR ishlamaydi) |
| `GET /v1/groups/:g/members` | a’zo | ustoz — hammani; talaba — ustozni va o‘zini |
| `DELETE /v1/groups/:g/members/:u` | ustoz | talabani chiqarish (ustozni emas) |
| `GET /v1/groups/:g/topics` | a’zo | ochilgan mavzular (o‘quv rejasi kun id) |
| `PUT /v1/groups/:g/topics/:day` | ustoz | mavzuni ochish |
| `DELETE /v1/groups/:g/topics/:day` | ustoz | mavzuni yopish |
| `GET /v1/groups/:g/marks[?day_id=]` | a’zo | ustoz — hammaniki; talaba — faqat o‘ziniki |
| `PUT /v1/groups/:g/marks` `{user_id, day_id, question_id, result, grade?}` | ustoz | savol-javob belgisi (`correct/partial/incorrect/skipped`, baho 1–5 ixtiyoriy) |
| `DELETE /v1/groups/:g/marks/:id` | ustoz | belgini o‘chirish |
| `GET /v1/groups/:g/assignments` | a’zo | test sessiyalari (qoralamani faqat ustoz ko‘radi); kalit yo‘q |
| `POST /v1/groups/:g/assignments` `{title, question_ids, correct_indexes, day_id?, due_at?, time_limit_minutes?, start?}` | ustoz | sessiya; `start:false` — qoralama |
| `POST /v1/assignments/:a/open` · `/close` | ustoz | sessiyani boshlash / yakunlash |
| `POST /v1/assignments/:a/start` | talaba | boshlanish vaqti (bir marta) + `server_now` |
| `POST /v1/assignments/:a/submit` `{answers}` | talaba | ball serverda; bir marta; vaqt chegarasi + 2 daqiqa |
| `GET /v1/assignments/:a/submissions` | a’zo | ustoz — hamma; talaba — faqat o‘zi |
| `GET /v1/groups/:g/submissions` | a’zo | xuddi shunday, guruh bo‘yicha |
| `GET /v1/assignments/:a/key` | ustoz | to‘g‘ri javoblar kaliti |

Ilovada `LabBackend` interfeysi o‘zgarmadi. Mavzular, belgilar, sessiyani
boshlash/yakunlash, kodni yangilash va guruhni o‘chirish hozircha faqat
`CloudflareLabBackend` sinfining qo‘shimcha metodlari
(`topics/openTopic/closeTopic`, `marks/putMark/deleteMark`,
`openAssignment/closeAssignment`, `rotateJoinCode`, `deleteGroup`;
`createAssignment(dayId:, start:)`). Ekranlar ularga ulanganda interfeysga
ko‘chiriladi.

### Reja: hali ko‘chirilmagan (501)

Bular uchun D1 jadvallari (`0003_planned_ports.sql`) bor, lekin endpointlar
**yo‘q** — server `501 not_implemented`, ilova adapteri
`BackendFailure.unavailable` (“ulanmagan”) qaytaradi; hech biri ishlayotgandek
ko‘rsatilmaydi. Hamkorlar ro‘yxati bo‘sh (reklama joylari chiqmaydi).

| Bo‘lim | Yo‘l | Qolgan ish (manba: `supabase/migrations`) |
|---|---|---|
| Taklif va yordam | `/v1/support/*` | murojaat/xabar CRUD, o‘qilgan belgisi; skrinshot uchun yopiq R2 bucket (PNG/JPEG ≤ 5 MB, kuniga 10) |
| Admin panel | `/v1/admin/*` (hozir ham admin+aal2 tekshiriladi) | statistika (faqat ro‘yxatdan o‘tganlar — mehmonlar serverga tushmaydi), foydalanuvchilar (`email_masked`), reviewer berish, audit o‘qish |
| Kontent tekshiruvi | `/v1/reviews` | `content_reviews` |
| Hamkorlar | `/v1/partners*` | feed, arizalar, kunlik umumiy hisoblagich, logo (R2) |
| Pro huquqlari | `/v1/entitlements` | `verify-purchase` porti (do‘kon API), ilova faqat o‘qiydi |

Eslatma: to‘liq emailni “ochish” (`adminRevealEmail`) bu serverda **bo‘lmaydi**
— email saqlanmaydi.

## Xavfsizlik

- **Email minimal:** bazada faqat `HMAC-SHA256(email)` (kalit — Worker
  secreti) va niqoblangan `da***@gmail.com`. Ochiq email faqat kod yuborish
  paytida xotirada bo‘ladi. Sessiya ichida email qurilmada saqlanadi.
- **OTP:** 6 raqam (`crypto.getRandomValues`, bir tekis), faqat HMAC holida,
  10 daqiqa, bitta kodga 5 urinish (atomar hisob), bir martalik. Limitlar:
  qayta yuborish 60 s; email bo‘yicha soatiga 5 kod va 15 tekshiruv; IP bo‘yicha
  soatiga 60 so‘rov va 10 daqiqada 100 tekshiruv (sinf bitta NAT ortida
  bo‘lishi mumkin). IP saqlanmaydi — limit kalitida faqat HMAC.
- **Sessiya:** 32 baytli tasodifiy opaque token; D1 da faqat SHA-256; 60 kun;
  chiqish/hamma qurilmadan chiqish; muddati o‘tgani cron bilan o‘chadi.
- **Rollar:** `student` standart; `teacher` — foydalanuvchi o‘zi tanlaydi va
  faqat guruh **yaratishga** ruxsat beradi; ustoz huquqi faqat o‘zi yaratgan
  guruhlarda. **Admin** — hech bir API bermaydi: faqat maxfiy
  `LG_ADMIN_EMAILS` dagi email kod bilan tasdiqlanganda (ro‘yxatdan chiqsa —
  keyingi kirishda olinadi) yoki egasi qo‘lda (`granted_reason='manual'`).
  Admin yo‘llari qo‘shimcha **TOTP (aal2)** talab qiladi; tasdiqlangan faktor
  bor bo‘lsa yangisini qo‘shib bo‘lmaydi; kodni qayta ishlatish rad etiladi.
  Muhim amallar `audit_log` ga (faqat qo‘shiladi).
- **Ustoz–talaba:** a’zo bo‘lmaganga guruh borligi bildirilmaydi (404);
  talaba boshqa talabaning javobi, belgisi va a’zolar ro‘yxatini ko‘rmaydi;
  kalit faqat ustozga; ball serverda. Taxallus — harf/raqam, `@` va havola
  emas; bo‘lmasa “Talaba NN”. Guruh kodi taxminiga qarshi: foydalanuvchiga
  15 daqiqada 10, IP ga soatiga 100 urinish.
- **SQL:** faqat parametrli (`?1`) so‘rovlar; test SQL shablonlarida
  tashqi qiymat interpolatsiyasi yo‘qligini ham tekshiradi.
- **CORS:** standart holatda umuman yo‘q (mobil ilovaga kerak emas);
  `LG_ALLOWED_ORIGINS` faqat web build uchun.
- **Xatolar:** `500 {"error":"internal"}` — SQL/stack chiqmaydi; logda faqat
  xato turi (email, kod, kalit logga yozilmaydi). `cache-control: no-store`,
  `nosniff`, tana ≤ 32 KB, faqat `application/json`.
- **Fayllar:** R2 hali ulanmagan — fayl qabul qilinmaydi (yopiq bucket
  rejada).
- **AI:** server hech qanday avtomatik javob yubormaydi.

Testlar (`cd cloudflare && npm test`): 52 ta, shundan avtorizatsiya va
xavfsizlik — 37 ta (boshqa ustoz guruhi, talaba ↔ talaba, o‘zini admin qilish,
TOTP, SQL injection, CORS, xato tafsiloti, limitlar, maxfiylik).

## Lokal ishlash

```bash
cd cloudflare
npm ci
npm test              # workerd + lokal D1 (tarmoq va hisob kerak emas)
npm run typecheck
```

## Egasi uchun qadamlar (bir marta)

1. **Cloudflare hisob** — bor. D1 baza `labguide-db` yaratilgan (EEUR,
   id `wrangler.toml` da). Workers & Pages → **workers.dev subdomeni**
   yoqilganini tekshiring (URL `https://labguide-api.<subdomen>.workers.dev`).
2. **API token:** dash.cloudflare.com → My Profile → API Tokens → Create
   Token → *Custom token*:
   - Account → **Workers Scripts: Edit**
   - Account → **D1: Edit**
   - Account → **Account Settings: Read**
   - User → **Memberships: Read**, **User Details: Read**
   - Account Resources: *Include → faqat LabGuide hisobi*. TTL ixtiyoriy.
   Token barcha Workerlarni tahrirlay oladi — CI faqat `labguide-api` nomini
   deploy qiladi; tokenni boshqa joyda ishlatmang.
3. **Account ID:** Dashboard → Workers & Pages → o‘ng panel “Account ID”.
4. **Brevo:** brevo.com da hisob → *Senders, Domains & Dedicated IPs* →
   jo‘natuvchi email qo‘shib tasdiqlang (yaxshisi o‘z domeningiz va uning
   SPF/DKIM yozuvlari — aks holda xatlar spamga tushadi) → *SMTP & API → API
   Keys* → yangi kalit (`xkeysib-…`).
5. **Server secreti:** `openssl rand -hex 32` — natijani parol menejeriga
   saqlang. U email HMAC kaliti: o‘zgartirilsa yoki yo‘qolsa, mavjud hisoblar
   topilmay qoladi (MyCloud’ga ko‘chirishda ham kerak).
6. **GitHub → Settings → Secrets and variables → Actions → Secrets:**
   - `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
   - `BREVO_API_KEY`, `LG_SENDER_EMAIL` (tasdiqlangan jo‘natuvchi)
   - `LG_SERVER_SECRET` (5-qadam)
   - ixtiyoriy: `LG_ADMIN_EMAILS` (masalan, egasining emaili — vergul bilan),
     `CLOUDFLARE_D1_DATABASE_ID` (boshqa baza ishlatilsa)
7. **Deploy:** Actions → LabGuide CI → Run workflow → mode **deploy_api**.
   Job: Worker testlari → D1 migratsiyalari → `labguide-api` deploy →
   secretlar (stdin orqali, logga chiqmaydi) → `/v1/health`. Secret yetishmasa
   job xatosiz o‘tkazib yuboriladi va qaysi biri yo‘qligini yozadi.
8. **Ilovani ulash:** Settings → Variables → **`LG_API_URL`** = summary’dagi
   URL. Keyingi `build`/`testflight`/`play_internal` buildlari shu serverga
   ulanadi (`LG_SUPABASE_*` bo‘lsa ham Cloudflare ustun).
9. **Birinchi admin kirishi:** ilovada `LG_ADMIN_EMAILS` dagi email bilan
   kiring → Admin panel → TOTP. Kalit yo‘qolsa:
   `npx wrangler d1 execute labguide-db --remote --command "DELETE FROM totp_factors WHERE user_id = '<id>'"`.
   Qo‘lda admin berish: `INSERT INTO admins (user_id, granted_at, granted_reason) VALUES ('<id>', <ms>, 'manual')`.
10. **Maxfiylik siyosati:** server (Cloudflare, EEUR) va email xizmati (Brevo)
    nomlarini `docs/store/PRIVACY_POLICY.md` ga yozing; email ochiq holda
    saqlanmasligini qo‘shish mumkin.

## Keyin MyCloud (yoki boshqa server)ga ko‘chirish

D1 — oddiy SQLite, Worker kodi standart `Request/Response` va WebCrypto.

1. Eksport: `npx wrangler d1 export labguide-db --remote --output labguide.sql`
   (sxema + ma’lumot, SQLite dialekti). Faylni shifrlangan holda saqlang.
2. Yangi serverda SQLite (`sqlite3 labguide.db < labguide.sql`) yoki
   PostgreSQL’ga import (vaqtlar — Unix ms `INTEGER`, JSON maydonlar — `TEXT`).
3. Kod: `createApp()` faqat `env.DB` (D1 interfeysi: `prepare/bind/first/all/run/batch`)
   ni ishlatadi — `better-sqlite3` ustida shu interfeysli kichik o‘ram yozib,
   Node.js (yoki workerd) da ishga tushirish mumkin. Cron o‘rniga tizim
   taymeri.
4. Bir xil `LG_SERVER_SECRET` — aks holda email HMAC’lar mos kelmaydi va
   foydalanuvchilar yangi hisob ochib qo‘yadi. Sessiya tokenlari ham ishlayveradi.
5. Ilovada faqat `LG_API_URL` o‘zgaradi (yangi build). O‘zbekiston
   qonunchiligi (shaxsiy ma’lumotlarni mahalliy saqlash) uchun ko‘chirish
   rejasini yurist bilan tekshiring.
