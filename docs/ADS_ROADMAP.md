# Reklama joylari (hamkor firmalar) — keyingi reja (2026-10-26)

> **Holat: REJAGA YOZILDI, HOZIR QILINMAYDI** (egasi qarori, 2026-10-26). Tartib: avval bepul versiya do‘konda
> tasdiqlanadi → keyin pullik versiya tasdiqlanib chiqadi → shundan keyin reklama. Hozirgi bepul versiya va pullik
> tizim kodiga reklama sababli TEGILMAYDI. `LG_PARTNER_ADS` hamma buildda `false` qoladi (D-qaror 2026-10-17).

## Maqsad
Ilova ko‘p foydalanuvchi to‘plagach, laboratoriya xizmatlari, apparat firmalari va laboratoriyalar bosh sahifada va
tegishli bo‘limlarda o‘z reklamasini joylay olishi. Har bir davlat foydalanuvchisiga o‘sha davlat uchun reklama.

## Hozir bor (kod, o‘chirilgan)
- Ekran joylari: bosh sahifa juftligi (lab xizmati + apparat firmasi), Lab sahifasi, yo‘nalish, apparat kartasi, hamkor sahifasi,
  admin bo‘limlari, ko‘rsatilish/bosilish hisoboti (`docs/PARTNERS.md`, `lib/core/backend/partner_models.dart`).
- Test buildda demo “Namuna — reklama joyi” kartasi.

## Qilinadigan ishlar (1.1 dan keyin, alohida tarmoq)
1. **Server (Cloudflare):** hamkorlar jadvali + admin API + ko‘rsatilish/bosilish hisobi (hozir faqat eski Supabase’da;
   `0003_planned_ports.sql` rejalashtirilgan). Yangi migratsiya, testlar.
2. **Davlat bo‘yicha ko‘rsatish:** hamkorda “qaysi davlatlar” maydoni (`UZ`, `KZ`, `RU`, … yoki “hammasi”). Foydalanuvchi
   davlati serverdan (so‘rov davlat kodi) olinadi, ilovadan so‘ralmaydi, SAQLANMAYDI. Hisobotda davlat kesimi.
3. **Do‘kon buildi:** demo karta CHIQMAYDI; joy faqat haqiqiy faol hamkor bo‘lganda ko‘rinadi. Firmalar uchun Profil / “Ilova
   haqida” da “Reklama bering / Hamkor bo‘ling” tugmasi (aloqa).
4. **Siyosat va formalar:** Maxfiylik siyosati, App Store “App Privacy”, Google Play “Data Safety” (reklama hisobi, davlat kodi
   saqlanmasligi); do‘kon qoidalari bo‘yicha “Reklama” yorlig‘i (allaqachon bor). Huquqshunos ko‘rigi.
5. **Bayroq:** `LG_PARTNER_ADS=true` faqat shu ishlar tugab, egasi ruxsat bergach (D-qarorni yangilash, ci.yml va guardlar).

## Shartlar (qilishdan oldin)
- Bepul versiya tasdiqlangan va chiqqan; pullik versiya tasdiqlangan va chiqqan.
- Egasining alohida ruxsati; haqiqiy hamkor shartnomasi/narxlari egasi tomonidan (men narx o‘ylab topmayman).
