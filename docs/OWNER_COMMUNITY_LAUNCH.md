# Hamjamiyatni ishga tushirish — egasi uchun qo‘llanma

Bu ish **bir marta** qilinadi (server yangilangandan keyin). Kompyuter yoki texnik bilim shart emas — faqat telefon va LabGuide ilovasi.

## Boshlashdan oldin

- Ilova va server **yangi versiyada** bo‘lishi kerak (buni dasturchi/supervisor tasdiqlaydi).
- Siz **egasi emaili** (`davlatsudekspert@gmail.com`) bilan kirasiz. Boshqa email bilan bu tugma ishlamaydi.
- Telefoningizda **autentifikator ilovasi** bo‘lishi kerak: Google Authenticator yoki Microsoft Authenticator (Play Market / App Store’dan bepul). Yo‘q bo‘lsa, avval shuni o‘rnating.

## A. Ilovaga kirish (agar kirmagan bo‘lsangiz)

1. LabGuide’ni oching.
2. Birinchi ekranda **Kirish** ni bosing (agar allaqachon kirgan bo‘lsangiz, bu bosqichni o‘tkazib yuboring).
3. Email maydoniga egasi emailingizni yozing, shartlarni qabul qilish belgisini qo‘ying, **Kod olish** ni bosing.
4. Emailingizga kelgan 6 xonali kodni kiriting va **Tasdiqlash** ni bosing.

## B. Hamjamiyat moderatsiyasiga o‘tish

1. Ekranning yuqori o‘ng burchagidagi **profil belgisini** bosing (“Profil va sozlamalar” ochiladi).
2. Pastroqda **Hamjamiyat moderatsiyasi** qatorini bosing.

## C. Ikki bosqichli himoya (TOTP)

Bu qadam faqat shu sahifada “Ikki bosqichli himoya” oynasi chiqsa kerak bo‘ladi. Tepasida ko‘k tushuntirish ham ko‘rinadi.

### C1. Birinchi marta (autentifikatorni ulash)

1. Ilovada **Kalit** deb yozilgan uzun harf-raqamlar ko‘rinadi.
2. **Kalitni nusxalash** ni bosing (“Nusxalandi” deb chiqadi).
3. Autentifikator ilovasini oching (Google Authenticator) → **+** → **Sozlash kalitini kiritish** (Enter a setup key).
4. Nom: `LabGuide`. Kalit: nusxalanganni qo‘ying (yopishtiring). Turi: **Vaqtga asoslangan** (Time based). **Qo‘shish** ni bosing.
   - Muqobil: LabGuide’da **Autentifikatorda ochish** ni bosing — telefon o‘zi autentifikatorni ochib, kalitni qo‘shishni taklif qiladi.
5. Autentifikatorda “LabGuide” paydo bo‘ladi va 6 xonali kod ko‘rsatadi (30 soniyada almashadi).
6. LabGuide’ga qayting, **6 xonali kod** maydoniga o‘sha kodni yozing, **Tasdiqlash** ni bosing.

> Kalitni boshqa odamga bermang va skrinshot qilib yubormang. Telefonni almashtirsangiz, autentifikator ma’lumotlari ko‘chirilishi kerak — aks holda kirish tiklanmaydi (tiklash faqat qo‘lda, dasturchi orqali).

### C2. Keyingi safarlar

Autentifikator allaqachon ulangan bo‘lsa, ilova faqat **6 xonali kod** so‘raydi: autentifikatordagi “LabGuide” kodini kiriting → **Tasdiqlash**. Kod eskirsa (“noto‘g‘ri yoki eskirgan”), yangi kodni kuting va qayta kiriting.

## D. Bir tugma: ishga tushirish

1. Tasdiqlangandan keyin sahifaning tepasida **Hamjamiyatni ishga tushirish** kartasi chiqadi.
2. **Ishga tushirish** tugmasini **bir marta** bosing.
3. Tayyor bo‘lsa xabar chiqadi:
   **“Tayyor: asoschi tasdiqlandi. Qo‘shildi: N ta savol, M ta javob.”**
4. Tugmani qayta bossangiz zarar yo‘q: “Hamjamiyat allaqachon ishga tushirilgan…” deb chiqadi, hech narsa takrorlanmaydi.

## E. Tekshirish

1. Orqaga qayting → **Tahlillar** → **Kaliy** (yoki HbA1c) → pastda hamjamiyat savollari havolasi.
2. Savollar “LabGuide” nomi va “tasdiqlangan” belgisi bilan ko‘rinishi kerak.

## Xatolar bo‘lsa

| Xabar | Nima qilish kerak |
|---|---|
| “Bu hisob asoschi sifatida ruxsat etilmagan…” | Egasi emaili bilan kirmagansiz. Chiqib, to‘g‘ri email bilan qayta kiring. |
| “Faqat admin uchun” | Bu hisob admin emas. Egasi emaili bilan kiring. |
| “Kod noto‘g‘ri yoki eskirgan” | Autentifikatordagi yangi kodni kiriting; telefon soati to‘g‘ri bo‘lsin (avtomatik vaqt yoqilgan). |
| Ulanish xatosi | Internetni tekshirib, qayta urining. Tugma xavfsiz — takror bosish mumkin. |
| Hamjamiyat bo‘limi ko‘rinmaydi | Ilova serverga ulanmagan versiyada. Dasturchiga xabar bering. |
