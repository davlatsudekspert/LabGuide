# Hamkor firmalar va reklama

Laboratoriya apparatlari ishlab chiqaruvchilari, rasmiy distribyutorlar va
servis markazlari LabGuide ichida o‘z apparatlarini reklama qilishi mumkin.
Asosiy tamoyil: **foydalanuvchi reklamani foydali deb bilsin va ilovaga
ishonchi buzilmasin.** Shuning uchun:

- har bir reklama joyida aniq **“Reklama”** yoki **“Hamkor”** yorlig‘i bor;
- katalog faktlari, ularning tartibi va tekshiruv holati hamkorlikka
  **bog‘liq emas** (reklama bloki ma’lumot bo‘limidan alohida, eng oxirida);
- haqiqiy faol hamkor bo‘lmasa, hech qanday soxta kompaniya ko‘rsatilmaydi;
- server sozlanmagan buildda reklama joylari umuman chiqmaydi.

Hujjat ikki qismdan iborat: firmalar uchun taklif va admin qo‘llanmasi.
Oxirida texnik tafsilotlar va qonunchilik bo‘yicha eslatma.

---

## 1. Firmalar uchun taklif

### Nima beriladi

| Joy | Nima ko‘rinadi |
|---|---|
| **Apparat kartasi** (Lab → Apparatlar → yo‘nalish → ishlab chiqaruvchi → model) | Kartaning oxirida “Rasmiy hamkorlar” bo‘limi (“Reklama” yorlig‘i bilan): logo, kompaniya nomi va turi, qisqa tavsif, hududlar, apparatning O‘zbekistonda ro‘yxatdan o‘tganlik guvohnomasi raqami (berilgan bo‘lsa), **Qo‘ng‘iroq** va **Telegram** tugmalari, “Batafsil”. Hamkor model yoki butun ishlab chiqaruvchiga bog‘lanadi. |
| **Yo‘nalish** (masalan, Biokimyo) | Ishlab chiqaruvchilar ro‘yxatidan keyin ixcham “Hamkor · Reklama” kartasi (ko‘pi bilan ikkitasi, har kuni navbat bilan). |
| **Lab bosh sahifasi** | Bo‘limlar ro‘yxatidan keyin bitta “Reklama” kartasi (bir nechta hamkor bo‘lsa — har kuni navbat bilan). |
| **Asosiy menyu (Bosh sahifa) — 1-joy: laboratoriya xizmati** | Qidiruv maydonidan darhol keyin, tezkor amallar va hero kartasidan **oldin** (ilova ochilganda birinchi ekranda): 2-joy bilan yonma-yon juftlikdagi ixcham “Reklama” kartasi — logo, nom, qisqa tavsif, tur · “Batafsil” (hamkor sahifasiga). Faqat **laboratoriya xizmati** turidagi hamkor; bir nechta bo‘lsa — har kuni navbat bilan. Tor ekranda (< 360 px) yoki katta shriftda (> 1.15×) juftlik ustma-ust ixcham qatorlarga o‘tadi; faqat bitta joy to‘la bo‘lsa — u to‘liq kenglikda. |
| **Asosiy menyu (Bosh sahifa) — 2-joy: apparat firmasi** | Xuddi shunday karta (juftlikda o‘ngda); ishlab chiqaruvchi, rasmiy distribyutor yoki servis markazi turidagi hamkor uchun (kunlik navbat). |
| **Hamkor sahifasi** | Tavsif, barcha aloqa (telefon, Telegram, sayt, email, buklet), bog‘liq modellar va guvohnoma raqamlari. Sahifa boshida “Reklama” yorlig‘i, oxirida “bu sahifa — reklama” izohi. |
| **Hisobot** | Kun va joy bo‘yicha ko‘rsatilishlar va “bog‘lanish” bosilishlari (pastda — qanday sanalishi). |

#### Bosh sahifa joylari: build rejimiga qarab

> Reklama do‘kon buildlaridan kompilyatsiyada chiqarib tashlanadi (`LG_PARTNER_ADS=false`, `lib/core/build_flags.dart`); `true` faqat TestFlight va Play ichki test buildlarida (ci.yml `testflight` / `play_internal`).

