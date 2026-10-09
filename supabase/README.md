# LabGuide server (Supabase)

Hisoblar (email kod), admin panel, “Taklif va yordam” va o‘qituvchi–talaba
guruhlari shu yerda. Ilova serverga faqat **URL** va **publishable** kalit
bilan ulanadi; ikkalasi ham repoda emas — build vaqtida GitHub secrets'dan
`--dart-define` orqali beriladi. **Service role** kaliti hech qachon ilovaga
yoki repoga tushmaydi (faqat Edge Function ichida, Supabase o‘zi beradi).

Sozlanmagan build (secrets bo‘sh) “Server hali ulanmagan” deb ko‘rsatadi;
mehmon rejimi va oflayn kontent to‘liq ishlaydi.

## Tarkib

| Fayl | Nima |
|---|---|
| `migrations/…0100_core_access.sql` | profil, admin ro‘yxati (`admin_allowlist`), `app_admins` (faqat email tasdiqlanganda trigger beradi), reviewer, `admin_audit` (faqat qo‘shiladi) |
| `migrations/…0200_support.sql` | murojaatlar va xabarlar, RLS, yopiq `support-attachments` bucket (PNG/JPEG, 5 MB, o‘z papkasi, kuniga 10 ta) |
| `migrations/…0300_admin_panel.sql` | `admin_stats`, `admin_list_users` (niqoblangan email), `admin_reveal_email` (jurnalga yoziladi), `admin_set_reviewer` |
| `migrations/…0400_groups.sql` | guruh, taklif kodi, topshiriq, javob (ball serverda hisoblanadi) |
| `migrations/…0900_privileges.sql` | jadvallarga to‘g‘ridan-to‘g‘ri yozish yopiq; yozish faqat RPC orqali |
| `functions/delete-account` | foydalanuvchi o‘z hisobini o‘chiradi (fayllari bilan) |
| `tests/` | lokal Postgres'da qabul testlari (`tool/backend_test.sh`) |

Admin vakolati: `davlatsudekspert@gmail.com` serverdagi ro‘yxatda. Vakolat
faqat shu email **kod bilan tasdiqlangan** hisobga beriladi, admin RPC'lari
esa qo‘shimcha ravishda ikki bosqichli sessiya (`aal2`, TOTP) talab qiladi.
Ilovadagi email yoki rol tanlovi hech narsa bermaydi; foydalanuvchi o‘zini
admin qila olmaydi (jadvallarga yozish huquqi yo‘q).

## Lokal tekshiruv

```bash
tool/backend_test.sh          # PostgreSQL 14+ kerak; vaqtinchalik klaster
```

Kutilgan oxirgi qator: `backend tests: OK`. CI'da `backend` job shuni bajaradi.

## Haqiqiy serverga ulash (bir marta)

1. **Loyiha.** supabase.com → New project (region: Frankfurt `eu-central-1`
   yoki yaqinroq). Bepul tarifda faol loyihalar soni 2 ta — hozirgi ikkala
   loyiha band (qarang: `docs/PROGRESS.md`, “Server”).
2. **Migratsiyalar.** SQL Editor'da `migrations/*.sql` ni nom tartibida
   ishga tushiring, yoki CLI bilan:
   ```bash
   supabase link --project-ref <ref>
   supabase db push
   ```
3. **Edge Function.**
   ```bash
   supabase functions deploy delete-account
   ```
4. **Auth → Providers → Email:**
   - Email provider: yoqilgan; “Confirm email”: yoqilgan.
   - **Email OTP Expiration: 600** (ilova ham 10 daqiqa deb ko‘rsatadi).
   - Email OTP Length: 6.
5. **Auth → Email Templates → Magic Link** (kod shu shablonda keladi):
   ```html
   <h2>LabGuide kirish kodi</h2>
   <p>Kodingiz: <strong>{{ .Token }}</strong></p>
   <p>Kod 10 daqiqa amal qiladi. Siz so‘ramagan bo‘lsangiz, xatni e’tiborsiz qoldiring.</p>
   ```
   “Confirm signup” shablonida ham `{{ .Token }}` bo‘lsin (yangi hisob).
6. **Auth → SMTP Settings: o‘z SMTP** (Resend, Postmark, Amazon SES,
   Brevo…). Standart Supabase pochtasi faqat loyiha a’zolariga va soatiga
   bir necha xat yuboradi — haqiqiy foydalanuvchiga yetmaydi. Jo‘natuvchi
   domen uchun SPF/DKIM yozuvlari kerak.
7. **Auth → Rate Limits:** email yuborish — soatiga 30 (yoki SMTP
   provayderingiz ruxsat bergancha); OTP tekshirish — standart.
8. **Auth → Multi-Factor:** TOTP yoqilgan (standart).
9. **Auth → URL Configuration:** Site URL — `https://labguide.uz` (yoki
   maxfiylik sahifasi joylashgan domen). Ilova havola emas, kod ishlatadi.
10. **GitHub → Settings → Secrets and variables → Actions:**
    - `LG_SUPABASE_URL` = `https://<ref>.supabase.co`
    - `LG_SUPABASE_KEY` = Project Settings → API Keys → **publishable**
      (`sb_publishable_…`). Service role / secret kalitni bu yerga
      **qo‘ymang**.
11. Keyingi CI build (TestFlight) avtomatik ravishda serverga ulangan
    bo‘ladi. Tekshirish: Profil → “Taklif va yordam” — “Server hali
    ulanmagan” yozuvi yo‘qolgan bo‘lishi kerak.

## Birinchi admin kirishi

1. Ilovada `davlatsudekspert@gmail.com` bilan kiring (emailga kelgan kod).
2. Profil → **Admin panel** (faqat server tasdiqlagandan keyin ko‘rinadi).
3. Autentifikator ilovasiga kalitni qo‘shing va 6 xonali kodni kiriting —
   shundan keyin panel ochiladi. Kalitni yo‘qotsangiz: Supabase Dashboard →
   Authentication → Users → foydalanuvchi → MFA factors → o‘chirish, keyin
   qayta ro‘yxatdan o‘tkazing.

## Qabul tekshiruvi haqiqiy serverda

Faqat test hisoblari bilan (haqiqiy foydalanuvchilarga sinov xabari
yuborilmaydi):

1. A va B test emaillari bilan kiring — admin statistikada har biri bir
   marta sanaladi (mehmonlar sanalmaydi).
2. A “Taklif va yordam”da murojaat yuboradi → admin “Murojaatlar”da ko‘radi.
3. Admin javob yozadi → A'da “1 ta yangi javob” belgisi, B'da yo‘q.
4. A javobga yana yozadi → murojaat yana “Yangi”.
5. B na A murojaatini, na admin panelni ocha oladi (“Faqat admin uchun”).
6. Ilovani yopib-ochish: yozishma saqlangan.
7. Test hisoblarini Profil → Maxfiylik → “Hisobni o‘chirish” bilan
   o‘chiring.
