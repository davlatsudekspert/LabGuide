# Admin panel — egasi uchun qo‘llanma

Ilovada: **Profil → Admin panel**. Panel Cloudflare serveri bilan ishlaydi
(`docs/BACKEND_CLOUDFLARE.md`, “Egasi admin paneli”). Panelda faqat serverdan
kelgan haqiqiy sonlar ko‘rinadi — soxta yoki taxminiy raqam yo‘q.

## 1. Bir martalik sozlash

1. GitHub → repo → **Settings → Secrets and variables → Actions → Secrets** →
   **New repository secret**:
   - Nomi: `ADMIN_EMAILS`
   - Qiymati: `davlatsudekspert@gmail.com` (bir nechta bo‘lsa — vergul bilan).
   Eski nom `LG_ADMIN_EMAILS` ham ishlaydi (`ADMIN_EMAILS` bo‘sh bo‘lsa). Ikkalasi
   ham bo‘lmasa server kodda yozilgan standart egasi emailini oladi (egasi qarori).
2. **Actions → LabGuide CI → Run workflow → mode `deploy_api`.** Job testlarni
   o‘tkazadi, D1 migratsiyalarini (`0009_admin_console` ham) qo‘llaydi, Worker’ni
   deploy qiladi va secretlarni yozadi (qiymatlar logga chiqmaydi).
3. Emailni olib tashlash yoki almashtirish: secretni o‘zgartiring va yana
   `deploy_api`. Eslatma: GitHub’dagi secretni **o‘chirish** Worker’dagi secretni
   o‘chirmaydi — o‘rniga yangi qiymat yozing (yoki
   `npx wrangler secret delete ADMIN_EMAILS`).

## 2. Kirish

1. Ilovada Profil → **Kirish** → `ADMIN_EMAILS` dagi email → emailga kelgan
   6 xonali **kod**.
2. Profil → **Admin panel** qatori paydo bo‘ladi → panel darhol ochiladi.
   Holat kartasida: “Kirish: egasi emaili (ADMIN_EMAILS) va email kodi”.
3. **Google yoki Apple bilan kirgan sessiyada panel ochilmaydi** — faqat email
   kodi bilan kirilgan sessiyada. (Hisob bitta: chiqib, email kodi bilan qayta
   kiring.)
4. Ikki bosqichli himoya (TOTP) **faqat** quyidagilar uchun so‘raladi:
   “Shikoyatlar va a’zolar” (hamjamiyat moderatsiyasi, mutaxassis tasdig‘i) va
   “Adminlar boshqaruvi”. Sozlash: bo‘limga kiring → “Kalit”ni nusxalang yoki
   “Autentifikatorda ochish” → Google Authenticator / 1Password → 6 xonali kodni
   kiriting. Kalit yo‘qolsa: `docs/BACKEND_CLOUDFLARE.md`, 9-qadam.

### Xavfsizlik — ochiq aytiladi

Panel uchun TOTP talab qilinmasligi avvalgi dizayndan **zaifroq**: email qutingiz
buzilsa, panel ham ochiladi. Bu sizning ongli qaroringiz. Shuning uchun:
- Gmail’da **2 bosqichli tekshiruv** albatta yoqilgan bo‘lsin;
- server **har so‘rovda** emailni maxfiy ro‘yxat bilan solishtiradi (secret
  o‘zgarsa — darhol), faqat email kodi sessiyasini tan oladi, to‘xtatilgan
  hisobni rad etadi;
- har bir admin amali **“Amallar tarixi”**ga yoziladi (kim — niqoblangan email);
- admin to‘xtatilmaydi va o‘z rolini o‘zgartira olmaydi; so‘rovlar limitlangan.

## 3. Umumiy ko‘rsatkichlar — nima nimani bildiradi

| Ko‘rsatkich | Ma’nosi |
|---|---|
| Ro‘yxatdan o‘tgan | Emailini kod bilan (yoki Google/Apple bilan) tasdiqlagan hisoblar. Mehmonlar serverga tushmaydi — sanalmaydi |
| Bugun / 7 / 30 kunda yangi | Shu davrda ochilgan hisoblar (kunlar — Toshkent vaqti) |
| Hozir onlayn (5 daqiqa) | So‘nggi 5 daqiqada ilovadan serverga so‘rov yuborgan hisoblar |
| 7 / 30 kunda faol | Shu davrda ilovani ochib serverga murojaat qilgan hisoblar |
| To‘xtatilgan hisoblar | Siz to‘xtatgan hisoblar |
| Grafik (14 kun) | Har kuni nechta yangi hisob ochilgani; VoiceOver/TalkBack har ustunni sana va son bilan o‘qiydi |
| Rollar / tillar bo‘yicha | Profil roli va ilova tili (faqat umumiy son) |
| Guruhlar, ustozlar, talabalar | Ustoz–talaba bo‘limi |
| Test sessiyalari / natijalari | Guruhlardagi topshiriqlar va topshirilgan javoblar soni |
| Hamjamiyat savollari / javoblari | Savol-javob bo‘limi |
| Ochiq / hal qilingan shikoyatlar | Ilova ichidan yuborilgan shikoyatlar |
| Hamjamiyat: ko‘rilmagan shikoyatlar | Shikoyat qilingan postlar soni |
| Murojaatlar: javob kutmoqda | “Taklif va yordam”dagi yangi murojaatlar |