| Holat | Nima ko‘rinadi |
|---|---|
| **Do‘kon build** (`LG_PARTNER_ADS=false`, standart; ci.yml `build` va kelajakdagi do‘kon rejimi) | Hech qanday reklama/hamkor UI yo‘q: bosh sahifa juftligi, Lab kartasi, apparat kartalari, hamkor sahifalari, “Hamkor bo‘lish”, Aloqa ekranidagi reklama bo‘limi, admin hamkor bo‘limlari; serverga hamkor so‘rovi va hisobot ham yo‘q. |
| **Test build** (`LG_PARTNER_ADS=true`), joy turiga mos **haqiqiy faol hamkor bor** | Hamkor kartasi; ko‘rsatilish va “bog‘lanish” hisoblagichi `home_lab` / `home_equipment` joylari bo‘yicha (bitta qurilmadan kuniga bir marta; faqat hisobli foydalanuvchi). |
| **Test build** (`LG_PARTNER_ADS=true`), hamkor **yo‘q** | Aniq belgilangan **“Namuna / Demo — reklama joyi”** kartasi: “Reklama” yorlig‘i, “Bu yerda hamkor laboratoriya xizmati / apparat firmasi reklamasi chiqadi” matni va “Reklama joylashtirish” (→ Hamkor bo‘lish sahifasi). Kompaniya nomi, logo, telefon, Telegram **yo‘q**; ko‘rsatilish ham, bosish ham **sanalmaydi**. |

Demo karta soxta kompaniya emas, faqat joyni ko‘rsatuvchi namuna; u faqat
ichki sinov buildlarida chiqadi, do‘kon foydalanuvchilariga ko‘rinmaydi.
Hamkor turi **“Laboratoriya xizmati”** (`laboratory`) yangi: u katalogdagi
apparatga bog‘lanmaydi, shuning uchun e’lon qilish uchun “kamida bitta
bog‘lanish” sharti bu tur uchun talab qilinmaydi (tavsif va aloqa baribir
shart). Apparat firmalari (ishlab chiqaruvchi, distribyutor, servis markazi)
uchun bog‘lanish sharti o‘zgarmagan.

### Auditoriya

LabGuide to‘rt rol uchun: laboratoriya mutaxassislari, shifokorlar,
talabalar va ustozlar; o‘zbek, rus va ingliz tillarida. Foydalanuvchilar
soni va rollar taqsimotini muzokara paytida **server statistikasidan**
(admin panel) ko‘rsatamiz — taxminiy yoki o‘ylab topilgan raqam aytilmaydi.

### Qoidalar

1. Har bir joyda aniq “Reklama” yoki “Hamkor” yorlig‘i turadi.
2. Katalog faktlari, tartibi va tekshiruv holati hamkorlikka bog‘liq emas —
   pul evaziga o‘zgartirilmaydi, “tasdiqlangan” holat berilmaydi.
3. Tibbiy buyum (laboratoriya apparati) reklamasi: apparat O‘zbekistonda
   ro‘yxatdan o‘tgan bo‘lishi kerak; guvohnoma raqami taqdim etilsa kartada
   ko‘rsatiladi (“raqamni hamkor taqdim etgan” izohi bilan).
4. Faqat tekshirsa bo‘ladigan ma’lumot: “eng yaxshi”, “100% aniq” kabi
   isbotsiz da’volar, boshqa kompaniyalarni kamsitish qabul qilinmaydi.
5. Foydalanuvchilarning shaxsiy ma’lumotlari hamkorga berilmaydi — faqat
   jamlangan hisoblagichlar.
6. Dori vositalari reklamasi bu bo‘limda joylanmaydi.

### Narx

**Narx kelishiladi** — joylar, muddat va hududlarga qarab. Ilovada va bu
hujjatda narx ko‘rsatilmaydi.

### Qanday ulanadi

