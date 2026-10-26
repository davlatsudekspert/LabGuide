# YORDAMCHIGA PROMPT — LabGuide pullik tizimini do‘konlarda sozlash

> Quyidagi matnni to‘liq yordamchiga (Claude sessiyasi yoki odam) bering. Maxfiy kalitlarni (parol, .p8, JSON) chatga
> YOZMANG — to‘g‘ridan-to‘g‘ri GitHub Secrets’ga qo‘ying.

---

Sen LabGuide ilovasining (Flutter, bundle/paket `uz.labguide.app`) pullik tizimini do‘konlarda sozlashda egasiga
yordam beryapsan. Repo: `davlatsudekspert/labguide`, tarmoq: `rc/paid-1` (faqat shu tarmoq; `main` ga TEGMA).
Avval o‘qi: `docs/PAID_OWNER_HELPER_CHECKLIST.md`, `docs/PAID_SANDBOX_RUNBOOK.md`,
`docs/PAID_BACKEND_DEPLOY_CHECKLIST.md`, `docs/DECISIONS.md` (D-77, D-78).

## Vaziyat
- Cloudflare Worker `labguide-api` deploy qilingan, pullik yo‘llar yoqilgan, do‘kon kalitlari YO‘Q.
- Test buildlar TestFlight (0.1.0 (35)) va Play ichki trekda (draft). Ilovaning bepul versiyasi do‘kon tekshiruvida —
  uni O‘ZGARTIRMA, bekor qilma, almashtirma.

## Qil
1. App Store Connect: bitta obuna guruhi va 8 obuna mahsuloti (ID lar aynan):
   `uz.labguide.student.monthly|yearly`, `uz.labguide.teacher.monthly|yearly`,
   `uz.labguide.specialist.monthly|yearly`, `uz.labguide.premium.monthly|yearly`. Har biriga uz/ru/en nom va tavsif,
   7 kunlik introductory offer (bepul sinov). Narx: egasi tasdiqlagan bazaviy USD (checklist 0-bo‘lim); mahalliy
   valyuta narx nuqtalarini egasidan SO‘RA, o‘zing o‘ylab topma.
2. Google Play Console: xuddi shu 8 obuna (base plan), 7 kunlik free-trial offer.
3. Kalitlar yarat va GitHub Secrets’ga (Settings → Secrets and variables → Actions) qo‘y — nomlari aynan:
   `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`, `APPLE_DEVICECHECK_KEY_ID`,
   `APPLE_DEVICECHECK_TEAM_ID`, `APPLE_DEVICECHECK_PRIVATE_KEY`, `GOOGLE_PLAY_SERVICE_ACCOUNT`,
   `PLAY_INTEGRITY_SERVICE_ACCOUNT` (ixtiyoriy), `PLAY_INTEGRITY_CERT_SHA256`, `PLAY_RTDN_AUDIENCE`,
   `PLAY_RTDN_SERVICE_ACCOUNT` (yoki `PLAY_RTDN_TOKEN`), `TRIAL_PLATFORMS` = `android`, `LG_BILLING_SANDBOX` = `true`.
4. Do‘kon bildirishnoma manzillari: App Store Server Notifications V2 →
   `https://labguide-api.davlatsudekspert.workers.dev/v1/billing/apple/notifications`; Google RTDN (Pub/Sub push) →
   `https://labguide-api.davlatsudekspert.workers.dev/v1/billing/google/rtdn`.
5. Sandbox/License tester akkauntlarini yarat (Apple Sandbox, Play License testing).
6. Play Console → Internal testing → draft relizni testerlarga ochish (“Start rollout to Internal testing”).
7. Hammasi tayyor bo‘lgach egasidan so‘ra: GitHub Actions → LabGuide CI → `deploy_api` (+ `billing_preview`) — BIR marta.
   Keyin `GET https://labguide-api.davlatsudekspert.workers.dev/v1/billing/status` ni tekshir.
8. `docs/PAID_SANDBOX_RUNBOOK.md` §2 matritsasi bo‘yicha sandbox sinov: sotib olish, tiklash, bekor qilish, muddat
   tugashi, mehmon va akkauntli, 7 kunlik sinov. Har qatorga PASS / FAIL / NOT RUN yoz.

## Qilma (egasining alohida ruxsatisiz)
- `main` ga merge, Production reliz, bepul versiyani o‘zgartirish yoki rad etish.
- Pullik xizmat/API sotib olish, reklama kampaniyasi, pullik GitHub Actions/macOS build.
- Tasdiqlanmagan ilmiy kontentni ommaviy nashr qilish.
- Narx, mahsulot ID yoki maxfiy kalitni o‘ylab topish yoki chatga/repoga yozish.
- Mutaxassis tasdiqlarini birovning nomidan yozish.

## Hisobot (oxirida, qisqa)
Har qadam: bajarildi / bajarilmadi (sababi) / egasi kerak. Sinov natijalari: PASS/FAIL/NOT RUN (haqiqiy do‘konda
sinalmagan narsani “sinalgan” dema). Biror tizim (Apple/Google) real tasdiq, parol yoki to‘lov talab qilsa — to‘xta,
aniq to‘siqni yoz va qolgan ishlarni davom ettir.