Shaxsiy ma’lumot ko‘rsatilmaydi: email faqat niqoblangan (`st***@gmail.com`),
IP va qurilma saqlanmaydi, faollik uchun faqat kun va daqiqa yoziladi.

### Ko‘rinmaydigan narsalar

- **Yuklab olishlar soni** — server buni bilmaydi (ilovada analitika SDK yo‘q,
  maxfiylik siyosati). Panelda **App Store Connect** va **Google Play Console**
  tugmalari bor: o‘sha yerda “Units/Installs” va boshqa do‘kon sonlari.
- **Sotuvlar: 0** — hozircha ilova to‘liq bepul, to‘lov yo‘q.
- To‘liq email — server uni saqlamaydi (faqat HMAC va niqob); “emailni ochish”
  yo‘q.

## 4. Shikoyatlar (Apple 1.2 talabi)

Apple foydalanuvchi kontenti bor ilovadan: xabar berish yo‘li, bloklash va
**o‘z vaqtida** ko‘rib chiqishni talab qiladi. Maqsad — **24 soat ichida**.

- **Ilova shikoyatlari** (Profil → Aloqa va shikoyat shakli; mehmon ham
  yuboradi, soatiga 5 ta): ro‘yxatda “Ochiq / Hal qilingan / Hammasi” va tur
  (shikoyat, nomaqbul kontent, xato, reklama, boshqa) filtri. Bittasini oching →
  matn, yuboruvchi (niqoblangan email yoki “Mehmon”), ishora (masalan, post id) →
  **Admin izohi** yozing (nima qilindi) → **Hal qilindi**. Kerak bo‘lsa —
  **Qayta ochish**.
- **Hamjamiyat shikoyatlari**: post bo‘yicha (nechta shikoyat, sabablar).
  “Postni ochish” → tekshiring → **Asossiz** (shikoyatlar yopiladi va
  avtomatik to‘xtatishga sanalmaydi) / **Hal qilindi** (masalan, postni
  o‘chirgansiz) / **Muallifni to‘xtatish**.
- **Email orqali** kelgan shikoyatlar `labguide@nfcstore.uz` ga keladi
  (`lib/core/contact.dart`) — ularni pochtada ko‘ring.

## 5. Foydalanuvchilar

- Qidiruv: **Email** rejimida to‘liq emailni yozing (server HMAC bilan aniq
  qidiradi; qisman qidiruv yo‘q). **Taxallus** rejimida — guruhdagi taxallus
  (kamida 2 belgi). Filtr: rol, holat (faol / to‘xtatilgan).
- Ro‘yxatda: niqoblangan email, rol, til, ro‘yxatdan o‘tgan va oxirgi faollik
  sanasi, holat; adminlar “Admin” belgisi bilan.
- Bittasini oching:
  - **Rol** (Talaba / Ustoz / Shifokor / Laboratoriya mutaxassisi) — bosing,
    darhol o‘zgaradi va jurnalga yoziladi. O‘z rolingiz o‘zgarmaydi.
  - **Hisobni to‘xtatish** — tasdiq so‘raladi; foydalanuvchi hamma
    qurilmalardan chiqariladi va qayta kira olmaydi (email kodi, Google, Apple).
    Ilova unga “Hisobingiz to‘xtatilgan. Savol bo‘lsa, yozing: …” deydi.
    **Qayta faollashtirish** — yana kira oladi. Adminni to‘xtatib bo‘lmaydi.
  - **Hamjamiyatda to‘xtatish / Tiklash** — faqat savol-javob yozishni
    to‘xtatadi, ilovaning qolgan qismi ishlaydi.
  - **Hisobni o‘chirish** (D-63) — emailda kelgan o‘chirish so‘rovi uchun
    (maxfiylik siyosati: **30 kun ichida**). Avval xat kelgan emailni Email
    qidiruvida toping (xat aynan shu manzildan kelganiga ishonch hosil qiling),
    hisobni oching, pastdagi “Hisobni o‘chirish” maydoniga **to‘liq emailni
    qayta** yozing → “Hisobni butunlay o‘chirish” → tasdiq. Server emailni shu
    hisob bilan solishtiradi (boshqa hisob o‘chmaydi). O‘chirish — foydalanuvchi
    o‘zi o‘chirgandagi bilan bir xil: guruhlar, natijalar, hamjamiyat postlari,
    bloklar, murojaatlar, sessiyalar, Google/Apple bog‘lanishi. Apple hisobida
    server Apple ruxsatini bekor qila olmaydi (ilovadagi Apple tasdig‘i kerak) —
    jurnalda `apple_revoke: no_code`; javob xatida foydalanuvchiga iPhone
    Sozlamalaridan ham olib tashlashni ayting. Jurnal: `account_deleted_by_admin`.
    O‘zingizni va boshqa adminni o‘chirib bo‘lmaydi. Qaytarib bo‘lmaydi.