1. Ilovada **Profil → Hamkor bo‘lish** sahifasida ariza yuboriladi
   (kompaniya, mas’ul shaxs, telefon/email, mahsulotlar, xabar). Ariza uchun
   email bilan kirish kerak — javob shu hisobga keladi (spamga qarshi:
   bir hisobdan kuniga ko‘pi bilan 3 ta ariza).
2. Biz bog‘lanamiz va shartlarni kelishamiz.
3. Firma materiallarni yuboradi:
   - logo — PNG yoki JPEG, ≤ 1 MB (kvadrat, shaffof yoki oq fon tavsiya);
   - kompaniya nomi va turi (ishlab chiqaruvchi / rasmiy distribyutor /
     servis markazi);
   - qisqa tavsif uz/ru/en (har biri ≤ 300 belgi);
   - hududlar (viloyatlar yoki butun respublika);
   - aloqa: telefon, Telegram username, sayt (https), email;
   - qaysi ishlab chiqaruvchi va modellar bilan bog‘lanadi;
   - har model uchun O‘zbekistonda ro‘yxatdan o‘tganlik guvohnomasi raqami
     (ixtiyoriy, lekin tibbiy buyum uchun tavsiya etiladi);
   - buklet havolasi (https, ixtiyoriy);
   - faollik davri (boshlanish va tugash sanasi).
4. Admin tekshiradi va e’lon qiladi; hisobot muntazam yuboriladi.

### Aloqa, reklama va shikoyat kanali

Ilovada **Profil → Aloqa va shikoyat** ekrani bor (`ContactScreen`, marshrut
`/profile/contact`). U **serverga bog‘liq emas, doim ochiq** va barcha murojaat
bitta ommaviy manzilga boradi: **labguide@nfcstore.uz** (Cloudflare Email
Routing orqali egasiga yo‘naltiriladi). Manzil kodda **bitta joyda** —
`lib/core/contact.dart` (`Contact.email`); almashtirish uchun faqat shu qiymat
o‘zgaradi (so‘ng `docs/store/PRIVACY_POLICY.md` va do‘kon “Support” maydonlarini
ham yangilang).

- **Savol va takliflar** — pochta ilovasi mavzu “LabGuide: savol/taklif” bilan ochiladi.
- **Reklama va hamkorlik** — mavzu “LabGuide: reklama”; server ulangan buildda
  qo‘shimcha ravishda **Hamkor bo‘lish** arizasiga havola.
- **Shikoyat / xato haqida xabar** — mavzu “LabGuide: shikoyat”: noto‘g‘ri tibbiy
  ma’lumot, nomaqbul reklama yoki foydalanuvchi kontenti. Xatda bo‘lim/karta
  (reklama bo‘lsa — firma) nomi so‘raladi. Javob muddati va’da qilinmaydi.
- Xat shabloniga faqat ilova versiyasi va platforma qo‘yiladi (shaxsiy ma’lumot
  yo‘q). Pochta ilovasi ochilmasa manzil nusxalanadi.

**Reklamaga shikoyat — qaytadan ko‘rib chiqish kerak:** hozir reklama
kartalarida (`lib/features/partners/partner_widgets.dart`) alohida
“Reklama haqida xabar” havolasi **yo‘q** (u fayl va `lib/features/home` boshqa
ish bilan band bo‘lgani uchun tegilmadi). Qo‘shish oson: `PartnerTag` yonida yoki
hamkor sahifasi (`PartnerScreen`) oxiridagi “bu sahifa — reklama” izohi (yoki umumiy `_AdFrame`)
ostida kichik `LgButton.link` — bosilganda `context.push('/profile/contact')`
yoki to‘g‘ridan-to‘g‘ri `Contact.mailto(subject: Contact.subjectReport, body: …)`
(xat matniga hamkor nomi/id qo‘yilsa, shikoyatni topish tezlashadi; shaxsiy
ma’lumot yo‘q). Matn uchun yangi ARB kaliti kerak (masalan, “Reklama haqida
xabar berish”).

---

## 2. Admin qo‘llanmasi

