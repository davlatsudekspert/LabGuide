# Pro bepul sinovi — suiiste'molga qarshi eslatmalar (D-74)

> Holat: **o'chiq**. Hech narsa deploy qilinmagan. `LG_BILLING_ENABLED` o'chiq (yo'llar 404), qurilma attestatsiyasi
> tekshiruvchisi ulanmagan (503 `device_attestation_not_configured`), `0016_pro_trials.sql` — faqat fayl.

## 1. Maqsad
7 kunlik bepul sinov (D-76; avval 30 kun — D-74/D-75, bekor) **bir telefonga bir marta** (hisobga emas), hamma
reja uchun (Talaba, Ustoz, Mutaxassis, Premium). Shu bilan birga bitta hisobga va bitta kanonik
emailga ham bir marta. Pullik obunani hech qachon bosib o'tmaydi.

## 2. Oqim
1. Ilova: hisobga kirgan (mehmon emas) foydalanuvchi “Bepul sinov” ni bosadi (tugma faqat `DeviceAttestor.available`
   bo'lsa — bugun hech bir buildda yo'q).
2. `POST /v1/billing/trial/challenge` → 32 baytli nonce (5 daqiqa, shu hisobga bog'langan, serverda SHA-256).
3. Ilova platforma attestatsiyasini oladi: iOS — App Attest assertion (yoki DeviceCheck tokeni), Android — Play
   Integrity token; nonce so'rovga bog'lanadi.
4. `POST /v1/billing/trial/start {tier, email, attestation}`. Server tartibi: sessiya → tekshiruvchi sozlanganmi (503)
   → limit → email hisobniki (403 `email_not_verified`) → daraja ruxsati (403 `plan_not_allowed`) → amaldagi obuna
   (409 `already_subscribed`) → hisob/email sinovi (409) → nonce (400 `invalid_nonce`) → attestatsiya (403
   `device_attestation_failed`) → qurilma sinovi / platforma bayrog'i (409) → yozuv (unikal indekslar) →
   `markUsed` → jurnal → 201.

## 3. Mexanizmlar va nimaga qarshi
| Nazorat | Nimani to'xtatadi | Nimani to'xtatmaydi |
|---|---|---|
| Hisob shart (sessiya) | mehmon rejimida cheksiz sinov | — |
| Email = hisob emaili (OTP / provayder `email_verified`) | birovning emailini yozish | ko'p haqiqiy email ochish |
| Kanonik email (Gmail nuqta/`+teg`, googlemail, MS/Yandex `+teg`) | `ali.v+1@gmail.com`, `aliv+2@googlemail.com` | boshqa provayderdagi aliaslar, bir martalik domenlar, yangi email |
| Qurilma attestatsiyasi + `device_key` | bir telefonda ko'p hisob | yangi/boshqa telefon; subyekt o'zgarsa (masalan App Attest kaliti qayta yaratilsa) |
| Platforma bayrog'i (DeviceCheck 2 bit / Play “device recall”) | ilovani qayta o'rnatish, bizdagi yozuv o'chgan holat | platforma bayrog'ini tiklab bo'lmaydigan holatlar (tekshirilmagan) |
| Attestatsiya halolligi (App Attest / Play Integrity verdict) | oddiy emulyator, soxta so'rov skripti | root/jailbreak ostidagi ilg'or chetlab o'tish, ruxsat berilgan sertifikatlangan qurilmalar fermasi |
| O'chirishdan keyin yozuv qoladi (24 oy) | “hisobni o'chir — qayta ro'yxat — yana sinov” | 24 oydan keyin (ataylab) |
| Limitlar (hisob 5/soat, IP 30/soat) | ommaviy urinish | ko'p IP / ko'p hisob |
| Daraja ruxsati (Ustoz — `teacher_accounts`, Mutaxassis — tasdiqlangan, Premium — ikkalasi; D-76) | Talabaning Ustoz sinovini olishi | `teacher_accounts` o'z-o'zini ro'yxatdan o'tkazish (D-42) — tasdiq emas |

## 4. Qolgan xavflar (halol)
- **Hech bir usul qat'iyatli buzg'unchini to'liq to'xtatmaydi.** Yangi telefon = yangi sinov. Qurilma fermalari,
  root/jailbreak + attestatsiyani chetlab o'tish, platforma kalitlari o'g'irlanishi mumkin.
- App Attest kaliti ilova qayta o'rnatilganda yangilanadi (subyekt o'zgaradi) — shuning uchun iOS'da DeviceCheck
  bitlari (qurilma bo'yicha, Apple serverida) qo'shimcha kerak. Ularning zavod sozlamasiga qaytarishdan keyin ham
  saqlanishi Apple hujjati bilan shu ishda TEKSHIRILMADI (NOT_CHECKED). Play “device recall” — beta; xuddi shunday.
- Google Play xizmatlarisiz qurilmalar (Huawei/AOSP) va web — attestatsiya yo'q → sinov berilmaydi (hozirgi qaror).
- `LG_SERVER_SECRET` almashtirilsa barcha `email_key`/`device_key` mos kelmay qoladi (sinov qayta ochiladi).
- Xato musbat: telefon sotilsa/meros qolsa yangi egasi sinov ololmaydi (24 oy).
- iOS App Review 3.1.1: obuna ilovalarida kartasiz, server bergan sinov savol tug'dirishi mumkin (Apple obuna uchun
  Introductory Offer ni kutadi) — yoqishdan oldin tekshirish kerak (bu ishda qoidalar qayta o'qilmadi).

## 5. Do'kon-native kirish taklifi nimasi bilan farq qiladi
| | Server sinovi (D-74) | Apple Introductory Offer / Google Play free trial |
|---|---|---|
| Kimga bir marta | telefon + hisob + kanonik email | Apple ID (obuna guruhiga) / Google hisobi (dasturchi sozlamasiga ko'ra) — **qurilmaga emas** |
| Karta / to'lov usuli | shart emas | shart; sinov tugagach avtomatik pullik |
| Bizning serverdagi ma'lumot | HMAC xeshlar, 24 oy | yo'q (do'kon hal qiladi) |
| Suiiste'mol | yuqoridagi xavflar | yangi Apple ID / Google hisob bilan qayta; do'kon o'z firibgarlikka qarshi vositalari |
| Kod | bu tarmoqda (o'chiq) | ilova `StoreProduct.freeTrial` ni allaqachon o'qiydi (D-71) |

## 6. Maxfiylik
Saqlanadi: sinov id, hisob id (o'chirilganda NULL), daraja, platforma, boshlanish/tugash, `email_key`, `device_key`
(HMAC-SHA256, kalit serverda), `account_deleted_at`, `retain_until`. Saqlanmaydi: email, qurilma id, attestatsiya
tokeni, IP. Asos: suiiste'molning oldini olishdagi qonuniy manfaat; minimal hajm; 24 oy. Matn loyihasi:
`site/privacy/index.html` §10a (uz/ru/en), ilovada `proPrivacyTrialNote` (faqat Pro bayrog'i bilan). Do'kon
deklaratsiyalari (App Privacy, Data safety “Device or other IDs”) — egasi yangilaydi. Yurist tasdig'i kerak.

## 7. Kodda qayerda
- Server: `cloudflare/src/trial.ts` (oqim, `canonicalEmail`, interfeys, tozalash), `billing.ts` (`loadAccess`,
  `resolveAccess` — `trial`), `auth.ts` (`deleteUserData` → yozuvni uzish), `app.ts` (yo'llar, kunlik tozalash),
  `migrations/0016_pro_trials.sql`. Testlar: `cloudflare/test/trial.test.ts`, `fake_attestation.ts`.
- Ilova: `lib/core/entitlements/device_attestor.dart`, `entitlement_source.dart` (`TrialSource`),
  `entitlement_service.dart` (`startTrial`, `TrialOutcome`), `features/profile/subscription_screen.dart`.