## 6. Amallar tarixi

Har bir admin amali: nima qilindi, qachon, kim (niqoblangan email). O‘zgartirib
yoki o‘chirib bo‘lmaydi.

## 7. Hali yo‘q bo‘limlar

Hamkorlar (reklama) va reviewer berish bu serverga hali ko‘chirilmagan —
panelda “Bu serverda hali ulanmagan” deb belgilangan, bosilmaydi. Murojaatga
skrinshot biriktirish ham hozircha yo‘q (tugma ko‘rinmaydi).

## 8. Pro berish (D-73) — HOZIR O‘CHIQ
> **Holat: tayyor, lekin yoqilmagan.** Bo‘lim faqat Pro build bayrog‘i (`LG_PRO_ENABLED=true`) bilan yig‘ilgan ilovada VA
> serverda `LG_BILLING_ENABLED=true` bo‘lganda mavjud; migratsiya `0014_pro_grants.sql` hali production’ga qo‘llanmagan.
> Bayroq o‘chiq (standart) bo‘lsa bu bo‘lim ilovada ham, serverda ham (404) yo‘q — panel yuqoridagidek ishlaydi.

Nima qiladi: admin istalgan email manziliga Pro huquqini beradi (Talaba, Ustoz yoki Mutaxassis darajasi; 30/90/365 kun
yoki bekor qilinguncha; ixtiyoriy izoh). Ilovada: Admin panel → **Pro berish**.
- **Kim:** admin roli (serverda berilgan) VA ikki bosqichli himoya (TOTP) — “Adminlar boshqaruvi” bilan bir xil. Egasi
  panelining TOTP siz kirishi bu amalga yetmaydi: avval bo‘limda TOTP’ni tasdiqlang.
- **Hisob yo‘q email:** grant “kutilmoqda”; foydalanuvchi ro‘yxatdan o‘tganda yoki birinchi kirganda boshlanadi (muddat
  o‘sha paytdan). Hisob bor bo‘lsa — darhol.
- **Qayta berish:** standart — mavjud grant ALMASHTIRILADI (daraja va muddat yangilanadi, muddat hozirdan). “Uzaytirish”
  tanlansa — muddat mavjud tugashidan uzayadi (muddat tanlash shart; kutilayotgan grantni uzaytirib bo‘lmaydi).
- **Do‘kon obunasi bilan:** grant uni bosib o‘tmaydi — ikkalasidan yuqori daraja (teng bo‘lsa uzoqroq muddat) amal qiladi;
  grant qaytarib olinsa do‘kon obunasi saqlanadi.
- **Qaytarib olish:** ro‘yxatdagi tugma, tasdiq bilan; huquq darhol yo‘qoladi.
- **Daraja chegarasi (D-74):** grant faqat o‘z darajasi ochadigan imkoniyatlarni beradi — Talaba granti ustoz paneli Pro
  imkoniyatlarini OCHMAYDI (serverda `requireTier`), Ustoz/Mutaxassis — ochadi. Bugungi bepul guruhlar bunga bog‘liq emas.
  Grant bepul sinovni (bir telefonga bir marta) ishlatmaydi va unga ta’sir qilmaydi.
- **Xavfsizlik:** email serverda saqlanmaydi (HMAC + niqob), ro‘yxatda faqat niqoblangan; har berish/almashtirish/uzaytirish/
  qaytarib olish “Amallar tarixi”ga yoziladi (kim, kimga — niqob, daraja, muddat); limit: soatiga 30 ta berish.
- **Hali qaror qilinmagan:** kim bera olishi (hozir har TOTP’li admin), kutilayotgan grantning amal qilish muddati,
  foydalanuvchiga xabar, maxfiylik/shartlar matni (D-73 §5).