Kirish: **Profil → Admin panel** (server admin hisobi + ikki bosqichli TOTP).
Har amal serverda qayta tekshiriladi va **Amallar tarixi**ga (`admin_audit`)
yoziladi.

### Hamkorlik arizalari

Admin panel → **Hamkorlik arizalari** (yangi arizalar soni qatorda). Holat
filtri: Yangi / Ko‘rib chiqilmoqda / Qabul qilindi / Rad etildi. Arizani
ochib holatni tanlang va (ixtiyoriy) javob yozing — arizachi uni
“Hamkor bo‘lish” sahifasida ko‘radi. Javobni faqat inson yozadi.

### Hamkor yaratish va e’lon qilish

1. Admin panel → **Hamkorlar** → **Yangi hamkor**.
2. Nom, tur, logo (havola yoki **Logoni yuklash** — ochiq `partner-logos`
   bucket'iga), tavsif uz/ru/en, hududlar, aloqa, buklet.
3. **Katalogga bog‘lash:** ishlab chiqaruvchi chiplari (uning barcha
   modellari kartasida chiqadi) va/yoki **Model qo‘shish** (qidiruv bilan);
   model uchun guvohnoma raqami.
4. **Faollik davri** (standart: bugundan 30 kun).
5. **Saqlash** — qoralama (hech kimga ko‘rinmaydi).
6. **E’lon qilish** — server shartlarni tekshiradi: tavsif (kamida bitta
   tilda), kamida bitta aloqa, kamida bitta bog‘lanish. Shartlar bajarilmasa
   e’lon qilinmaydi.
7. **To‘xtatish** — reklama darhol yo‘qoladi (ilovalarda kesh yangilanishi
   bilan; pastga qarang). Hamkor o‘chirilmaydi — hisobot tarixi saqlanadi.
8. E’lon qilingan hamkorni tahrirlab **Saqlash** — o‘zgarish darhol
   ko‘rinadi (server e’lon shartlarini qayta tekshiradi). Katta
   o‘zgarishdan oldin to‘xtatib, tekshirib, qayta e’lon qilish xavfsizroq.

E’lon qilishdan oldin tekshiring:

- guvohnoma raqamini rasmiy reyestrdan (Sog‘liqni saqlash vazirligi
  tizimi) solishtiring — ilova raqamni avtomatik tekshirmaydi;
- tavsifda isbotsiz da’vo, boshqa kompaniyani kamsitish, tibbiy tashxis yoki
  davolash va’dasi yo‘qligini;
- kompaniya haqiqatan rasmiy distribyutor/servis ekanini (shartnoma yoki
  ishlab chiqaruvchi xati).

Holatlar ro‘yxatda: Qoralama, E’lon qilingan, To‘xtatilgan, Muddati tugagan
(e’lon qilingan, lekin tugash sanasi o‘tgan), Hali boshlanmagan.

### Statistika va hisobot

Hamkor → **Statistika**: 30 kunlik ko‘rsatilish va “bog‘lanish” bosilishi,
bosilish ulushi (CTR); 7 kun / 30 kun / butun davr; joylar bo‘yicha; kunlar
bo‘yicha. **Hisobotni nusxalash** — matnni firmaga yuborish uchun.

Qanday sanaladi (hisobotda ham shu matn bor):

- **Ko‘rsatilish** — hamkor bloki foydalanuvchi ekranida chizilgan;
  bitta qurilmadan kuniga har joy uchun bir marta.
- **Bog‘lanish** — Qo‘ng‘iroq, Telegram, sayt, email yoki buklet tugmasi
  bosilgan; bitta qurilmadan kuniga har joy uchun bir marta.
- Faqat **hisobga kirgan** foydalanuvchilar sanaladi; mehmonlar va admin
  sanalmaydi (shuning uchun raqamlar haqiqiy auditoriyadan kam — bu
  ataylab ehtiyotkor hisob).
- Kun — Toshkent vaqti bo‘yicha. Faqat kunlik hisoblagich saqlanadi: kim
  ko‘rgani yoki bosgani hech qayerda yozilmaydi.

---

## 3. Texnik tafsilotlar

Migratsiya: `supabase/migrations/20261009001000_partners.sql` (+
`20261017000100_partner_home_slots.sql`), qabul
testlari: `supabase/tests/20_partners.sql` (`tool/backend_test.sh`).

| Jadval | Nima | O‘qish (RLS) | Yozish |
|---|---|---|---|
| `partners` | profil, davr, holat | hamma (anon ham): faqat `published` va bugun faol; admin (aal2): hammasi | `admin_partner_save`, `admin_partner_set_status` |
| `partner_links` | ishlab chiqaruvchi/model id lari, guvohnoma raqami | faqat ko‘rinadigan hamkor bilan | `admin_partner_save` |
| `partner_events` | kunlik agregat: hamkor × kun × joy → ko‘rsatilish, bog‘lanish | faqat admin | `partner_track` |
| `partner_event_quota` | spamga qarshi: hisobga bitta qator (bugungi son) | hech kim | `partner_track` |
| `partner_requests` | arizalar | egasi yoki admin | `partner_request_create`, `admin_partner_request_update` |

- `partners_feed()` — ilova o‘qiydigan ro‘yxat (chaqiruvchi huquqi bilan, RLS
  qo‘llanadi; admin uchun ham faqat faol hamkorlar — qoralama reklama
  joyiga chiqmaydi).
- Hisobot joylari (`partner_events.placement`): `card`, `category`,
  `lab_home`, `partner_page`, `home_lab`, `home_equipment`. Hamkor turlari:
  `manufacturer`, `distributor`, `service`, `laboratory`. Bosh sahifa
  joylari va `laboratory` turi `supabase/migrations/20261017000100_partner_home_slots.sql`
  migratsiyasi bilan qo‘shilgan (eski serverda yangi joy hodisasi rad etiladi
  — avval migratsiyani qo‘llang).
- `partner_track(p_events)` — faqat hisobli foydalanuvchi; bir chaqiruvda
  ≤ 20 hodisa, hisobga kuniga ≤ 100; faol bo‘lmagan hamkor sanalmaydi; admin
  hodisasi sanalmaydi.
- `partner_request_create` — faqat hisobli foydalanuvchi, kuniga ≤ 3 ta.
- Logo: ochiq `partner-logos` bucket (PNG/JPEG, ≤ 1 MB), yuklash faqat admin.
- Admin amallari: `partner_created`, `partner_updated`, `partner_published`,
  `partner_paused`, `partner_draft`, `partner_request` — `admin_audit` da.

Ilova (`lib/features/partners/`):

- `PartnersController` ro‘yxatni `partners.cache` ga keshlaydi: internet
  bo‘lmasa oxirgi ro‘yxat ko‘rinadi, muddati o‘tgan hamkor esa keshdan ham
  ko‘rsatilmaydi. Yangilash: ilova ochilganda va reklama joyi ochilganda
  (kesh 6 soatdan eski bo‘lsa). To‘xtatilgan hamkor boshqa qurilmalarda
  shu yangilanishgacha qolishi mumkin (ko‘pi bilan 6 soat yoki ilova qayta
  ochilguncha).
- Hodisalar bir kadrda yig‘ilib bitta so‘rovda yuboriladi; dublikat
  qurilmada tashlanadi.
- `UnconfiguredBackend.partners()` bo‘sh ro‘yxat qaytaradi va
  `PartnersController.enabled == false` — reklama joylari chizilmaydi;
  “Hamkor bo‘lish” sahifasi taklifni ko‘rsatadi, ariza esa “server hali
  ulanmagan” deydi.
- Logo internetdan yuklanmasa — kompaniya nomining bosh harflari.

---

## 4. Qonunchilik bo‘yicha eslatma

> **Bu huquqiy maslahat emas.** Quyidagilar ilovani loyihalashda e’tiborga
> olingan umumiy eslatma. Hamkorlik shartnomasi va reklama matnlari
> bo‘yicha yurist bilan maslahatlashing; e’lon qilishdan oldin qonunlarning
> amaldagi tahririni [lex.uz](https://lex.uz) da tekshiring.

Quyidagi moddalar 2026-10-09 kuni lex.uz’dagi rasmiy matndan tekshirildi:

**“Reklama to‘g‘risida”gi Qonun** (O‘RQ-776, 07.06.2022;
[lex.uz/docs/6052631](https://lex.uz/uz/docs/-6052631)):

- **18-modda “Reklamani identifikatsiya qilish”** — reklama, tarqatilish
  shakli va vositasidan qat’i nazar, boshqa axborotdan ajratilgan va
  reklama sifatida identifikatsiya qilinadigan bo‘lishi kerak (bosma
  nashrlarda — “Reklama” so‘zi bilan). Ilovada: har joyda “Reklama” /
  “Hamkor” yorlig‘i, reklama bloki katalog ma’lumotidan alohida.
- **16-modda “Reklamaga doir asosiy talablar”** — reklama qilish taqiqlangan
  holatlar ro‘yxatida majburiy sertifikatlashtirish guvohnomalari yoki
  maxsus ruxsatnomalari mavjud bo‘lmagan tovarlar ham bor.
- **12-modda** (reklama beruvchining majburiyatlari) va **13-modda**
  (reklama tayyorlovchi va tarqatuvchining huquqlari) — majburiy
  sertifikatlanadigan tovar yoki litsenziyalanadigan faoliyat reklamasida
  tegishli sertifikat/litsenziya/ruxsat hujjati taqdim etiladi; tarqatuvchi
  ularni talab qilishga haqli. Amalda: admin hamkordan guvohnoma va
  rasmiy vakillik hujjatini oladi.
- **31-modda** — Internet orqali tarqatiladigan reklama; 16-modda
  talablariga rioya qilinishi kerak.
- **34-modda “Dori vositalarini reklama qilish”** — dori vositalari uchun
  alohida cheklovlar (masalan, ro‘yxatdan o‘tmagan yoki retsept bo‘yicha
  beriladigan dorilar). LabGuide hamkorlik bo‘limida dori reklamasi
  joylanmaydi.
- Qonun matnida “tibbiy buyum” yoki “tibbiy texnika” reklamasiga bag‘ishlangan
  alohida modda topilmadi — umumiy talablar (16, 18-moddalar) qo‘llanadi.

**“Dori vositalari va farmatsevtika faoliyati to‘g‘risida”gi Qonun**
(2016-yil 4-yanvardagi O‘RQ-399 bilan yangi tahrirda;
[lex.uz/acts/2856464](https://lex.uz/uz/acts/-2856464)):

- **12-modda** — dori vositalari, tibbiy buyumlar va tibbiy texnikani davlat
  ro‘yxatidan o‘tkazish;
- **14-modda** — dori vositalari, tibbiy buyumlar, tibbiy texnika haqidagi
  axborot va dori vositalari reklamasi;
- **20-modda** — O‘zbekistonda ro‘yxatdan o‘tkazilmagan dori vositalari va
  tibbiy buyumlarni chakana realizatsiya qilish va ulardan foydalanish
  taqiqlanadi (19 va 24-moddalarda ulgurji savdo va import uchun ham shunday
  cheklovlar bor).

Tibbiy buyumlarni davlat ro‘yxatidan o‘tkazish tartibi Vazirlar Mahkamasi
qarorlari bilan belgilanadi. lex.uz’da 2018-yil 23-martdagi 213-son qaror
sahifasida u 2026-yil 26-fevraldan kuchini yo‘qotgani va 2025-yil
24-noyabrdagi 738-son qaror bilan almashtirilgani ko‘rsatilgan; yangi
qaror matnini alohida tekshirmadik. Shu sababli amaliy qoida:
**faqat O‘zbekistonda ro‘yxatdan o‘tgan apparat reklama qilinadi** va
guvohnoma raqami rasmiy reyestrdan solishtiriladi.

Moddalar raqami va mazmuni keyingi o‘zgartishlarda o‘zgarishi mumkin —
yuqoridagi havolalar orqali har safar amaldagi tahrirni tekshiring.
